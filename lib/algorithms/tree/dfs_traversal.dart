import '../base.dart';
import '../../core/scene/scene_frame.dart';
import '../../core/scene/action.dart';
import '../../core/scene/input_schema.dart';
import 'level_order_tree.dart';

/// DFS 深度优先遍历 (前序) 可视化
class DfsTraversalVisualizer implements AlgorithmVisualizer {
  @override
  String get name => 'DFS 深度优先遍历';

  @override
  String get category => 'tree';

  @override
  String get description =>
      '从根节点出发, 先访问左子树再访问右子树 (前序遍历)。输入为层序数组, 按堆式下标排列, -1 表示空位。';

  @override
  int get maxInputSize => 31;

  @override
  InputSchema get inputSchema => InputSchema(
        fields: [
          InputField.array('arr', maxLength: maxInputSize, label: '层序数组'),
        ],
      );

  /// 代码区行号约定 (与 visualization_page 中 dfsCode 保持一致)
  /// 1 void dfs(TreeNode? node) {
  /// 2   if (node == null) return;
  /// 3   visit(node);
  /// 4   dfs(node.left);
  /// 5   dfs(node.right);
  /// 6 }
  static const int _lineVisit = 3;

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

    void visit(int pos) {
      visited.add(pos);
      frames.add(SceneFrame(
        frameId: frameId++,
        caption: '访问节点 ${tree.valueOf(pos)}',
        elements: tree.toElements(),
        actions: actionsOf(pos),
        currentLine: _lineVisit,
        activeLines: const [_lineVisit],
      ));

      final left = tree.leftOf(pos);
      if (left != null) visit(left);
      final right = tree.rightOf(pos);
      if (right != null) visit(right);
    }

    visit(tree.rootPos);

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
