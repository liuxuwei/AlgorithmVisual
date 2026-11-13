import 'package:algorithm_visual/catalog/leetcode_client.dart';
import 'package:algorithm_visual/catalog/problem_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'fake_http.dart';
import 'snapshot_test_data.dart';

void main() {
  group('LeetCodeClient.fetchHot100', () {
    test('mock 响应解析出 100 题并按专题映射', () async {
      final client = LeetCodeClient(client: snapshotBackedClient());
      final problems = await client.fetchHot100();

      expect(problems.length, 100);
      expect(problems.first.titleSlug, 'two-sum');
      expect(problems.first.number, 1);
      expect(problems.first.title, '两数之和');
      expect(problems.first.difficulty, ProblemDifficulty.easy);
      expect(problems.first.groupSlug, 'hash-table');

      final linkedListSlugs =
          problems.where((p) => p.groupSlug == 'linked-list').map((p) => p.titleSlug);
      expect(linkedListSlugs.length, 14);
      expect(linkedListSlugs, contains('reverse-linked-list'));
      client.close();
    });

    test('题目数量异常时抛出 LeetCodeException', () async {
      final client = LeetCodeClient(client: snapshotBackedClient(omitCount: 1));
      expect(client.fetchHot100(), throwsA(isA<LeetCodeException>()));
      client.close();
    });

    test('HTTP 错误时抛出 LeetCodeException', () async {
      final client = LeetCodeClient(
        client: FakeHttpClient((_) async => http.Response('oops', 500)),
      );
      expect(client.fetchHot100(), throwsA(isA<LeetCodeException>()));
      client.close();
    });

    test('响应缺少 data 时抛出 LeetCodeException', () async {
      final client = LeetCodeClient(
        client: FakeHttpClient((_) async => http.Response('{"data":{}}', 200)),
      );
      expect(client.fetchHot100(), throwsA(isA<LeetCodeException>()));
      client.close();
    });
  });

  group('LeetCodeClient.fetchStatement', () {
    test('解析中文题面 HTML', () async {
      final client = LeetCodeClient(client: snapshotBackedClient());
      final html = await client.fetchStatement('two-sum');
      expect(html, contains('示例题面内容'));
      client.close();
    });

    test('快照真实题面可读且不含空内容', () async {
      final raw = loadSnapshotRaw();
      expect(raw.contains('statementHtml'), isTrue);
    });
  });
}
