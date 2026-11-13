/// 描述帧间差异的动作基类
sealed class Action {
  final String targetId;
  const Action({required this.targetId});
}

/// 高亮某个元素
class Highlight extends Action {
  final bool isHighlighted;
  const Highlight({required super.targetId, this.isHighlighted = true});
}

/// 交换两个元素的位置
class Swap extends Action {
  final String otherId;
  const Swap({required super.targetId, required this.otherId});
}

/// 新元素入场
class Insert extends Action {
  const Insert({required super.targetId});
}

/// 元素退场
class Remove extends Action {
  const Remove({required super.targetId});
}

/// 标记元素状态 (e.g. DFS visited / DP cell computed / sorted)
class Mark extends Action {
  final String state; // "visited", "sorted", "computed", "pivot" 等
  const Mark({required super.targetId, required this.state});
}

/// 指针移动到目标元素 (e.g. 双指针 left / right)
class Pointer extends Action {
  final String label;
  const Pointer({required super.targetId, required this.label});
}

/// 区间 / 窗口标注 (e.g. 滑动窗口 [1, 3])
class Range extends Action {
  final String label;
  final String startId;
  final String endId;

  const Range({
    required super.targetId,
    required this.label,
    required this.startId,
    required this.endId,
  });
}
