import 'package:material_ui/material_ui.dart';

import '../../scene/element.dart';
import '../../scene/scene_frame.dart';
import 'frame_actions.dart';

/// 矩阵 / 网格渲染 Widget
///
/// 按 row/col 排布 MatrixCell, 支持状态着色、指针与区间窗口。
class MatrixGridView extends StatelessWidget {
  final SceneFrame frame;

  const MatrixGridView({super.key, required this.frame});

  static const double _cellWidth = 44;
  static const double _cellHeight = 40;

  @override
  Widget build(BuildContext context) {
    final cells = frame.elements.whereType<MatrixCell>().toList();
    if (cells.isEmpty) {
      return const SizedBox.shrink();
    }

    final actions = FrameActions.of(frame);
    final byId = <String, MatrixCell>{for (final c in cells) c.id: c};

    var rows = 0;
    var cols = 0;
    for (final c in cells) {
      if (c.row + 1 > rows) rows = c.row + 1;
      if (c.col + 1 > cols) cols = c.col + 1;
    }
    final idToIndex = <String, int>{
      for (final c in cells) c.id: c.row * cols + c.col,
    };

    final grid = List.generate(
      rows,
      (_) => List<MatrixCell?>.filled(cols, null),
    );
    for (final c in cells) {
      if (c.row < rows && c.col < cols) grid[c.row][c.col] = c;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(_cellWidth),
        border: TableBorder.all(color: Colors.blueGrey.shade100),
        children: [
          for (var r = 0; r < rows; r++)
            TableRow(
              children: [
                for (var c = 0; c < cols; c++)
                  _buildCell(
                    grid[r][c],
                    actions: actions,
                    idToIndex: idToIndex,
                    byId: byId,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(
    MatrixCell? cell, {
    required FrameActions actions,
    required Map<String, int> idToIndex,
    required Map<String, MatrixCell> byId,
  }) {
    if (cell == null) {
      return const SizedBox(height: _cellHeight);
    }

    final highlighted = actions.highlighted.contains(cell.id);
    final inRange = actions.inRangeAt(idToIndex[cell.id] ?? -1, idToIndex);
    final state = cell.state;

    Color background = Colors.white;
    if (highlighted) {
      background = Colors.orange.shade200;
    } else if (state == 'visited') {
      background = Colors.green.shade100;
    } else if (state == 'path' || state == 'computed' || state == 'done') {
      background = Colors.purple.shade50;
    } else if (inRange) {
      background = Colors.orange.shade50;
    }

    final labels = actions.labelsFor(cell.id);

    return Container(
      height: _cellHeight,
      color: background,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (labels.isNotEmpty)
            Text(
              labels.join(','),
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                color: Colors.deepOrange,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          Text(
            '${cell.value ?? ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  highlighted || inRange ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
