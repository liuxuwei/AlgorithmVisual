import '../base.dart';
import '../../core/scene/scene_frame.dart';
import '../../core/scene/element.dart';
import '../../core/scene/action.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/point.dart';

/// 快速排序可视化
class QuickSortVisualizer implements AlgorithmVisualizer {
  @override
  String get name => '快速排序';

  @override
  String get category => 'sorting';

  @override
  String get description =>
      '选择基准值 pivot, 将数组分区为小于和大于 pivot 的两部分, 递归排序。平均时间复杂度 O(n log n)。';

  @override
  int get maxInputSize => 50;

  @override
  InputSchema get inputSchema => InputSchema(
        fields: [InputField.array('arr', maxLength: maxInputSize, label: '数组')],
      );

  // 代码行号映射 (对应下方 visualize 中的注释)
  static const int _linePivotSelect = 8; // pivot = arr[high]
  static const int _lineCompare = 12; // arr[j] < pivot
  static const int _lineSwap = 16; // swap

  @override
  List<SceneFrame> visualize(Map<String, dynamic> input) {
    final raw = input['arr'];
    if (raw is! List<int>) {
      throw ArgumentError('arr must be List<int>, got ${raw.runtimeType}');
    }
    if (raw.isEmpty) {
      throw ArgumentError('arr must not be empty');
    }
    if (raw.length > maxInputSize) {
      throw ArgumentError(
          'arr length ${raw.length} exceeds maxInputSize $maxInputSize');
    }

    final arr = List<int>.from(raw);
    final n = arr.length;
    final frames = <SceneFrame>[];
    var frameId = 0;
    final sortedSet = <int>{};

    List<Element> buildElements({
      int? pivotIndex,
      Set<int>? sorted,
      int? low,
      int? high,
    }) {
      final elements = <Element>[];
      for (var i = 0; i < n; i++) {
        elements.add(ArrayBar(
          id: 'bar_$i',
          position: Point(i.toDouble(), 0),
          value: arr[i],
          index: i,
        ));
      }
      return elements;
    }

    // 初始帧
    frames.add(SceneFrame(
      frameId: frameId++,
      caption: '初始数组',
      elements: buildElements(),
      currentLine: null,
    ));

    // 手动管理递归调用栈: 存储待排序的 [low, high] 区间
    final stack = <List<int>>[[0, n - 1]];

    while (stack.isNotEmpty) {
      final range = stack.removeLast();
      final low = range[0];
      final high = range[1];

      if (low >= high) {
        if (low == high) {
          sortedSet.add(low);
          frames.add(SceneFrame(
            frameId: frameId++,
            caption: 'arr[$low]=${arr[low]} 已就位',
            elements: buildElements(sorted: sortedSet),
            actions: [Mark(targetId: 'bar_$low', state: 'sorted')],
          ));
        }
        continue;
      }

      // 选择 pivot = arr[high]
      final pivotIndex = high;
      final pivot = arr[pivotIndex];

      frames.add(SceneFrame(
        frameId: frameId++,
        caption: '选择 pivot = arr[$pivotIndex] = $pivot (区间 [$low, $high])',
        elements: buildElements(pivotIndex: pivotIndex, sorted: sortedSet),
        actions: [Mark(targetId: 'bar_$pivotIndex', state: 'pivot')],
        currentLine: _linePivotSelect,
      ));

      // Lomuto partition
      var i = low - 1;
      for (var j = low; j < high; j++) {
        // 比较 arr[j] 和 pivot
        frames.add(SceneFrame(
          frameId: frameId++,
          caption: '比较 arr[$j]=${arr[j]} 和 pivot=$pivot',
          elements: buildElements(pivotIndex: pivotIndex, sorted: sortedSet),
          actions: [
            Highlight(targetId: 'bar_$j'),
            Highlight(targetId: 'bar_$pivotIndex'),
          ],
          currentLine: _lineCompare,
        ));

        if (arr[j] < pivot) {
          i++;
          if (i != j) {
            // 交换 arr[i] 和 arr[j]
            final temp = arr[i];
            arr[i] = arr[j];
            arr[j] = temp;

            frames.add(SceneFrame(
              frameId: frameId++,
              caption: 'arr[$j] < pivot, 交换 arr[$i] 和 arr[$j]',
              elements: buildElements(pivotIndex: pivotIndex, sorted: sortedSet),
              actions: [
                Swap(targetId: 'bar_$i', otherId: 'bar_$j'),
              ],
              currentLine: _lineSwap,
            ));
          }
        }
      }

      // 把 pivot 放到正确位置
      final pivotFinal = i + 1;
      if (pivotFinal != pivotIndex) {
        final temp = arr[pivotFinal];
        arr[pivotFinal] = arr[pivotIndex];
        arr[pivotIndex] = temp;

        frames.add(SceneFrame(
          frameId: frameId++,
          caption: 'pivot 归位: 交换 arr[$pivotFinal] 和 arr[$pivotIndex]',
          elements: buildElements(pivotIndex: pivotFinal, sorted: sortedSet),
          actions: [
            Swap(targetId: 'bar_$pivotFinal', otherId: 'bar_$pivotIndex'),
          ],
        ));
      }

      sortedSet.add(pivotFinal);
      frames.add(SceneFrame(
        frameId: frameId++,
        caption: 'arr[$pivotFinal]=$pivot 已就位',
        elements: buildElements(sorted: sortedSet),
        actions: [Mark(targetId: 'bar_$pivotFinal', state: 'sorted')],
      ));

      // 将左右子区间压栈 (先压右边, 保证左边先处理, 和递归顺序一致)
      stack.add([pivotFinal + 1, high]);
      stack.add([low, pivotFinal - 1]);
    }

    // 最终完成帧
    frames.add(SceneFrame(
      frameId: frameId++,
      caption: '排序完成',
      elements: buildElements(sorted: Set.from(List.generate(n, (i) => i))),
    ));

    return frames;
  }
}
