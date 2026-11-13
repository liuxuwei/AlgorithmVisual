import 'package:material_ui/material_ui.dart';

import '../../scene/element.dart';
import '../../scene/scene_frame.dart';
import 'frame_actions.dart';

/// 数组柱状图 Widget
///
/// 支持高亮 / pivot / sorted 着色, 以及指针标签与区间窗口叠加。
class ArrayBarView extends StatelessWidget {
  final SceneFrame frame;
  final double height;
  final double width;

  const ArrayBarView({
    super.key,
    required this.frame,
    required this.height,
    required this.width,
  });

  static const List<Color> _pointerColors = [
    Color(0xFF2E7D32),
    Color(0xFF1565C0),
    Color(0xFFEF6C00),
    Color(0xFF6A1B9A),
  ];

  @override
  Widget build(BuildContext context) {
    final actions = FrameActions.of(frame);
    final bars = frame.elements.whereType<ArrayBar>().toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    final idToIndex = <String, int>{
      for (var i = 0; i < bars.length; i++) bars[i].id: i,
    };
    final maxValue = bars.fold<int>(
      0,
      (prev, bar) => bar.value > prev ? bar.value : prev,
    );
    final maxLabels = ((height - 24) / 18).floor().clamp(0, 8);
    final labelCount = bars.fold<int>(
      0,
      (prev, bar) {
        final count = actions.labelsFor(bar.id).length;
        final capped = count > maxLabels ? maxLabels : count;
        return capped > prev ? capped : prev;
      },
    );
    final labelHeight = labelCount == 0
        ? 0.0
        : (labelCount * 16.0).clamp(0.0, height * 0.35);
    final chartHeight = (height - labelHeight - 24).clamp(0.0, height);
    final minBarHeight = chartHeight < 12.0 ? chartHeight : 12.0;
    final barWidth = width / bars.length;

    return SizedBox(
      height: height,
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++)
            _buildColumn(
              bar: bars[i],
              index: i,
              actions: actions,
              idToIndex: idToIndex,
              maxValue: maxValue,
              barWidth: barWidth,
              chartHeight: chartHeight,
              minBarHeight: minBarHeight,
              maxLabels: maxLabels,
            ),
        ],
      ),
    );
  }

  Widget _buildColumn({
    required ArrayBar bar,
    required int index,
    required FrameActions actions,
    required Map<String, int> idToIndex,
    required int maxValue,
    required double barWidth,
    required double chartHeight,
    required double minBarHeight,
    required int maxLabels,
  }) {
    final isHighlighted = actions.highlighted.contains(bar.id);
    final isPivot = actions.pivots.contains(bar.id);
    final isSorted = actions.sorted.contains(bar.id);
    final inRange = actions.inRangeAt(index, idToIndex);

    Color color;
    if (isPivot) {
      color = Colors.orange;
    } else if (isSorted) {
      color = Colors.green;
    } else if (isHighlighted) {
      color = Colors.red;
    } else {
      color = Colors.blue.shade400;
    }

    final barHeight = maxValue <= 0
        ? 12.0
        : (bar.value.abs() / maxValue) * (chartHeight - 24) + 12;

    return Container(
      width: barWidth,
      decoration: inRange
          ? BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final entry
              in actions.labelsFor(bar.id).take(maxLabels).toList().asMap().entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _pointerColors[entry.key % _pointerColors.length]
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Flexible(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: barWidth - 2,
              height: barHeight.clamp(minBarHeight, chartHeight),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: isHighlighted || isPivot
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  '${bar.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
