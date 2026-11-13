import '../base.dart';
import '../../core/scene/scene_frame.dart';
import '../../core/scene/element.dart';
import '../../core/scene/action.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/point.dart';

/// 冒泡排序可视化
class BubbleSortVisualizer implements AlgorithmVisualizer {
  @override
  String get name => '冒泡排序';

  @override
  String get category => 'sorting';

  @override
  String get description =>
      '重复遍历数组, 比较相邻元素, 将大的往后冒泡。平均时间复杂度 O(n²)。';

  @override
  int get maxInputSize => 50;

  @override
  InputSchema get inputSchema => InputSchema(
        fields: [InputField.array('arr', maxLength: maxInputSize, label: '数组')],
      );

  /// 冒泡排序代码 (用于 currentLine 映射)
  /// ```dart
  /// void bubbleSort(List<int> arr) {          // 1
  ///   final n = arr.length;                   // 2
  ///   for (int i = 0; i < n - 1; i++) {       // 3
  ///     for (int j = 0; j < n - i - 1; j++) { // 4
  ///       if (arr[j] > arr[j + 1]) {          // 5
  ///         final temp = arr[j];              // 6
  ///         arr[j] = arr[j + 1];              // 7
  ///         arr[j + 1] = temp;                // 8
  ///       }
  ///     }
  ///   }
  /// }
  /// ```
  static const int _lineCompare = 5; // if (arr[j] > arr[j+1])
  static const int _lineSwapStart = 6; // final temp = arr[j];
  static const int _lineSwapEnd = 8; // arr[j+1] = temp;

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

    // 辅助: 根据当前 arr 状态构建完整元素列表
    List<Element> buildElements({Set<int>? sortedIndices}) {
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

    // 标记已排序的索引
    final sortedSet = <int>{};

    for (var i = 0; i < n - 1; i++) {
      for (var j = 0; j < n - i - 1; j++) {
        // 比较帧
        frames.add(SceneFrame(
          frameId: frameId++,
          caption: '比较 arr[$j]=${arr[j]} 和 arr[${j + 1}]=${arr[j + 1]}',
          elements: buildElements(sortedIndices: sortedSet),
          actions: [
            Highlight(targetId: 'bar_$j'),
            Highlight(targetId: 'bar_${j + 1}'),
          ],
          currentLine: _lineCompare,
          activeLines: const [_lineCompare],
        ));

        if (arr[j] > arr[j + 1]) {
          // 执行交换
          final temp = arr[j];
          arr[j] = arr[j + 1];
          arr[j + 1] = temp;

          // 交换帧
          frames.add(SceneFrame(
            frameId: frameId++,
            caption: '交换 arr[$j] 和 arr[${j + 1}]',
            elements: buildElements(sortedIndices: sortedSet),
            actions: [
              Swap(targetId: 'bar_$j', otherId: 'bar_${j + 1}'),
            ],
            currentLine: _lineSwapEnd,
            activeLines: const [_lineSwapStart, _lineSwapEnd],
          ));
        }
      }
      // 本轮末尾元素标记为已排序
      sortedSet.add(n - i - 1);
      frames.add(SceneFrame(
        frameId: frameId++,
        caption: 'arr[${n - i - 1}]=${arr[n - i - 1]} 已就位',
        elements: buildElements(sortedIndices: sortedSet),
        actions: [Mark(targetId: 'bar_${n - i - 1}', state: 'sorted')],
        currentLine: null,
      ));
    }

    // 最后一个元素也标记
    sortedSet.add(0);
    frames.add(SceneFrame(
      frameId: frameId++,
      caption: '排序完成',
      elements: buildElements(sortedIndices: sortedSet),
      actions: [Mark(targetId: 'bar_0', state: 'sorted')],
      currentLine: null,
    ));

    return frames;
  }
}
