import 'package:material_ui/material_ui.dart';
import '../../scene/scene_frame.dart';
import '../../scene/element.dart';
import 'frame_actions.dart';

/// 二叉树渲染 Widget
///
/// - 用 CustomPaint 绘制父子连线
/// - 每个 TreeNode 渲染为圆形节点
/// - 节点位置来自 TreeNode.position (x = 中序序号, y = 深度), 渲染时自动缩放到画布
/// - 支持 Mark(state: 'visited') 绿色 / Highlight 橙色
class TreeView extends StatelessWidget {
  final SceneFrame frame;
  final double height;
  final double width;

  const TreeView({
    super.key,
    required this.frame,
    required this.height,
    required this.width,
  });

  static const double _radius = 18;
  static const double _padding = 28;

  @override
  Widget build(BuildContext context) {
    final nodes = frame.elements.whereType<TreeNode>().toList();

    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final actions = FrameActions.of(frame);

    // 坐标边界
    var minX = nodes.first.position.x;
    var maxX = nodes.first.position.x;
    var maxY = nodes.first.position.y;
    for (final n in nodes) {
      if (n.position.x < minX) minX = n.position.x;
      if (n.position.x > maxX) maxX = n.position.x;
      if (n.position.y > maxY) maxY = n.position.y;
    }
    final spanX = maxX - minX;
    final spanY = maxY;

    double toScreenX(double x) => spanX == 0
        ? width / 2
        : _padding + (x - minX) / spanX * (width - 2 * _padding);
    double toScreenY(double y) => spanY == 0
        ? height / 2
        : _padding + y / spanY * (height - 2 * _padding);

    final byId = <String, TreeNode>{for (final n in nodes) n.id: n};
    final screens = <String, Offset>{
      for (final n in nodes)
        n.id: Offset(toScreenX(n.position.x), toScreenY(n.position.y)),
    };

    // 父子连线
    final edges = <(Offset, Offset)>[];
    for (final n in nodes) {
      final from = screens[n.id]!;
      for (final childId in [n.leftId, n.rightId]) {
        if (childId == null) continue;
        final child = byId[childId];
        if (child == null) continue;
        edges.add((from, screens[childId]!));
      }
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _TreeEdgePainter(edges: edges),
            ),
          ),
          for (final node in nodes)
            Positioned(
              left: screens[node.id]!.dx - _radius,
              top: screens[node.id]!.dy - _radius,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TreeNodeDot(
                    label: '${node.data}',
                    color: _colorFor(
                      highlighted: actions.highlighted.contains(node.id),
                      visited: actions.visited.contains(node.id),
                    ),
                    radius: _radius,
                  ),
                  if (actions.labelsFor(node.id).isNotEmpty)
                    Text(
                      actions.labelsFor(node.id).join(','),
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
        ],
      ),
    );
  }

  Color _colorFor({required bool highlighted, required bool visited}) {
    if (highlighted) return Colors.orange;
    if (visited) return Colors.green;
    return Colors.blue.shade400;
  }
}

class _TreeNodeDot extends StatelessWidget {
  final String label;
  final Color color;
  final double radius;

  const _TreeNodeDot({
    required this.label,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TreeEdgePainter extends CustomPainter {
  final List<(Offset, Offset)> edges;

  const _TreeEdgePainter({required this.edges});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final (from, to) in edges) {
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreeEdgePainter oldDelegate) {
    if (oldDelegate.edges.length != edges.length) return true;
    for (var i = 0; i < edges.length; i++) {
      if (oldDelegate.edges[i].$1 != edges[i].$1 ||
          oldDelegate.edges[i].$2 != edges[i].$2) {
        return true;
      }
    }
    return false;
  }
}
