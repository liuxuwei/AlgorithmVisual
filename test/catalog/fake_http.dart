import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:algorithm_visual/catalog/problem_catalog.dart';
import 'package:algorithm_visual/catalog/problem_entry.dart';

import 'snapshot_test_data.dart';

/// 可注入的假 HTTP 客户端
class FakeHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request request) handler;

  FakeHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request as http.Request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
    );
  }
}

/// 用真实快照构造热题 100 GraphQL 响应; omitCount 用于模拟数量异常
String hot100Response({int omitCount = 0}) {
  final catalog = ProblemCatalog.fromJson(loadSnapshotJson());
  var remaining = omitCount;
  final groups = <Map<String, dynamic>>[];
  for (final group in kProblemGroups) {
    final questions = <Map<String, dynamic>>[];
    for (final p in catalog.byGroup(group.slug)) {
      if (remaining > 0) {
        remaining--;
        continue;
      }
      questions.add({
        'titleSlug': p.titleSlug,
        'questionFrontendId': '${p.number}',
        'title': p.title,
        'translatedTitle': p.title,
        'difficulty': p.difficulty.name.toUpperCase(),
      });
    }
    groups.add({
      'slug': 'remote-${group.slug}',
      'name': group.name,
      'questions': questions,
    });
  }
  return jsonEncode({
    'data': {
      'studyPlanV2Detail': {
        'name': 'LeetCode 热题 100',
        'planSubGroups': groups,
      },
    },
  });
}

String questionResponse(String html) {
  return jsonEncode({
    'data': {
      'question': {
        'translatedTitle': '题目',
        'translatedContent': html,
      },
    },
  });
}

/// 统一处理 hot100 与 question 两类查询
FakeHttpClient snapshotBackedClient({int omitCount = 0}) {
  return FakeHttpClient((request) async {
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final query = body['query'] as String? ?? '';
    if (query.contains('studyPlanV2Detail')) {
      return http.Response(
        hot100Response(omitCount: omitCount),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }
    return http.Response(
      questionResponse('<p>示例题面内容</p>'),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

/// 从快照构造 100 条本地条目 (脚本、代码在真实 problem_data 中补齐)
List<ProblemEntry> snapshotLocalProblems() {
  return ProblemCatalog.fromJson(loadSnapshotJson()).problems;
}
