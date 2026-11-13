import 'point.dart';

/// 所有可渲染元素的基类
///
/// sealed class 确保所有子类都在此文件中定义, 方便 switch 穷尽检查
sealed class Element {
  final String id;
  final Point position;

  const Element({required this.id, required this.position});
}

/// 数组元素 —— 用于排序等算法
class ArrayBar extends Element {
  final int value;
  final int index;

  const ArrayBar({
    required super.id,
    required super.position,
    required this.value,
    required this.index,
  });
}

/// 树节点
class TreeNode extends Element {
  final dynamic data;
  final String? leftId;
  final String? rightId;

  const TreeNode({
    required super.id,
    required super.position,
    required this.data,
    this.leftId,
    this.rightId,
  });
}

/// 图节点
class GraphNode extends Element {
  final dynamic data;

  const GraphNode({
    required super.id,
    required super.position,
    required this.data,
  });
}

/// 图的边 (不属于 Element, 但常和 GraphNode 一起出现)
class GraphEdge {
  final String fromId;
  final String toId;

  const GraphEdge({required this.fromId, required this.toId});
}

/// 动态规划表格格子
class DpCell extends Element {
  final int row;
  final int col;
  final dynamic value;

  const DpCell({
    required super.id,
    required super.position,
    required this.row,
    required this.col,
    this.value,
  });
}

/// 链表节点
///
/// nextId / prevId 指向同一帧中其他 [LinkedListNode] 的 id, 为空表示链尾。
class LinkedListNode extends Element {
  final dynamic data;
  final String? nextId;
  final String? prevId;

  /// 随机指针 (随机链表的复制等题使用)
  final String? randomId;

  const LinkedListNode({
    required super.id,
    required super.position,
    required this.data,
    this.nextId,
    this.prevId,
    this.randomId,
  });
}

/// 矩阵 / 网格格子
class MatrixCell extends Element {
  final int row;
  final int col;
  final dynamic value;

  /// 展示状态, 如 "visited" / "done" / "path"
  final String? state;

  const MatrixCell({
    required super.id,
    required super.position,
    required this.row,
    required this.col,
    this.value,
    this.state,
  });
}

/// 栈 / 队列中的条目
class StackFrame extends Element {
  final int index;
  final dynamic value;

  const StackFrame({
    required super.id,
    required super.position,
    required this.index,
    required this.value,
  });
}

/// 哈希桶中的键值条目
class HashEntry extends Element {
  final dynamic key;
  final dynamic value;
  final int bucket;

  const HashEntry({
    required super.id,
    required super.position,
    required this.key,
    required this.value,
    this.bucket = 0,
  });
}

/// 指针 / 游标标注, 作为覆盖层元素指向另一个元素
class PointerMarker extends Element {
  final String label;
  final String targetId;

  const PointerMarker({
    required super.id,
    super.position = const Point(0, 0),
    required this.label,
    required this.targetId,
  });
}
