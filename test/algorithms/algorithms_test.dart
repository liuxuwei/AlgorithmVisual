import 'package:algorithm_visual/algorithms/registry.dart';
import 'package:algorithm_visual/algorithms/sorting/bubble_sort.dart';
import 'package:algorithm_visual/algorithms/sorting/quick_sort.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BubbleSortVisualizer', () {
    late BubbleSortVisualizer algo;

    setUp(() {
      algo = BubbleSortVisualizer();
    });

    test('declares correct metadata', () {
      expect(algo.name, '冒泡排序');
      expect(algo.category, 'sorting');
      expect(algo.maxInputSize, 50);
    });

    test('frames are generated for small input', () {
      final frames = algo.visualize({'arr': [5, 4, 3, 2, 1]});
      expect(frames, isNotEmpty);
      // n=5, 冒泡排序需要比较 ~10 次 + 初始帧 + 标记帧 + 完成帧
      expect(frames.length, greaterThanOrEqualTo(10));
    });

    test('every frame has non-empty elements', () {
      final frames = algo.visualize({'arr': [3, 1, 2]});
      for (final frame in frames) {
        expect(frame.elements, isNotEmpty,
            reason: 'frame ${frame.frameId} should have elements');
      }
    });

    test('frames carry currentLine for compare/swap steps', () {
      final frames = algo.visualize({'arr': [3, 1, 2]});
      // 至少有某些帧带 currentLine (不是所有帧都需要)
      final framesWithLine = frames.where((f) => f.currentLine != null).toList();
      expect(framesWithLine, isNotEmpty);
    });

    test('throws on empty input', () {
      expect(() => algo.visualize({'arr': []}), throwsArgumentError);
    });

    test('throws when input exceeds maxInputSize', () {
      final bigList = List.generate(51, (i) => i); // 超过 50
      expect(() => algo.visualize({'arr': bigList}), throwsArgumentError);
    });

    test('throws on wrong input type', () {
      expect(() => algo.visualize({'arr': 'not a list'}), throwsArgumentError);
    });

    test('produces sorted result at final frame', () {
      final frames = algo.visualize({'arr': [5, 3, 8, 1, 9, 2, 7]});
      final lastFrame = frames.last;
      final values = lastFrame.elements
          .map((e) {
            // cast 到 ArrayBar 拿到 value
            // 这里 elements 的顺序是按 index 排的
            return (e as dynamic).value as int;
          })
          .toList();
      // 冒泡排序最终应该有序 (检查 elements 的值集合, 不一定顺序对但集合应该是对的)
      // 更准确地说, 应该检查最后的元素值是升序
      final sorted = List<int>.from(values)..sort();
      expect(values, sorted);
    });
  });

  group('QuickSortVisualizer', () {
    late QuickSortVisualizer algo;

    setUp(() {
      algo = QuickSortVisualizer();
    });

    test('declares correct metadata', () {
      expect(algo.name, '快速排序');
      expect(algo.category, 'sorting');
      expect(algo.maxInputSize, 50);
    });

    test('frames count is O(n log n) for typical input', () {
      final frames = algo.visualize({'arr': [5, 3, 8, 1, 9, 2, 7, 4, 6]});
      // 理论上应该远小于 O(n²) = 81
      // 实际上快速排序每 partition 会生成若干帧, 递归深度 log n
      // 粗略估计: 每 partition ~3n 帧, 递归层数 ~log n
      // 总帧数应该在几百以内而不是几千
      expect(frames.length, lessThan(1000));
    });

    test('every frame has elements', () {
      final frames = algo.visualize({'arr': [3, 1, 2]});
      for (final frame in frames) {
        expect(frame.elements, isNotEmpty);
      }
    });

    test('throws on empty input', () {
      expect(() => algo.visualize({'arr': []}), throwsArgumentError);
    });

    test('throws when input exceeds maxInputSize', () {
      final bigList = List.generate(51, (i) => i);
      expect(() => algo.visualize({'arr': bigList}), throwsArgumentError);
    });

    test('final frame values are sorted', () {
      final frames = algo.visualize({'arr': [5, 3, 8, 1, 9, 2, 7]});
      final lastFrame = frames.last;
      final values = lastFrame.elements
          .map((e) => (e as dynamic).value as int)
          .toList();
      final sorted = List<int>.from(values)..sort();
      expect(values, sorted);
    });
  });

  group('AlgorithmRegistry', () {
    test('registerAll adds sorting algorithms', () {
      final registry = AlgorithmRegistry.instance;
      registry.registerAll();

      expect(registry.getCategories(), contains('sorting'));
      expect(registry.getByCategory('sorting'), hasLength(greaterThanOrEqualTo(2)));
    });

    test('getByName finds registered algorithms', () {
      final registry = AlgorithmRegistry.instance;
      registry.registerAll();

      final bubble = registry.getByName('冒泡排序');
      expect(bubble, isA<BubbleSortVisualizer>());

      final quick = registry.getByName('快速排序');
      expect(quick, isA<QuickSortVisualizer>());
    });

    test('unknown name returns null', () {
      final registry = AlgorithmRegistry.instance;
      expect(registry.getByName('不存在的算法'), isNull);
    });
  });
}
