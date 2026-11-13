import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../scene/element.dart';
import '../../scene/scene_frame.dart';
import 'frame_actions.dart';

/// 链表渲染 Widget
///
/// - 自动按 next 关系拆成若干条链 (支持多链表 / 相交链表 / 环形链表)
/// - CustomPaint 绘制箭头, 空指针显示为 `∅`
/// - 支持 Highlight / Mark(visited) 着色与指针标签
class LinkedListView extends StatelessWidget {
  final SceneFrame frame;
  final double height;
  final double width;

  const LinkedListView({
    super.key,
    required this.frame,
    required this.height,
    required this.width,
  });

  static const double _nodeHeight = 34;

  @override
  Widget build(BuildContext context) {
    final nodes = frame.elements.whereType<LinkedListNode>().toList();
    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final actions = FrameActions.of(frame);
    final byId = <String, LinkedListNode>{for (final n in nodes) n.id: n};
    final chains = _buildChains(nodes, byId);
    final rowHeight = math.max(56.0, height / chains.length);

    final positions = <String, Offset>{};
    final sizes = <String, double>{};
    final edges = <_ListEdge>[];
    final nullMarkers = <Offset>[];

    for (var row = 0; row < chains.length; row++) {
      final chain = chains[row];
      final step = (width - 24) / math.max(chain.length, 1);
      final nodeWidth = (step - 12).clamp(22.0, 54.0);
      final centerY = rowHeight * row + rowHeight / 2;
      final rowTop = row * rowHeight;

      Offset centerOf(int index) =>
          Offset(12 + step * index + step / 2, centerY);

      for (var i = 0; i < chain.length; i++) {
        final key = '$row:${chain[i].id}';
        positions[key] = centerOf(i);
        sizes[key] = nodeWidth;
      }

      for (var i = 0; i < chain.length; i++) {
        final node = chain[i];
        final fromKey = '$row:${node.id}';
        final nextId = node.nextId;
        if (nextId == null) {
          nullMarkers.add(Offset(
            positions[fromKey]!.dx + nodeWidth / 2 + 8,
            centerY,
          ));
          continue;
        }

        final nextIndex = chain.indexWhere((n) => n.id == nextId, i + 1);
        if (nextIndex >= 0) {
          edges.add(_ListEdge(
            from: positions['$row:${chain[i].id}']!,
            to: positions['$row:${chain[nextIndex].id}']!,
            fromWidth: nodeWidth,
            toWidth: nodeWidth,
          ));
        } else if (byId.containsKey(nextId)) {
          // 环 / 指回已渲染节点: 画一条下方的回边
          edges.add(_ListEdge(
            from: positions[fromKey]!,
            to: positions['$row:$nextId'] ?? positions[fromKey]!,
            fromWidth: nodeWidth,
            toWidth: nodeWidth,
            curved: true,
            bottom: rowTop + rowHeight - 6,
          ));
        }
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _ListEdgePainter(edges: edges)),
          ),
          for (final entry in positions.entries)
            ..._buildNode(
              entry.key,
              entry.value,
              sizes[entry.key] ?? 40,
              nodes,
              actions,
            ),
          for (final marker in nullMarkers)
            Positioned(
              left: marker.dx,
              top: marker.dy - 8,
              child: const Text(
                '∅',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildNode(
    String key,
    Offset center,
    double nodeWidth,
    List<LinkedListNode> nodes,
    FrameActions actions,
  ) {
    final id = key.substring(key.indexOf(':') + 1);
    final node = nodes.firstWhere((n) => n.id == id);
    final labels = actions.labelsFor(id);

    Color color = Colors.blue.shade50;
    Color border = Colors.blue.shade200;
    if (actions.highlighted.contains(id)) {
      color = Colors.orange.shade100;
      border = Colors.orange.shade400;
    } else if (actions.visited.contains(id)) {
      color = Colors.green.shade100;
      border = Colors.green.shade400;
    }

    return [
      Positioned(
        left: center.dx - nodeWidth / 2,
        top: center.dy - _nodeHeight / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: nodeWidth,
              height: _nodeHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: border, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${node.data}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
          ],
        ),
      ),
    ];
  }

  List<List<LinkedListNode>> _buildChains(
    List<LinkedListNode> nodes,
    Map<String, LinkedListNode> byId,
  ) {
    final incoming = <String>{};
    for (final node in nodes) {
      final next = node.nextId;
      if (next != null && byId.containsKey(next)) incoming.add(next);
    }
    final heads = [
      for (final node in nodes)
        if (!incoming.contains(node.id)) node,
    ];
    if (heads.isEmpty) heads.add(nodes.first);

    final chains = <List<LinkedListNode>>[];
    for (final head in heads) {
      final chain = <LinkedListNode>[];
      final seen = <String>{};
      LinkedListNode? current = head;
      while (current != null && seen.add(current.id)) {
        chain.add(current);
        final next = current.nextId;
        current = next == null ? null : byId[next];
      }
      chains.add(chain);
    }
    return chains;
  }
}

class _ListEdge {
  final Offset from;
  final Offset to;
  final double fromWidth;
  final double toWidth;
  final bool curved;
  final double bottom;

  const _ListEdge({
    required this.from,
    required this.to,
    required this.fromWidth,
    required this.toWidth,
    this.curved = false,
    this.bottom = 0,
  });
}

class _ListEdgePainter extends CustomPainter {
  final List<_ListEdge> edges;

  const _ListEdgePainter({required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.shade300
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (final edge in edges) {
      final start = Offset(
        edge.from.dx + edge.fromWidth / 2,
        edge.from.dy,
      );
      final end = Offset(
        edge.to.dx - edge.toWidth / 2,
        edge.to.dy,
      );

      if (!edge.curved && end.dx > start.dx) {
        canvas.drawLine(start, end, paint);
        _drawArrowHead(canvas, end, 0, paint);
      } else {
        final path = Path()
          ..moveTo(edge.from.dx, edge.from.dy + 17)
          ..cubicTo(
            edge.from.dx,
            edge.bottom,
            edge.to.dx,
            edge.bottom,
            edge.to.dx,
            edge.to.dy + 17,
          );
        canvas.drawPath(path, paint);
        _drawArrowHead(canvas, Offset(edge.to.dx, edge.to.dy + 17), -math.pi / 2,
            paint);
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Paint paint) {
    const size = 6.0;
    final left = tip +
        Offset(
          math.cos(angle + math.pi * 0.8) * size,
          math.sin(angle + math.pi * 0.8) * size,
        );
    final right = tip +
        Offset(
          math.cos(angle - math.pi * 0.8) * size,
          math.sin(angle - math.pi * 0.8) * size,
        );
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant _ListEdgePainter oldDelegate) {
    if (oldDelegate.edges.length != edges.length) return true;
    for (var i = 0; i < edges.length; i++) {
      final a = oldDelegate.edges[i];
      final b = edges[i];
      if (a.from != b.from || a.to != b.to || a.curved != b.curved) {
        return true;
      }
    }
    return false;
  }
}
