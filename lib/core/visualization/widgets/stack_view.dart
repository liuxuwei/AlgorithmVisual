import 'package:material_ui/material_ui.dart';

import '../../scene/element.dart';
import '../../scene/scene_frame.dart';
import 'frame_actions.dart';

/// 栈 / 队列渲染 Widget
///
/// 按 index 自底向上排布, 最新的元素显示在顶部。
class StackView extends StatelessWidget {
  final SceneFrame frame;

  const StackView({super.key, required this.frame});

  @override
  Widget build(BuildContext context) {
    final frames = frame.elements.whereType<StackFrame>().toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    if (frames.isEmpty) {
      return const SizedBox.shrink();
    }

    final actions = FrameActions.of(frame);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              '栈顶',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
          for (final item in frames.reversed)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: _StackItem(
                item: item,
                labels: actions.labelsFor(item.id),
                highlighted: actions.highlighted.contains(item.id),
                visited: actions.visited.contains(item.id),
                isTop: item.index == frames.last.index,
              ),
            ),
        ],
      ),
    );
  }
}

class _StackItem extends StatelessWidget {
  final StackFrame item;
  final List<String> labels;
  final bool highlighted;
  final bool visited;
  final bool isTop;

  const _StackItem({
    required this.item,
    required this.labels,
    required this.highlighted,
    required this.visited,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.blue.shade50;
    if (highlighted) color = Colors.orange.shade100;
    if (visited) color = Colors.green.shade100;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 96, minHeight: 34),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: isTop ? Colors.blueGrey.shade400 : Colors.blueGrey.shade200,
              width: isTop ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.value}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '#${item.index}',
                style: const TextStyle(fontSize: 9, color: Colors.grey),
              ),
            ],
          ),
        ),
        if (labels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              labels.join(','),
              style: const TextStyle(
                fontSize: 9,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
