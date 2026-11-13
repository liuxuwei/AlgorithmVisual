import 'package:material_ui/material_ui.dart';
import '../../scene/scene_frame.dart';
import '../../scene/element.dart';
import 'frame_actions.dart';

/// 动态规划表格渲染 Widget
class DpGridView extends StatelessWidget {
  final SceneFrame frame;

  const DpGridView({super.key, required this.frame});

  @override
  Widget build(BuildContext context) {
    final cells = frame.elements.whereType<DpCell>().toList();

    if (cells.isEmpty) {
      return const SizedBox.shrink();
    }

    // 找出行数和列数
    int maxRow = 0;
    int maxCol = 0;
    for (final c in cells) {
      if (c.row > maxRow) maxRow = c.row;
      if (c.col > maxCol) maxCol = c.col;
    }

    final actions = FrameActions.of(frame);

    // 按 (row, col) 排序放进二维列表
    final grid = List.generate(maxRow + 1, (_) => List<Object?>.filled(maxCol + 1, null));
    final cellMap = <String, DpCell>{};
    for (final cell in cells) {
      grid[cell.row][cell.col] = cell.value;
      cellMap['dp_${cell.row}_${cell.col}'] = cell;
    }

    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        for (var r = 0; r <= maxRow; r++)
          TableRow(
            children: [
              for (var c = 0; c <= maxCol; c++)
                Builder(
                  builder: (_) {
                    final cell = cellMap['dp_${r}_$c'];
                    final id = cell?.id ?? '';
                    final isHighlighted = actions.highlighted.contains(id);
                    final isComputed = actions.computed.contains(id);
                    final labels = actions.labelsFor(id);

                    Color bgColor = Colors.white;
                    if (isHighlighted) {
                      bgColor = Colors.orange.shade100;
                    } else if (isComputed) {
                      bgColor = Colors.green.shade100;
                    }

                    return Container(
                      color: bgColor,
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (labels.isNotEmpty)
                            Text(
                              labels.join(','),
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            '${grid[r][c] ?? ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: isHighlighted || isComputed
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
      ],
    );
  }
}
