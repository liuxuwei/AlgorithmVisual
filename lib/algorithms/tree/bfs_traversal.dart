import '../base.dart';
import '../../core/scene/scene_frame.dart';
import '../../core/scene/action.dart';
import '../../core/scene/input_schema.dart';
import 'level_order_tree.dart';

/// BFS 广度优先遍历可视化
class BfsTraversalVisualizer implements AlgorithmVisualizer {
  @override
  String get name => 'BFS 广度优先遍历';

  @override
  String get category => 'tree';

  @override
  String get description =>
      '借助队列逐层访问节点, 先访问的节点其子节点先入队。输入为层序数组, 按堆式下标排列, -1 表示空位。';

  @override
  int get maxInputSize => 31;

  @override
  InputSchema get inputSchema => InputSchema(
        fields: [
          InputField.array('arr', maxLength: maxInputSize, label: '层序数组'),
        ],
      );

  /// 代码区行号约定 (与 visualization_page 中 bfsCode 保持一致)
  /// 1  void bfs(TreeNode? root) {
  /// 2    if (root == null) return;
  /// 3    final queue = `<TreeNode>`[root];
  /// 4    while (queue.isNotEmpty) {
  /// 5      final node = queue.removeAt(0);
  /// 6      visit(node);
  /// 7      if (node.left != null) {
  /// 8        queue.add(node.left!);
  /// 9      }
  /// 10     if (node.right != null) {
  /// 11       queue.add(node.right!);
  /// 12     }
  /// 13   }
  /// 14 }
  static const int _lineVisit = 6;
  static const int _lineEnqueueLeft = 8;
  static const int _lineEnqueueRight = 11;

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

    final tree = LevelOrderTree.fromArray(raw);
    final frames = <SceneFrame>[];
    final visited = <int>[];
    var frameId = 0;

    List<Action> actionsOf(int? current) => [
          for (final pos in visited)
            Mark(targetId: tree.idOf(pos), state: 'visited'),
          if (current != null) Highlight(targetId: tree.idOf(current)),
        ];

    frames.add(SceneFrame(
      frameId: frameId++,
      caption: '初始二叉树 (共 ${tree.nodeCount} 个节点)',
      elements: tree.toElements(),
    ));

    final queue = <int>[tree.rootPos];

    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      visited.add(pos);
      frames.add(SceneFrame(
        frameId: frameId++,
        caption: '出队并访问节点 ${tree.valueOf(pos)}',
        elements: tree.toElements(),
        actions: actionsOf(pos),
        currentLine: _lineVisit,
        activeLines: const [_lineVisit],
      ));

      final left = tree.leftOf(pos);
      if (left != null) {
        queue.add(left);
        frames.add(SceneFrame(
          frameId: frameId++,
          caption: '节点 ${tree.valueOf(left)} 入队',
          elements: tree.toElements(),
          actions: actionsOf(left),
          currentLine: _lineEnqueueLeft,
          activeLines: const [_lineEnqueueLeft],
        ));
      }

      final right = tree.rightOf(pos);
      if (right != null) {
        queue.add(right);
        frames.add(SceneFrame(
          frameId: frameId++,
          caption: '节点 ${tree.valueOf(right)} 入队',
          elements: tree.toElements(),
          actions: actionsOf(right),
          currentLine: _lineEnqueueRight,
          activeLines: const [_lineEnqueueRight],
        ));
      }
    }

    frames.add(SceneFrame(
      frameId: frameId++,
      caption:
          '遍历完成, 访问顺序: ${visited.map(tree.valueOf).join(' → ')}',
      elements: tree.toElements(),
      actions: actionsOf(null),
    ));

    return frames;
  }
}
