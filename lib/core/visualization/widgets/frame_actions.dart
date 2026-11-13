import '../../scene/action.dart';
import '../../scene/element.dart';
import '../../scene/scene_frame.dart';

/// 一帧中的区间标注 (e.g. 滑动窗口)
class RangeSpan {
  final String label;
  final String startId;
  final String endId;

  const RangeSpan({
    required this.label,
    required this.startId,
    required this.endId,
  });
}

/// 从帧中统一提取指针 / 区间 / 着色标注, 供各渲染器复用
class FrameActions {
  final Map<String, List<String>> pointers = {};
  final List<RangeSpan> ranges = [];
  final Set<String> highlighted = {};
  final Set<String> visited = {};
  final Set<String> computed = {};
  final Set<String> pivots = {};
  final Set<String> sorted = {};
  final Set<String> swapped = {};

  FrameActions._();

  factory FrameActions.of(SceneFrame frame) {
    final result = FrameActions._();

    for (final marker in frame.elements.whereType<PointerMarker>()) {
      result.pointers.putIfAbsent(marker.targetId, () => []).add(marker.label);
    }

    for (final action in frame.actions) {
      switch (action) {
        case Pointer(targetId: final id, :final label):
          result.pointers.putIfAbsent(id, () => []).add(label);
        case Range(
            targetId: _,
            :final label,
            :final startId,
            :final endId,
          ):
          result.ranges.add(
            RangeSpan(label: label, startId: startId, endId: endId),
          );
        case Highlight(targetId: final id, :final isHighlighted)
            when isHighlighted:
          result.highlighted.add(id);
        case Mark(targetId: final id, state: final state):
          switch (state) {
            case 'visited':
              result.visited.add(id);
            case 'computed':
              result.computed.add(id);
            case 'pivot':
              result.pivots.add(id);
            case 'sorted':
              result.sorted.add(id);
          }
        case Swap(targetId: final a, :final otherId):
          result.swapped.addAll([a, otherId]);
        default:
          break;
      }
    }
    return result;
  }

  List<String> labelsFor(String id) => pointers[id] ?? const [];

  /// 按元素在有序列表中的下标判断是否落在任一区间内
  bool inRangeAt(int index, Map<String, int> idToIndex) {
    for (final span in ranges) {
      final start = idToIndex[span.startId];
      final end = idToIndex[span.endId];
      if (start == null || end == null) continue;
      final lo = start <= end ? start : end;
      final hi = start <= end ? end : start;
      if (index >= lo && index <= hi) return true;
    }
    return false;
  }
}
