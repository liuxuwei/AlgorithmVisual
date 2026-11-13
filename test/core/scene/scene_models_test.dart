import 'package:algorithm_visual/core/scene/action.dart';
import 'package:algorithm_visual/core/scene/element.dart';
import 'package:algorithm_visual/core/scene/input_schema.dart';
import 'package:algorithm_visual/core/scene/point.dart';
import 'package:algorithm_visual/core/scene/scene_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Point', () {
    test('constructs with x, y', () {
      const p = Point(3.5, 4.2);
      expect(p.x, 3.5);
      expect(p.y, 4.2);
    });

    test('copyWith works', () {
      const p = Point(1, 2);
      final p2 = p.copyWith(x: 10);
      expect(p2.x, 10);
      expect(p2.y, 2);
    });
  });

  group('Element', () {
    test('ArrayBar has correct fields', () {
      const bar = ArrayBar(
        id: 'bar_0',
        position: Point(0, 0),
        value: 42,
        index: 0,
      );
      expect(bar.id, 'bar_0');
      expect(bar.value, 42);
      expect(bar.index, 0);
      expect(bar.position.x, 0);
    });

    test('DpCell has row/col', () {
      const cell = DpCell(
        id: 'dp_1_2',
        position: Point(20, 30),
        row: 1,
        col: 2,
        value: 5,
      );
      expect(cell.row, 1);
      expect(cell.col, 2);
      expect(cell.value, 5);
    });

    test('TreeNode has left/right ids', () {
      const node = TreeNode(
        id: 'n_1',
        position: Point(10, 20),
        data: 'A',
        leftId: 'n_2',
        rightId: 'n_3',
      );
      expect(node.leftId, 'n_2');
      expect(node.rightId, 'n_3');
    });

    test('sealed type switch compiles exhaustively', () {
      void handle(Element e) {
        switch (e) {
          case ArrayBar():
          case TreeNode():
          case GraphNode():
          case DpCell():
          case LinkedListNode():
          case MatrixCell():
          case StackFrame():
          case HashEntry():
          case PointerMarker():
            // all covered
        }
      }

      const bar = ArrayBar(id: 'a', position: Point(0, 0), value: 1, index: 0);
      handle(bar); // should compile without missing case warning
    });
  });

  group('Action', () {
    test('Swap has otherId', () {
      const swap = Swap(targetId: 'a', otherId: 'b');
      expect(swap.targetId, 'a');
      expect(swap.otherId, 'b');
    });

    test('Mark has state', () {
      const mark = Mark(targetId: 'n_1', state: 'sorted');
      expect(mark.state, 'sorted');
    });

    test('Highlight defaults to true', () {
      const h = Highlight(targetId: 'x');
      expect(h.isHighlighted, isTrue);
    });
  });

  group('SceneFrame', () {
    test('constructs with all fields', () {
      final frame = SceneFrame(
        frameId: 3,
        caption: '交换 a, b',
        elements: const [],
        actions: const [],
        currentLine: 5,
        activeLines: const [5, 6],
      );
      expect(frame.frameId, 3);
      expect(frame.caption, '交换 a, b');
      expect(frame.currentLine, 5);
      expect(frame.activeLines, [5, 6]);
    });

    test('optional fields default to null/empty', () {
      final frame = SceneFrame(frameId: 0, elements: const []);
      expect(frame.currentLine, isNull);
      expect(frame.activeLines, isNull);
      expect(frame.actions, isEmpty);
    });

    test('copyWith updates specified fields', () {
      final original = SceneFrame(
        frameId: 1,
        caption: 'a',
        elements: const [],
      );
      final updated = original.copyWith(frameId: 2, caption: 'b');
      expect(updated.frameId, 2);
      expect(updated.caption, 'b');
      expect(updated.elements, original.elements);
    });
  });

  group('InputSchema', () {
    test('describes bubble sort input', () {
      final schema = InputSchema(
        fields: [InputField.array('arr', maxLength: 50, label: '数组')],
      );
      final field = schema.findField('arr');
      expect(field, isNotNull);
      expect(field!.type, InputFieldType.array);
      expect(field.maxLength, 50);
    });

    test('describes knapsack input (多字段)', () {
      final schema = InputSchema(
        fields: [
          InputField.array('weights', maxLength: 30),
          InputField.array('values', maxLength: 30),
          InputField.int('capacity', minValue: 1, maxValue: 1000),
        ],
      );
      expect(schema.fields.length, 3);
      expect(schema.findField('weights'), isNotNull);
      expect(schema.findField('capacity')!.type, InputFieldType.int);
    });
  });
}
