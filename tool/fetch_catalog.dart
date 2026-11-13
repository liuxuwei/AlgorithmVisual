import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:algorithm_visual/catalog/leetcode_client.dart';
import 'package:algorithm_visual/catalog/problem_catalog.dart';

/// 生成 assets/problem_catalog.json 内置快照
///
/// 用法: dart run tool/fetch_catalog.dart
/// 输出: 100 条题目元数据 + 中文题面 HTML
Future<void> main(List<String> args) async {
  final outputPath = args.isNotEmpty ? args.first : 'assets/problem_catalog.json';
  final client = LeetCodeClient();

  stdout.writeln('拉取热题 100 列表...');
  final remote = await client.fetchHot100();
  stdout.writeln('获取到 ${remote.length} 道题, 开始拉取题面...');

  final entries = <Map<String, dynamic>>[];
  for (var i = 0; i < remote.length; i++) {
    final problem = remote[i];
    final statement = await _fetchStatementWithRetry(client, problem.titleSlug);
    entries.add({
      'titleSlug': problem.titleSlug,
      'number': problem.number,
      'title': problem.title,
      'difficulty': problem.difficulty.name,
      'groupSlug': problem.groupSlug,
      'patternId': _patternForGroup(problem.groupSlug),
      'code': '',
      'presets': const [],
      'maxInputSize': 0,
      'maxFrames': 2000,
      'statementHtml': ?statement,
    });
    stdout.writeln(
      '[${i + 1}/${remote.length}] ${problem.number}. ${problem.title}'
      '${statement == null ? ' (题面缺失)' : ''}',
    );
    await Future<void>.delayed(const Duration(milliseconds: 80));
  }

  final payload = jsonEncode({
    'fetchedAt': DateTime.now().toUtc().toIso8601String(),
    'problems': entries,
  });

  // 解析自检
  final catalog = ProblemCatalog.fromJson(
    jsonDecode(payload) as Map<String, dynamic>,
  );
  if (catalog.count != 100) {
    throw StateError('快照题目数量异常: ${catalog.count}');
  }

  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(payload);
  stdout.writeln('已写入 $outputPath (${catalog.count} 条, ${catalog.groups.length} 组)');

  client.close();
}

Future<String?> _fetchStatementWithRetry(
  LeetCodeClient client,
  String titleSlug,
) async {
  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      final html = await client.fetchStatement(titleSlug);
      if (html != null && html.trim().isNotEmpty) return html;
      return null;
    } catch (e) {
      if (attempt == 2) {
        stderr.writeln('题面拉取失败 $titleSlug: $e');
        return null;
      }
      await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));
    }
  }
  return null;
}

String _patternForGroup(String groupSlug) {
  switch (groupSlug) {
    case 'hash-table':
      return 'hash-table';
    case 'two-pointers':
      return 'array-two-pointer';
    case 'sliding-window':
      return 'array-sliding-window';
    case 'substring':
      return 'array-prefix-sum';
    case 'array':
    case 'greedy':
    case 'tricks':
      return 'array-basic';
    case 'matrix':
    case 'graph':
      return 'matrix-grid';
    case 'linked-list':
      return 'linked-list';
    case 'binary-tree':
      return 'binary-tree';
    case 'backtracking':
      return 'backtracking';
    case 'binary-search':
      return 'array-binary-search';
    case 'stack':
      return 'stack';
    case 'heap':
      return 'heap';
    case 'dp':
      return 'dp-1d';
    case 'dp-multidim':
      return 'dp-2d';
    default:
      return 'array-basic';
  }
}
