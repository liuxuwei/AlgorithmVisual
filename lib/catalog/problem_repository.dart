import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'leetcode_client.dart';
import 'problem_catalog.dart';
import 'problem_entry.dart';

/// 跨端键值缓存抽象 (便于单测替换为内存实现)
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

/// 内存实现, 用于单测与降级
class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }
}

/// 内置快照来源抽象
abstract class SnapshotSource {
  Future<String?> load();
}

/// 题库加载状态
class CatalogState {
  final ProblemCatalog? catalog;

  /// 是否正在首次加载 (尚无任何可展示数据)
  final bool isLoading;

  /// 当前数据是否来自内置快照 / 旧缓存 (网络不可用)
  final bool isOffline;

  /// 最近一次加载错误信息 (非阻塞)
  final String? error;

  /// 最近一次成功刷新的时间
  final DateTime? fetchedAt;

  const CatalogState({
    this.catalog,
    this.isLoading = false,
    this.isOffline = false,
    this.error,
    this.fetchedAt,
  });

  bool get hasCatalog => catalog != null;

  CatalogState copyWith({
    ProblemCatalog? catalog,
    bool? isLoading,
    bool? isOffline,
    String? error,
    DateTime? fetchedAt,
    bool clearError = false,
  }) {
    return CatalogState(
      catalog: catalog ?? this.catalog,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      error: clearError ? null : (error ?? this.error),
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }
}

/// 题库仓库: 缓存 → 立即返回 → 后台刷新 → 失败降级快照
class ProblemRepository {
  static const String catalogCacheKey = 'catalog:top-100';

  final Map<String, ProblemEntry> _local;
  final LeetCodeClient _client;
  final KeyValueStore _store;
  final SnapshotSource? _snapshot;

  final ValueNotifier<CatalogState> state =
      ValueNotifier<CatalogState>(const CatalogState(isLoading: true));

  bool _disposed = false;

  void _setState(CatalogState value) {
    if (!_disposed) state.value = value;
  }

  ProblemRepository({
    required List<ProblemEntry> localProblems,
    LeetCodeClient? client,
    KeyValueStore? store,
    SnapshotSource? snapshot,
  })  : _local = {for (final p in localProblems) p.titleSlug: p},
        _client = client ?? LeetCodeClient(),
        _store = store ?? MemoryKeyValueStore(),
        // ignore: prefer_initializing_formals
        _snapshot = snapshot;

  List<ProblemEntry> get localProblems => List.unmodifiable(_local.values);

  ProblemCatalog? get catalog => state.value.catalog;

  /// 首次加载: 优先缓存, 其次内置快照, 最后网络; 随后后台刷新
  Future<void> load() async {
    _setState(state.value.copyWith(isLoading: true, clearError: true));

    final cached = await _readCachedCatalog();
    if (cached != null) {
      _setState(CatalogState(
        catalog: _mergeWithLocal(cached),
        isLoading: false,
        isOffline: false,
      ));
      unawaited(refresh());
      return;
    }

    final snapshot = await _readSnapshotCatalog();
    if (snapshot != null) {
      _setState(CatalogState(
        catalog: _mergeWithLocal(snapshot),
        isLoading: false,
        isOffline: true,
      ));
      unawaited(refresh());
      return;
    }

    final ok = await refresh();
    if (!ok && state.value.catalog == null) {
      _setState(state.value.copyWith(
        isLoading: false,
        error: state.value.error ?? '题库加载失败',
      ));
    }
  }

  /// 主动刷新 (重试入口), 返回是否成功切换到在线数据
  Future<bool> refresh() async {
    try {
      final remote = await _client.fetchHot100();
      final catalog = _buildOnlineCatalog(remote);
      _setState(CatalogState(
        catalog: catalog,
        isLoading: false,
        isOffline: false,
        fetchedAt: DateTime.now(),
      ));
      await _writeCachedCatalog(catalog);
      return true;
    } catch (e) {
      final current = state.value;
      if (current.catalog == null) {
        final snapshot = await _readSnapshotCatalog();
        if (snapshot != null) {
          _setState(CatalogState(
            catalog: _mergeWithLocal(snapshot),
            isLoading: false,
            isOffline: true,
            error: '$e',
          ));
        } else {
          _setState(CatalogState(isLoading: false, error: '$e'));
        }
      } else {
        _setState(current.copyWith(isLoading: false, error: '$e'));
      }
      return false;
    }
  }

  /// 懒加载单题题面: 条目自带 → 缓存 → 网络
  Future<String?> statementFor(ProblemEntry entry) async {
    final local = entry.statementHtml;
    if (local != null && local.trim().isNotEmpty) return local;

    final key = 'statement:${entry.titleSlug}';
    final cached = await _store.read(key);
    if (cached != null && cached.trim().isNotEmpty) return cached;

    try {
      final html = await _client.fetchStatement(entry.titleSlug);
      if (html != null && html.trim().isNotEmpty) {
        await _store.write(key, html);
        return html;
      }
    } catch (_) {
      // 网络失败时返回 null, 由 UI 展示可重试的加载失败
    }
    return null;
  }

  ProblemCatalog _buildOnlineCatalog(List<RemoteProblem> remote) {
    final bySlug = {for (final r in remote) r.titleSlug: r};
    if (bySlug.length != 100) {
      throw LeetCodeException('题目数量异常: ${bySlug.length} (期望 100)');
    }

    final entries = <ProblemEntry>[];
    for (final local in _local.values) {
      final r = bySlug[local.titleSlug];
      if (r == null) {
        throw LeetCodeException('网络题库缺少本地题目: ${local.titleSlug}');
      }
      entries.add(local.applyRemote(ProblemEntry(
        titleSlug: r.titleSlug,
        number: r.number,
        title: r.title,
        difficulty: r.difficulty,
        groupSlug: r.groupSlug,
        patternId: local.patternId,
        code: local.code,
        presets: local.presets,
        inputSchema: local.inputSchema,
        maxInputSize: local.maxInputSize,
        maxFrames: local.maxFrames,
      )));
    }
    return ProblemCatalog(entries);
  }

  /// 网络 / 快照 / 缓存只提供元数据, 本地条目补齐脚本、代码与预置输入
  ProblemCatalog _mergeWithLocal(ProblemCatalog remoteCatalog) {
    final entries = <ProblemEntry>[];
    for (final local in _local.values) {
      final remote = remoteCatalog.bySlug(local.titleSlug);
      entries.add(remote == null ? local : local.applyRemote(remote));
    }
    return ProblemCatalog(entries);
  }

  Future<ProblemCatalog?> _readCachedCatalog() async {
    final raw = await _store.read(catalogCacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final catalogJson = decoded['catalog'] as Map?;
      if (catalogJson == null) {
        await _store.remove(catalogCacheKey);
        return null;
      }
      final catalog = ProblemCatalog.fromJson(
        Map<String, dynamic>.from(catalogJson),
      );
      if (catalog.count != 100) {
        await _store.remove(catalogCacheKey);
        return null;
      }
      return catalog;
    } catch (_) {
      await _store.remove(catalogCacheKey);
      return null;
    }
  }

  Future<void> _writeCachedCatalog(ProblemCatalog catalog) async {
    final payload = jsonEncode({
      'fetchedAt': DateTime.now().toIso8601String(),
      'catalog': catalog.toJson(includeStatement: false),
    });
    await _store.write(catalogCacheKey, payload);
  }

  Future<ProblemCatalog?> _readSnapshotCatalog() async {
    final source = _snapshot;
    if (source == null) return null;
    try {
      final raw = await source.load();
      if (raw == null || raw.isEmpty) return null;
      final catalog = ProblemCatalog.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (catalog.count != 100) return null;
      return catalog;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _disposed = true;
    _client.close();
    state.dispose();
  }
}
