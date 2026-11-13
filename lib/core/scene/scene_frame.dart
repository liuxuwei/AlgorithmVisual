import 'element.dart';
import 'action.dart';

/// 算法执行某一帧的完整快照
///
/// 每帧包含：
/// - frameId: 帧序号 (从 0 开始)
/// - caption: 文字说明 (e.g. "交换 arr[1] 和 arr[2]")
/// - elements: 当前场景所有元素的完整列表 (快照模型, 不依赖上一帧)
/// - actions: 本帧相对于上一帧的差异动作 (用于渲染层添加过渡动画)
/// - currentLine: 可选, 当前执行的代码行号 (1-based)
/// - activeLines: 可选, 同时高亮的代码行号列表
class SceneFrame {
  final int frameId;
  final String caption;
  final List<Element> elements;
  final List<Action> actions;
  final int? currentLine;
  final List<int>? activeLines;

  const SceneFrame({
    required this.frameId,
    this.caption = '',
    required this.elements,
    this.actions = const [],
    this.currentLine,
    this.activeLines,
  });

  SceneFrame copyWith({
    int? frameId,
    String? caption,
    List<Element>? elements,
    List<Action>? actions,
    int? currentLine,
    List<int>? activeLines,
  }) {
    return SceneFrame(
      frameId: frameId ?? this.frameId,
      caption: caption ?? this.caption,
      elements: elements ?? this.elements,
      actions: actions ?? this.actions,
      currentLine: currentLine ?? this.currentLine,
      activeLines: activeLines ?? this.activeLines,
    );
  }
}
