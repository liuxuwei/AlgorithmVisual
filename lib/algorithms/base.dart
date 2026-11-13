import '../core/scene/scene_frame.dart';
import '../core/scene/input_schema.dart';

/// 所有算法可视化器的统一接口
///
/// 实现约束:
/// - 不得 import Flutter SDK, 保持纯 Dart, 方便脱离 Flutter 运行单测
/// - visualize 接收 `Map<String, dynamic>` 输入, 返回完整的 SceneFrame 序列
/// - 必须在 visualize 内部校验 maxInputSize, 超限时抛 ArgumentError
abstract class AlgorithmVisualizer {
  /// 算法中文名, e.g. "冒泡排序"
  String get name;

  /// 分类, e.g. "sorting", "tree", "graph", "dp"
  String get category;

  /// 简要描述
  String get description;

  /// 输入规模上限, 每种算法自行声明
  int get maxInputSize;

  /// 输入字段描述, 供 UI 层自动生成表单
  InputSchema get inputSchema;

  /// 生成完整帧序列
  List<SceneFrame> visualize(Map<String, dynamic> input);
}
