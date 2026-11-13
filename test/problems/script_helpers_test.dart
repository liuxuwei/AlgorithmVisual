import 'package:algorithm_visual/problems/script_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FrameCollector', () {
    test('帧号从 0 开始连续递增', () {
      final collector = FrameCollector();
      collector.add(caption: 'a', elements: const []);
      collector.add(caption: 'b', elements: const []);
      final frames = collector.build();
      expect(frames.map((f) => f.frameId), [0, 1]);
    });

    test('超过 maxFrames 立即抛 ArgumentError', () {
      final collector = FrameCollector(maxFrames: 1);
      collector.add(elements: const []);
      expect(() => collector.add(elements: const []), throwsArgumentError);
      expect(collector.length, 1);
    });
  });

  group('CodeLines', () {
    test('按标记定位 1-based 行号', () {
      final lines = CodeLines('int a = 1;\nint b = 2;\nreturn a + b;');
      expect(lines['int b'], 2);
      expect(lines['return a + b'], 3);
      expect(lines.lineCount, 3);
    });

    test('标记不存在时抛 ArgumentError', () {
      final lines = CodeLines('int a = 1;');
      expect(() => lines['missing'], throwsArgumentError);
    });
  });

  group('输入解析', () {
    test('intList 与 intOf', () {
      expect(intList([1, 2, 3]), [1, 2, 3]);
      expect(intList(null), isEmpty);
      expect(intOf(1), 1);
      expect(intOf(null, 7), 7);
    });

    test('intMatrix 复制为二维整数列表', () {
      final matrix = intMatrix([
        [1, 2],
        [3, 4],
      ]);
      expect(matrix, [
        [1, 2],
        [3, 4],
      ]);
    });

    test('splitWords 支持空格与逗号', () {
      expect(splitWords('a, b  c'), ['a', 'b', 'c']);
      expect(splitWords(''), isEmpty);
    });

    test('treeInput 把 -1 转换为 null', () {
      expect(treeInput([1, -1, 2]), [1, null, 2]);
    });

    test('gridOfChars 支持字符串与列表', () {
      expect(gridOfChars('110/011'), [
        ['1', '1', '0'],
        ['0', '1', '1'],
      ]);
      expect(gridOfChars(['ab', 'cd']), [
        ['a', 'b'],
        ['c', 'd'],
      ]);
    });

    test('livePointers 过滤空值', () {
      expect(livePointers({'a': 'x', 'b': null, 'c': ''}), {'a': 'x'});
    });
  });

  group('链表辅助', () {
    test('chain 按顺序连接节点', () {
      final nodes = chain([1, 2, 3], prefix: 'x');
      expect(nodes.map((n) => n.id), ['x0', 'x1', 'x2']);
      expect(nodes[0].nextId, 'x1');
      expect(nodes[1].nextId, 'x2');
      expect(nodes[2].nextId, isNull);
    });
  });
}
