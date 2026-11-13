import 'package:algorithm_visual/core/scene/action.dart';
import 'package:algorithm_visual/core/scene/element.dart';
import 'package:algorithm_visual/core/scene/point.dart';
import 'package:algorithm_visual/core/scene/scene_frame.dart';
import 'package:algorithm_visual/core/visualization/scene_renderer.dart';
import 'package:algorithm_visual/core/visualization/widgets/array_bar.dart';
import 'package:algorithm_visual/core/visualization/widgets/hash_bucket.dart';
import 'package:algorithm_visual/core/visualization/widgets/linked_list_view.dart';
import 'package:algorithm_visual/core/visualization/widgets/matrix_grid.dart';
import 'package:algorithm_visual/core/visualization/widgets/stack_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget _host(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 600, height: 320, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('ArrayBarView 渲染数值、指针与窗口', (tester) async {
    const frame = SceneFrame(
      frameId: 0,
      elements: [
        ArrayBar(id: 'bar_0', position: Point(0, 0), value: 3, index: 0),
        ArrayBar(id: 'bar_1', position: Point(1, 0), value: 8, index: 1),
        ArrayBar(id: 'bar_2', position: Point(2, 0), value: 5, index: 2),
        PointerMarker(id: 'p_left', label: 'left', targetId: 'bar_0'),
      ],
      actions: [
        Pointer(targetId: 'bar_2', label: 'right'),
        Range(targetId: 'bar_0', label: '窗口', startId: 'bar_0', endId: 'bar_2'),
      ],
    );

    await tester.pumpWidget(_host(const ArrayBarView(
      frame: frame,
      height: 320,
      width: 600,
    )));

    expect(find.text('3'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('left'), findsOneWidget);
    expect(find.text('right'), findsOneWidget);
  });

  testWidgets('LinkedListView 按 next 关系渲染节点与空指针', (tester) async {
    const frame = SceneFrame(
      frameId: 0,
      elements: [
        LinkedListNode(
          id: 'n1',
          position: Point(0, 0),
          data: 1,
          nextId: 'n2',
        ),
        LinkedListNode(
          id: 'n2',
          position: Point(1, 0),
          data: 2,
          nextId: 'n3',
        ),
        LinkedListNode(id: 'n3', position: Point(2, 0), data: 3),
        PointerMarker(id: 'p_cur', label: 'cur', targetId: 'n2'),
      ],
      actions: [
        Mark(targetId: 'n1', state: 'visited'),
      ],
    );

    await tester.pumpWidget(_host(const LinkedListView(
      frame: frame,
      height: 320,
      width: 600,
    )));

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('cur'), findsOneWidget);
    expect(find.text('∅'), findsOneWidget);
  });

  testWidgets('LinkedListView 支持环形链表', (tester) async {
    const frame = SceneFrame(
      frameId: 0,
      elements: [
        LinkedListNode(id: 'a', position: Point(0, 0), data: 10, nextId: 'b'),
        LinkedListNode(id: 'b', position: Point(1, 0), data: 20, nextId: 'c'),
        LinkedListNode(id: 'c', position: Point(2, 0), data: 30, nextId: 'a'),
      ],
    );

    await tester.pumpWidget(_host(const LinkedListView(
      frame: frame,
      height: 320,
      width: 600,
    )));

    expect(find.text('10'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MatrixGridView 渲染行列与指针', (tester) async {
    const frame = SceneFrame(
      frameId: 0,
      elements: [
        MatrixCell(id: 'm00', position: Point(0, 0), row: 0, col: 0, value: 'A'),
        MatrixCell(id: 'm01', position: Point(0, 1), row: 0, col: 1, value: 'B'),
        MatrixCell(
          id: 'm10',
          position: Point(1, 0),
          row: 1,
          col: 0,
          value: 'C',
          state: 'visited',
        ),
        MatrixCell(id: 'm11', position: Point(1, 1), row: 1, col: 1, value: 'D'),
      ],
      actions: [
        Pointer(targetId: 'm11', label: 'i,j'),
      ],
    );

    await tester.pumpWidget(_host(const MatrixGridView(frame: frame)));

    expect(find.text('A'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('i,j'), findsOneWidget);
  });

  testWidgets('StackView 自底向上渲染栈元素', (tester) async {
    const frame = SceneFrame(
      frameId: 0,
      elements: [
        StackFrame(id: 's0', position: Point(0, 0), index: 0, value: '('),
        StackFrame(id: 's1', position: Point(0, 1), index: 1, value: '['),
        StackFrame(id: 's2', position: Point(0, 2), index: 2, value: ']'),
      ],
      actions: [
        Highlight(targetId: 's2'),
      ],
    );

    await tester.pumpWidget(_host(const StackView(frame: frame)));

    expect(find.text('栈顶'), findsOneWidget);
    expect(find.text('('), findsOneWidget);
    expect(find.text(']'), findsOneWidget);
  });

  testWidgets('HashBucketView 按桶分组展示键值', (tester) async {
    const frame = SceneFrame(
      frameId: 0,
      elements: [
        HashEntry(
          id: 'h1',
          position: Point(0, 0),
          key: 'aet',
          value: ['eat', 'tea'],
          bucket: 1,
        ),
        HashEntry(
          id: 'h2',
          position: Point(0, 1),
          key: 'ant',
          value: ['tan'],
          bucket: 2,
        ),
      ],
    );

    await tester.pumpWidget(_host(const HashBucketView(frame: frame)));

    expect(find.textContaining('aet → [eat, tea]'), findsOneWidget);
    expect(find.textContaining('ant → [tan]'), findsOneWidget);
    expect(find.text('桶 1'), findsOneWidget);
    expect(find.text('桶 2'), findsOneWidget);
  });

  testWidgets('SceneRenderer 按主元素类型分发到链表渲染器', (tester) async {
    const frame = SceneFrame(
      frameId: 0,
      elements: [
        LinkedListNode(id: 'n1', position: Point(0, 0), data: 7),
        PointerMarker(id: 'p', label: 'head', targetId: 'n1'),
      ],
    );

    await tester.pumpWidget(_host(const SceneRenderer(frame: frame)));

    expect(find.byType(LinkedListView), findsOneWidget);
    expect(find.text('head'), findsOneWidget);
  });
}
