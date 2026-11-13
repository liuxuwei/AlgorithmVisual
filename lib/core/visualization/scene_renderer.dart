import 'package:material_ui/material_ui.dart';

import '../scene/element.dart';
import '../scene/scene_frame.dart';
import 'widgets/array_bar.dart';
import 'widgets/dp_grid.dart';
import 'widgets/hash_bucket.dart';
import 'widgets/linked_list_view.dart';
import 'widgets/matrix_grid.dart';
import 'widgets/stack_view.dart';
import 'widgets/tree_view.dart';

/// SceneFrame → Flutter Widget 的渲染器
///
/// 先按主元素类型选择基础渲染器, 指针 / 区间 / 着色标注由各渲染器作为覆盖层叠加。
class SceneRenderer extends StatelessWidget {
  final SceneFrame frame;

  const SceneRenderer({super.key, required this.frame});

  @override
  Widget build(BuildContext context) {
    final elements = frame.elements;

    if (elements.whereType<MatrixCell>().isNotEmpty) {
      return Center(child: MatrixGridView(frame: frame));
    }

    if (elements.whereType<LinkedListNode>().isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => LinkedListView(
          frame: frame,
          height: constraints.maxHeight,
          width: constraints.maxWidth,
        ),
      );
    }

    if (elements.whereType<StackFrame>().isNotEmpty) {
      return Center(child: StackView(frame: frame));
    }

    if (elements.whereType<HashEntry>().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: HashBucketView(frame: frame),
      );
    }

    if (elements.whereType<ArrayBar>().isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => ArrayBarView(
          frame: frame,
          height: constraints.maxHeight,
          width: constraints.maxWidth,
        ),
      );
    }

    if (elements.whereType<DpCell>().isNotEmpty) {
      return Center(child: DpGridView(frame: frame));
    }

    if (elements.whereType<TreeNode>().isNotEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => TreeView(
          frame: frame,
          height: constraints.maxHeight,
          width: constraints.maxWidth,
        ),
      );
    }

    // 暂时没有 GraphNode 的专门渲染器, 显示占位
    if (elements.isNotEmpty) {
      return Center(
        child: Text(
          '暂未实现的元素类型: ${elements.map((e) => e.runtimeType).toSet()}',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
