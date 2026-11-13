import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'package:algorithm_visual/algorithms/registry.dart';
import 'package:algorithm_visual/catalog/leetcode_client.dart';
import 'package:algorithm_visual/catalog/problem_entry.dart';
import 'package:algorithm_visual/catalog/problem_repository.dart';
import 'package:algorithm_visual/core/scene/element.dart';
import 'package:algorithm_visual/core/scene/input_schema.dart';
import 'package:algorithm_visual/core/scene/point.dart';
import 'package:algorithm_visual/core/scene/scene_frame.dart';
import 'package:algorithm_visual/core/visualization/scene_renderer.dart';
import 'package:algorithm_visual/main.dart';
import 'package:algorithm_visual/problems/problem_data.dart';
import 'package:algorithm_visual/ui/problem_list_page.dart';
import 'package:algorithm_visual/ui/visualization_page.dart';

import '../catalog/fake_http.dart';

class _AssetSnapshot implements SnapshotSource {
  const _AssetSnapshot();

  @override
  Future<String?> load() async =>
      File('assets/problem_catalog.json').readAsStringSync();
}

ProblemRepository _buildRepository({http.BaseClient? client}) {
  return ProblemRepository(
    localProblems: allProblems(),
    client: LeetCodeClient(
      client: client ?? FakeHttpClient((_) async => throw Exception('offline')),
    ),
    store: MemoryKeyValueStore(),
    snapshot: const _AssetSnapshot(),
  );
}

ProblemEntry _fakeProblem() {
  return ProblemEntry(
    titleSlug: 'fake-input',
    number: 999,
    title: '自定义输入测试',
    difficulty: ProblemDifficulty.medium,
    groupSlug: 'array',
    patternId: 'array-basic',
    code: 'void solve(String text, int[][] grid) { }',
    presets: const [
      ProblemPreset(
        label: '示例',
        input: {
          'text': 'abc',
          'grid': [
            [1, 2],
            [3, 4],
          ],
        },
      ),
    ],
    inputSchema: InputSchema(fields: [
      InputField.string('text', maxLength: 3, label: '字符串 text'),
      InputField.matrix('grid', maxRows: 2, maxCols: 2, label: '矩阵 grid'),
    ]),
    maxInputSize: 20,
    maxFrames: 10,
    script: (input) => const [
      SceneFrame(
        frameId: 0,
        caption: '初始帧',
        elements: [
          ArrayBar(id: 'bar_0', position: Point(0, 0), value: 1, index: 0),
        ],
      ),
    ],
  );
}

void main() {
  setUpAll(() {
    AlgorithmRegistry.instance.registerAll();
  });

  Future<void> tapVisible(WidgetTester tester, String text) async {
    final finder = find.text(text);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('点击专题进入题目列表并展示题号与难度', (tester) async {
    await tester.pumpWidget(const AlgorithmVisualApp());
    await tapVisible(tester, '哈希');

    expect(find.byType(ProblemListPage), findsOneWidget);
    expect(find.text('两数之和'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('简单'), findsWidgets);

    await tester.tap(find.text('两数之和'));
    await tester.pumpAndSettle();

    expect(find.byType(VisualizationPage), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('初始化哈希表 seen = {}'), findsOneWidget);
    expect(find.text('class Solution {'), findsOneWidget);
  });

  testWidgets('展开题面卡片显示中文题面且可视化仍可见', (tester) async {
    final repository = _buildRepository();
    addTearDown(repository.dispose);
    await repository.load();

    await tester.pumpWidget(AlgorithmVisualApp(repository: repository));
    await tester.pumpAndSettle();

    await tapVisible(tester, '哈希');
    await tester.tap(find.text('两数之和'));
    await tester.pumpAndSettle();

    expect(find.byType(VisualizationPage), findsOneWidget);
    // 默认收起: 不展示题面正文
    expect(find.textContaining('给定一个整数数组', findRichText: true), findsNothing);

    await tester.tap(find.text('题目描述'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('给定一个整数数组', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(SceneRenderer), findsOneWidget);
  });

  testWidgets('自定义输入按字段类型校验字符串与矩阵', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: VisualizationPage(problem: _fakeProblem())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('自定义'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'abcd');
    await tapVisible(tester, '生成');
    expect(find.text('超过最大长度 3'), findsOneWidget);

    await tester.enterText(fields.at(0), 'abc');
    await tester.enterText(fields.at(1), '1,2;3');
    await tapVisible(tester, '生成');
    expect(find.text('每行元素数量必须一致'), findsOneWidget);

    await tester.enterText(fields.at(1), '1,2;3,4');
    await tapVisible(tester, '生成');

    expect(find.text('初始帧'), findsOneWidget);
  });

  testWidgets('离线题库展示标识, 首页与播放页均可见', (tester) async {
    final repository = _buildRepository();
    addTearDown(repository.dispose);
    await repository.load();

    await tester.pumpWidget(AlgorithmVisualApp(repository: repository));
    await tester.pumpAndSettle();
    expect(find.text('当前使用离线题库'), findsOneWidget);

    await tapVisible(tester, '哈希');
    await tester.tap(find.text('两数之和'));
    await tester.pumpAndSettle();

    expect(find.byType(VisualizationPage), findsOneWidget);
    expect(find.text('当前使用离线题库'), findsOneWidget);
  });

  testWidgets('重试成功后离线标识消失', (tester) async {
    var calls = 0;
    final fallback = snapshotBackedClient();
    final client = FakeHttpClient((request) async {
      calls++;
      if (calls == 1) throw Exception('offline');
      return fallback.handler(request);
    });
    final repository = _buildRepository(client: client);
    addTearDown(repository.dispose);
    await repository.load();

    await tester.pumpWidget(AlgorithmVisualApp(repository: repository));
    await tester.pumpAndSettle();
    expect(find.text('当前使用离线题库'), findsOneWidget);

    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(find.text('当前使用离线题库'), findsNothing);
  });
}
