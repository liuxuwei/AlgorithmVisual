import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:algorithm_visual/algorithms/registry.dart';
import 'package:algorithm_visual/core/scene/input_schema.dart';
import 'package:algorithm_visual/main.dart';
import 'package:algorithm_visual/ui/algorithm_list_page.dart';
import 'package:algorithm_visual/ui/basic_algorithms_page.dart';
import 'package:algorithm_visual/ui/input_parsing.dart';
import 'package:algorithm_visual/ui/visualization_page.dart';

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

  Future<void> openBubbleSort(WidgetTester tester) async {
    await tester.pumpWidget(const AlgorithmVisualApp());
    await tapVisible(tester, '基础算法');
    await tapVisible(tester, '排序算法');
    await tapVisible(tester, '冒泡排序');
  }

  group('HomePage', () {
    testWidgets('展示热题 100 分组与基础算法入口', (tester) async {
      await tester.pumpWidget(const AlgorithmVisualApp());

      expect(find.text('算法可视化'), findsOneWidget);
      expect(find.text('热题 100'), findsOneWidget);
      expect(find.text('哈希'), findsOneWidget);
      expect(find.text('链表'), findsOneWidget);
      expect(find.text('基础算法'), findsOneWidget);
      expect(find.text('全部 100'), findsOneWidget);
    });

    testWidgets('难度筛选隐藏无匹配题目的专题', (tester) async {
      await tester.pumpWidget(const AlgorithmVisualApp());
      expect(find.text('哈希'), findsOneWidget);

      await tester.tap(find.textContaining('困难 '));
      await tester.pumpAndSettle();

      expect(find.text('哈希'), findsNothing);
      expect(find.text('链表'), findsOneWidget);
    });

    testWidgets('基础算法入口进入分类列表', (tester) async {
      await tester.pumpWidget(const AlgorithmVisualApp());
      await tapVisible(tester, '基础算法');

      expect(find.byType(BasicAlgorithmsPage), findsOneWidget);
      expect(find.text('排序算法'), findsOneWidget);
      expect(find.text('树遍历'), findsOneWidget);
      expect(find.text('2 个算法'), findsNWidgets(2));

      await tapVisible(tester, '排序算法');

      expect(find.byType(AlgorithmListPage), findsOneWidget);
      expect(find.text('冒泡排序'), findsOneWidget);
      expect(find.text('快速排序'), findsOneWidget);
    });
  });

  group('VisualizationPage', () {
    testWidgets('同时渲染可视化区、代码区与播放控制', (tester) async {
      await openBubbleSort(tester);

      expect(find.byType(VisualizationPage), findsOneWidget);
      expect(find.text('初始数组'), findsOneWidget);
      expect(find.text('void bubbleSort(List<int> arr) {'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
    });

    testWidgets('单步前进后帧说明同步更新', (tester) async {
      await openBubbleSort(tester);
      expect(find.text('初始数组'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pumpAndSettle();

      expect(find.text('比较 arr[0]=5 和 arr[1]=4'), findsOneWidget);
      expect(find.text('初始数组'), findsNothing);
    });

    testWidgets('后退一帧可回到上一状态', (tester) async {
      await openBubbleSort(tester);

      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.skip_previous));
      await tester.pumpAndSettle();

      expect(find.text('初始数组'), findsOneWidget);
    });

    testWidgets('切换预置用例会重置帧序列', (tester) async {
      await openBubbleSort(tester);

      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pumpAndSettle();
      expect(find.text('初始数组'), findsNothing);

      await tester.tap(find.text('已排序 [1,2,3,4,5]'));
      await tester.pumpAndSettle();

      expect(find.text('初始数组'), findsOneWidget);
    });

    testWidgets('快速排序页面渲染并可单步推进', (tester) async {
      await tester.pumpWidget(const AlgorithmVisualApp());
      await tapVisible(tester, '基础算法');
      await tapVisible(tester, '排序算法');
      await tapVisible(tester, '快速排序');

      expect(find.byType(VisualizationPage), findsOneWidget);
      expect(find.text('初始数组'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pumpAndSettle();

      expect(find.text('选择 pivot = arr[4] = 1 (区间 [0, 4])'), findsOneWidget);
    });

    testWidgets('点击自定义后展示输入表单与生成按钮', (tester) async {
      await openBubbleSort(tester);
      await tester.tap(find.text('自定义'));
      await tester.pumpAndSettle();

      expect(find.text('生成'), findsOneWidget);
      expect(find.text('输入数组, 逗号分隔: 1,2,3,4,5'), findsOneWidget);
    });

    testWidgets('自定义输入非法时给出提示', (tester) async {
      await openBubbleSort(tester);
      await tester.tap(find.text('自定义'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '1, abc, 3');
      await tapVisible(tester, '生成');

      expect(find.text('请输入有效数字, 用逗号分隔'), findsOneWidget);
    });
  });

  group('树遍历', () {
    testWidgets('DFS 页面渲染树并单步推进', (tester) async {
      await tester.pumpWidget(const AlgorithmVisualApp());
      await tapVisible(tester, '基础算法');
      await tapVisible(tester, '树遍历');

      expect(find.byType(AlgorithmListPage), findsOneWidget);
      expect(find.text('DFS 深度优先遍历'), findsOneWidget);
      expect(find.text('BFS 广度优先遍历'), findsOneWidget);

      await tester.tap(find.text('DFS 深度优先遍历'));
      await tester.pumpAndSettle();

      expect(find.byType(VisualizationPage), findsOneWidget);
      expect(find.textContaining('初始二叉树'), findsOneWidget);
      expect(find.text('void dfs(TreeNode? node) {'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pumpAndSettle();

      expect(find.text('访问节点 1'), findsOneWidget);
      expect(find.textContaining('初始二叉树'), findsNothing);
    });

    testWidgets('BFS 页面渲染并可单步推进', (tester) async {
      await tester.pumpWidget(const AlgorithmVisualApp());
      await tapVisible(tester, '基础算法');
      await tapVisible(tester, '树遍历');
      await tapVisible(tester, 'BFS 广度优先遍历');

      expect(find.byType(VisualizationPage), findsOneWidget);
      expect(find.textContaining('初始二叉树'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.skip_next));
      await tester.pumpAndSettle();

      expect(find.text('出队并访问节点 1'), findsOneWidget);
    });
  });

  group('parseInputField', () {
    test('数组: 空输入提示', () {
      final r = parseInputField(
        InputField.array('arr', maxLength: 50),
        '   ',
      );
      expect(r.value, isNull);
      expect(r.error, '请输入数组, 用逗号分隔');
    });

    test('数组: 非法字符提示', () {
      final r = parseInputField(
        InputField.array('arr', maxLength: 50),
        '1, abc, 3',
      );
      expect(r.value, isNull);
      expect(r.error, '请输入有效数字, 用逗号分隔');
    });

    test('数组: 超过最大长度提示', () {
      final tooMany = List.generate(51, (i) => '$i').join(',');
      final r = parseInputField(InputField.array('arr', maxLength: 50), tooMany);
      expect(r.value, isNull);
      expect(r.error, '超过最大长度 50');
    });

    test('数组: 合法输入解析成功', () {
      final r = parseInputField(InputField.array('arr', maxLength: 50), ' 3, 2, 1 ');
      expect(r.error, isNull);
      expect(r.value, [3, 2, 1]);
    });

    test('数组: 无长度限制时不校验长度', () {
      final r = parseInputField(InputField.array('arr'), '1,2,3');
      expect(r.error, isNull);
      expect(r.value, [1, 2, 3]);
    });

    test('整数: 非法与越界提示', () {
      expect(
        parseInputField(InputField.int('n', minValue: 1, maxValue: 10), '')
            .error,
        '请输入整数',
      );
      expect(
        parseInputField(InputField.int('n', minValue: 1, maxValue: 10), 'abc')
            .error,
        '请输入有效整数',
      );
      expect(
        parseInputField(InputField.int('n', minValue: 1, maxValue: 10), '11')
            .error,
        '超出范围 [1, 10]',
      );
      expect(
        parseInputField(InputField.int('n', minValue: 1, maxValue: 10), '9')
            .value,
        9,
      );
    });

    test('字符串: 空与超长提示', () {
      expect(
        parseInputField(InputField.string('s', maxLength: 3), '  ').error,
        '请输入内容',
      );
      expect(
        parseInputField(InputField.string('s', maxLength: 3), 'abcd').error,
        '超过最大长度 3',
      );
      expect(
        parseInputField(InputField.string('s', maxLength: 3), 'abc').value,
        'abc',
      );
    });

    test('矩阵: 非法、列数不一致与超限提示', () {
      final field = InputField.matrix('grid', maxRows: 2, maxCols: 2);
      expect(parseInputField(field, '').error, '请输入矩阵, 行用分号分隔');
      expect(parseInputField(field, '1,a;3,4').error, '请输入有效的整数矩阵');
      expect(parseInputField(field, '1,2;3').error, '每行元素数量必须一致');
      expect(parseInputField(field, '1,2;3,4;5,6').error, '超过最大行数 2');
      expect(parseInputField(field, '1,2,3;4,5,6').error, '超过最大列数 2');
      expect(parseInputField(field, '1,2;3,4').value, [
        [1, 2],
        [3, 4],
      ]);
    });
  });
}
