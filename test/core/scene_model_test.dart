import 'package:algorithm_visual/core/scene/action.dart';
import 'package:algorithm_visual/core/scene/element.dart';
import 'package:algorithm_visual/core/scene/point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('新增 Element 类型', () {
    test('LinkedListNode 可读取 next/prev/random 关系', () {
      const node = LinkedListNode(
        id: 'n1',
        position: Point(0, 0),
        data: 7,
        nextId: 'n2',
        prevId: 'n0',
        randomId: 'n2',
      );
      expect(node.id, 'n1');
      expect(node.data, 7);
      expect(node.nextId, 'n2');
      expect(node.prevId, 'n0');
      expect(node.randomId, 'n2');
    });

    test('MatrixCell 可读取行列与状态', () {
      const cell = MatrixCell(
        id: 'm_1_2',
        position: Point(1, 2),
        row: 1,
        col: 2,
        value: 3,
        state: 'visited',
      );
      expect(cell.row, 1);
      expect(cell.col, 2);
      expect(cell.value, 3);
      expect(cell.state, 'visited');
      expect(cell.position.x, 1);
    });

    test('StackFrame 可读取下标与值', () {
      const frame = StackFrame(
        id: 's_0',
        position: Point(0, 0),
        index: 0,
        value: '(',
      );
      expect(frame.index, 0);
      expect(frame.value, '(');
    });

    test('HashEntry 可读取桶号与键值', () {
      const entry = HashEntry(
        id: 'h_0',
        position: Point(0, 0),
        key: 'aet',
        value: ['eat', 'tea'],
        bucket: 2,
      );
      expect(entry.bucket, 2);
      expect(entry.key, 'aet');
      expect(entry.value, ['eat', 'tea']);
    });

    test('PointerMarker 指向目标元素并带标签', () {
      const marker = PointerMarker(id: 'p_left', label: 'left', targetId: 'bar_2');
      expect(marker.label, 'left');
      expect(marker.targetId, 'bar_2');
      expect(marker.position.x, 0);
      expect(marker.position.y, 0);
    });

    test('同一帧内 Element id 唯一', () {
      final elements = <Element>[
        const ArrayBar(id: 'e', position: Point(0, 0), value: 1, index: 0),
        const MatrixCell(id: 'e2', position: Point(0, 1), row: 0, col: 1),
        const StackFrame(id: 'e3', position: Point(0, 2), index: 0, value: 1),
      ];
      final ids = elements.map((e) => e.id).toSet();
      expect(ids.length, elements.length);
    });

    test('sealed 类型 switch 可穷尽全部分支', () {
      String describe(Element e) {
        switch (e) {
          case ArrayBar():
            return 'array';
          case TreeNode():
            return 'tree';
          case GraphNode():
            return 'graph';
          case DpCell():
            return 'dp';
          case LinkedListNode():
            return 'list';
          case MatrixCell():
            return 'matrix';
          case StackFrame():
            return 'stack';
          case HashEntry():
            return 'hash';
          case PointerMarker():
            return 'pointer';
        }
      }

      expect(
        describe(const ArrayBar(id: 'a', position: Point(0, 0), value: 1, index: 0)),
        'array',
      );
      expect(
        describe(const MatrixCell(id: 'm', position: Point(0, 0), row: 0, col: 0)),
        'matrix',
      );
      expect(describe(const PointerMarker(id: 'p', label: 'i', targetId: 'm')), 'pointer');
    });
  });

  group('新增 Action 类型', () {
    test('Pointer 带标签与目标', () {
      const p = Pointer(targetId: 'bar_3', label: 'left');
      expect(p.targetId, 'bar_3');
      expect(p.label, 'left');
    });

    test('Range 带起止与标签', () {
      const r = Range(
        targetId: 'bar_1',
        label: '窗口',
        startId: 'bar_1',
        endId: 'bar_4',
      );
      expect(r.label, '窗口');
      expect(r.startId, 'bar_1');
      expect(r.endId, 'bar_4');
    });
  });
}
