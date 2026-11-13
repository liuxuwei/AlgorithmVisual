import 'dart:convert';

import 'package:algorithm_visual/catalog/leetcode_client.dart';
import 'package:algorithm_visual/catalog/problem_catalog.dart';
import 'package:algorithm_visual/catalog/problem_entry.dart';
import 'package:algorithm_visual/catalog/problem_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'fake_http.dart';
import 'snapshot_test_data.dart';

const _jsonHeaders = {'content-type': 'application/json; charset=utf-8'};

class _StringSnapshot implements SnapshotSource {
  final String? raw;
  const _StringSnapshot(this.raw);

  @override
  Future<String?> load() async => raw;
}

void main() {
  late List<ProblemEntry> localProblems;

  setUpAll(() {
    localProblems = snapshotLocalProblems();
  });

  ProblemRepository buildRepository({
    KeyValueStore? store,
    SnapshotSource? snapshot,
    http.BaseClient? httpClient,
  }) {
    return ProblemRepository(
      localProblems: localProblems,
      client: LeetCodeClient(
        client: httpClient ?? snapshotBackedClient(),
      ),
      store: store ?? MemoryKeyValueStore(),
      snapshot: snapshot,
    );
  }

  group('ProblemRepository', () {
    test('缓存命中时立即返回且不标记离线', () async {
      final store = MemoryKeyValueStore();
      final cachedCatalog = ProblemCatalog.fromJson(loadSnapshotJson());
      await store.write(
        ProblemRepository.catalogCacheKey,
        jsonEncode({
          'fetchedAt': DateTime.now().toIso8601String(),
          'catalog': cachedCatalog.toJson(includeStatement: false),
        }),
      );

      final repo = buildRepository(
        store: store,
        snapshot: const _StringSnapshot(null),
        httpClient: FakeHttpClient((_) async => http.Response('{"data":{}}', 200)),
      );
      await repo.load();

      expect(repo.state.value.catalog!.count, 100);
      expect(repo.state.value.isLoading, isFalse);
      expect(repo.state.value.isOffline, isFalse);
      repo.dispose();
    });

    test('缓存损坏时丢弃缓存并回退内置快照', () async {
      final store = MemoryKeyValueStore();
      await store.write(ProblemRepository.catalogCacheKey, '{broken json');

      final repo = buildRepository(
        store: store,
        snapshot: _StringSnapshot(loadSnapshotRaw()),
        httpClient: FakeHttpClient((_) async => throw Exception('offline')),
      );
      await repo.load();

      expect(repo.state.value.catalog!.count, 100);
      expect(repo.state.value.isOffline, isTrue);
      expect(await store.read(ProblemRepository.catalogCacheKey), isNull);
      repo.dispose();
    });

    test('网络失败时使用快照并带离线标记', () async {
      final repo = buildRepository(
        snapshot: _StringSnapshot(loadSnapshotRaw()),
        httpClient: FakeHttpClient((_) async => throw Exception('offline')),
      );
      await repo.load();
      // 等后台刷新失败后写入错误信息
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(repo.state.value.catalog!.count, 100);
      expect(repo.state.value.isOffline, isTrue);
      expect(repo.state.value.error, isNotNull);
      repo.dispose();
    });

    test('接口返回题目数量异常时不展示残缺列表', () async {
      final repo = buildRepository(
        snapshot: const _StringSnapshot(null),
        httpClient: FakeHttpClient(
          (_) async => http.Response(
            hot100Response(omitCount: 1),
            200,
            headers: _jsonHeaders,
          ),
        ),
      );
      await repo.load();

      expect(repo.state.value.catalog, isNull);
      expect(repo.state.value.isLoading, isFalse);
      expect(repo.state.value.error, isNotNull);
      repo.dispose();
    });

    test('刷新成功后切换为在线数据', () async {
      final store = MemoryKeyValueStore();
      final repo = buildRepository(
        store: store,
        snapshot: _StringSnapshot(loadSnapshotRaw()),
        httpClient: snapshotBackedClient(),
      );
      await repo.load();
      expect(repo.state.value.isOffline, isTrue);

      final ok = await repo.refresh();
      expect(ok, isTrue);
      expect(repo.state.value.isOffline, isFalse);
      expect(repo.state.value.fetchedAt, isNotNull);
      expect(await store.read(ProblemRepository.catalogCacheKey), isNotNull);
      repo.dispose();
    });

    test('题面懒加载命中缓存后不重复请求', () async {
      var questionRequests = 0;
      final client = FakeHttpClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if ((body['query'] as String).contains('studyPlanV2Detail')) {
          return http.Response(hot100Response(), 200, headers: _jsonHeaders);
        }
        questionRequests++;
        return http.Response(
          questionResponse('<p>题面</p>'),
          200,
          headers: _jsonHeaders,
        );
      });

      final repo = buildRepository(store: MemoryKeyValueStore(), httpClient: client);
      await repo.load();

      final rawEntry =
          repo.localProblems.firstWhere((p) => p.titleSlug == 'two-sum');
      final entry = ProblemEntry.fromJson(
        rawEntry.toJson()..remove('statementHtml'),
      );
      final first = await repo.statementFor(entry);
      final second = await repo.statementFor(entry);

      expect(first, contains('题面'));
      expect(second, contains('题面'));
      expect(questionRequests, 1);
      repo.dispose();
    });
  });
}
