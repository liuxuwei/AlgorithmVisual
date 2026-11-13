import 'package:material_ui/material_ui.dart';

import '../../scene/element.dart';
import '../../scene/scene_frame.dart';
import 'frame_actions.dart';

/// 哈希桶渲染 Widget
///
/// 按 bucket 分组展示 key → value, 便于观察哈希冲突与分组结果。
class HashBucketView extends StatelessWidget {
  final SceneFrame frame;

  const HashBucketView({super.key, required this.frame});

  @override
  Widget build(BuildContext context) {
    final entries = frame.elements.whereType<HashEntry>().toList()
      ..sort((a, b) => a.bucket.compareTo(b.bucket));
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final actions = FrameActions.of(frame);
    final buckets = <int, List<HashEntry>>{};
    for (final entry in entries) {
      buckets.putIfAbsent(entry.bucket, () => []).add(entry);
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final bucket in buckets.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '桶 ${bucket.key}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final entry in bucket.value)
                          _HashEntryChip(
                            entry: entry,
                            labels: actions.labelsFor(entry.id),
                            highlighted: actions.highlighted.contains(entry.id),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HashEntryChip extends StatelessWidget {
  final HashEntry entry;
  final List<String> labels;
  final bool highlighted;

  const _HashEntryChip({
    required this.entry,
    required this.labels,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: highlighted ? Colors.orange.shade100 : Colors.blue.shade50,
        border: Border.all(
          color: highlighted ? Colors.orange.shade300 : Colors.blue.shade100,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${entry.key} → ${_formatValue(entry.value)}'
        '${labels.isEmpty ? '' : '  ${labels.join(",")}'}',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  static String _formatValue(dynamic value) {
    if (value is List) return '[${value.join(', ')}]';
    return '$value';
  }
}
