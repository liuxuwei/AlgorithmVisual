import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'problem_catalog.dart';
import 'problem_entry.dart';

/// LeetCode 请求失败
class LeetCodeException implements Exception {
  final String message;
  const LeetCodeException(this.message);

  @override
  String toString() => 'LeetCodeException: $message';
}

/// 网络返回的单题元数据
class RemoteProblem {
  final String titleSlug;
  final int number;
  final String title;
  final ProblemDifficulty difficulty;
  final String groupSlug;
  final String groupName;

  const RemoteProblem({
    required this.titleSlug,
    required this.number,
    required this.title,
    required this.difficulty,
    required this.groupSlug,
    required this.groupName,
  });
}

/// LeetCode 网页端 GraphQL 客户端
///
/// 只负责拉取「热题 100」列表与单题题面。代码、步骤脚本与预置输入均由本地提供。
class LeetCodeClient {
  static final Uri defaultEndpoint = Uri.parse('https://leetcode.cn/graphql/');

  final http.Client _client;
  final Uri endpoint;
  final Duration timeout;
  final bool _ownsClient;

  LeetCodeClient({
    http.Client? client,
    Uri? endpoint,
    this.timeout = const Duration(seconds: 15),
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        endpoint = endpoint ?? defaultEndpoint;

  static const String _hot100Query = '''
query hot100 {
  studyPlanV2Detail(planSlug: "top-100-liked") {
    name
    planSubGroups {
      slug
      name
      questions {
        titleSlug
        questionFrontendId
        title
        translatedTitle
        difficulty
      }
    }
  }
}''';

  static const String _questionQuery = '''
query question(\$titleSlug: String!) {
  question(titleSlug: \$titleSlug) {
    translatedTitle
    translatedContent
  }
}''';

  /// 拉取热题 100 列表 (17 组, 共 100 题)
  Future<List<RemoteProblem>> fetchHot100() async {
    final data = await _post(_hot100Query, const {});
    final plan = data['studyPlanV2Detail'];
    if (plan is! Map) {
      throw const LeetCodeException('响应缺少 studyPlanV2Detail');
    }
    final groups = plan['planSubGroups'];
    if (groups is! List || groups.length != kProblemGroups.length) {
      throw LeetCodeException(
        '专题分组数量异常: ${groups is List ? groups.length : 0}',
      );
    }

    final result = <RemoteProblem>[];
    for (var gi = 0; gi < groups.length; gi++) {
      final group = groups[gi];
      if (group is! Map) {
        throw const LeetCodeException('专题分组结构异常');
      }
      final canonical = kProblemGroups[gi];
      final questions = group['questions'];
      if (questions is! List) {
        throw LeetCodeException('专题 ${canonical.name} 缺少题目列表');
      }
      for (final raw in questions) {
        if (raw is! Map) {
          throw const LeetCodeException('题目结构异常');
        }
        final slug = raw['titleSlug'];
        final number = int.tryParse('${raw['questionFrontendId']}');
        if (slug is! String || slug.isEmpty || number == null) {
          throw const LeetCodeException('题目缺少 titleSlug 或题号');
        }
        final title = (raw['translatedTitle'] ?? raw['title'] ?? slug) as String;
        result.add(RemoteProblem(
          titleSlug: slug,
          number: number,
          title: title,
          difficulty: ProblemDifficulty.fromLeetCode('${raw['difficulty']}'),
          groupSlug: canonical.slug,
          groupName: canonical.name,
        ));
      }
    }

    if (result.length != 100) {
      throw LeetCodeException('题目数量异常: ${result.length} (期望 100)');
    }
    return result;
  }

  /// 拉取单题中文题面 HTML, 无内容时返回 null
  Future<String?> fetchStatement(String titleSlug) async {
    final data = await _post(_questionQuery, {'titleSlug': titleSlug});
    final question = data['question'];
    if (question is! Map) return null;
    final content = question['translatedContent'];
    if (content is! String || content.trim().isEmpty) return null;
    return content;
  }

  Future<Map<String, dynamic>> _post(
    String query,
    Map<String, dynamic> variables,
  ) async {
    http.Response response;
    try {
      response = await _client
          .post(
            endpoint,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'query': query, 'variables': variables}),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw const LeetCodeException('请求超时');
    } catch (e) {
      throw LeetCodeException('请求失败: $e');
    }

    if (response.statusCode != 200) {
      throw LeetCodeException('HTTP ${response.statusCode}');
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw LeetCodeException('响应不是合法 JSON: $e');
    }

    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw LeetCodeException('GraphQL 错误: ${errors.first}');
    }

    final data = decoded['data'];
    if (data is! Map) {
      throw const LeetCodeException('响应缺少 data');
    }
    return Map<String, dynamic>.from(data);
  }

  /// 释放内部创建的 http.Client
  void close() {
    if (_ownsClient) _client.close();
  }
}
