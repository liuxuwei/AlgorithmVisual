import '../../core/scene/element.dart';
import '../../core/scene/point.dart';

/// 层序数组中的空位占位值
const int emptyNodeValue = -1;

/// 由层序数组构建的二叉树模型
///
/// 数组按堆式下标排列: 位置 i 的左右子位置为 2i+1 / 2i+2。
/// 值等于 [emptyNodeValue] 表示该位置为空, 其子位置一并忽略。
/// 坐标约定: y = 深度 (根为 0), x = 节点在中序遍历中的序号。
class LevelOrderTree {
  final Map<int, int> _values;
  final Map<int, int?> _left;
  final Map<int, int?> _right;
  final Map<int, Point> _positions;

  LevelOrderTree._(this._values, this._left, this._right, this._positions);

  factory LevelOrderTree.fromArray(List<int> raw) {
    if (raw.isEmpty) {
      throw ArgumentError('arr must not be empty');
    }
    for (final v in raw) {
      if (v < emptyNodeValue) {
        throw ArgumentError('arr 中的值必须 >= $emptyNodeValue (-1 表示空位)');
      }
    }
    if (raw[0] == emptyNodeValue) {
      throw ArgumentError('根节点 (第 1 个位置) 不能为空位');
    }

    // 位置 -> 值
    final allValues = <int, int>{};
    for (var i = 0; i < raw.length; i++) {
      if (raw[i] != emptyNodeValue) {
        allValues[i] = raw[i];
      }
    }

    // 只保留从根可达的节点 (空位的后代整体忽略)
    final values = <int, int>{};
    final queue = <int>[0];
    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      final v = allValues[pos];
      if (v == null) continue;
      values[pos] = v;
      queue.add(2 * pos + 1);
      queue.add(2 * pos + 2);
    }

    final left = <int, int?>{};
    final right = <int, int?>{};
    for (final pos in values.keys) {
      left[pos] = null;
      right[pos] = null;
    }
    for (final pos in values.keys) {
      if (pos == 0) continue;
      final parent = (pos - 1) ~/ 2;
      if (!values.containsKey(parent)) continue;
      if (pos.isOdd) {
        left[parent] = pos;
      } else {
        right[parent] = pos;
      }
    }

    // 中序遍历分配 x 坐标
    final positions = <int, Point>{};
    var column = 0;
    void assign(int pos, int depth) {
      final l = left[pos];
      if (l != null) assign(l, depth + 1);
      positions[pos] = Point(column.toDouble(), depth.toDouble());
      column++;
      final r = right[pos];
      if (r != null) assign(r, depth + 1);
    }

    assign(0, 0);

    return LevelOrderTree._(values, left, right, positions);
  }

  /// 根节点位置 (恒为 0)
  int get rootPos => 0;

  /// 节点总数
  int get nodeCount => _values.length;

  int valueOf(int pos) => _values[pos]!;

  String idOf(int pos) => 'node_$pos';

  int? leftOf(int pos) => _left[pos];

  int? rightOf(int pos) => _right[pos];

  /// 层序 (BFS) 访问顺序
  List<int> get levelOrder {
    final order = <int>[];
    final queue = <int>[rootPos];
    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      order.add(pos);
      final l = _left[pos];
      if (l != null) queue.add(l);
      final r = _right[pos];
      if (r != null) queue.add(r);
    }
    return order;
  }

  /// 前序 (DFS) 访问顺序
  List<int> get preorder {
    final order = <int>[];
    void walk(int pos) {
      order.add(pos);
      final l = _left[pos];
      if (l != null) walk(l);
      final r = _right[pos];
      if (r != null) walk(r);
    }

    walk(rootPos);
    return order;
  }

  /// 构建当前树的完整元素快照
  List<Element> toElements() {
    return [
      for (final entry in _positions.entries)
        TreeNode(
          id: idOf(entry.key),
          position: entry.value,
          data: _values[entry.key]!,
          leftId: _left[entry.key] == null ? null : idOf(_left[entry.key]!),
          rightId: _right[entry.key] == null ? null : idOf(_right[entry.key]!),
        ),
    ];
  }
}
