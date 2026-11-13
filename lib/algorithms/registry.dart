import 'base.dart';
import 'sorting/bubble_sort.dart';
import 'sorting/quick_sort.dart';
import 'tree/dfs_traversal.dart';
import 'tree/bfs_traversal.dart';

/// 算法注册表 —— 按 category 分组管理所有 AlgorithmVisualizer 实例
class AlgorithmRegistry {
  static final AlgorithmRegistry instance = AlgorithmRegistry._();

  final Map<String, List<AlgorithmVisualizer>> _visualizers = {};
  final Map<String, AlgorithmVisualizer> _byName = {};

  AlgorithmRegistry._();

  /// 注册算法
  void register(AlgorithmVisualizer visualizer) {
    _visualizers.putIfAbsent(visualizer.category, () => []).add(visualizer);
    _byName[visualizer.name] = visualizer;
  }

  /// 按分类查询
  List<AlgorithmVisualizer> getByCategory(String category) {
    return _visualizers[category] ?? const [];
  }

  /// 查询所有已注册的 category (按字典序)
  List<String> getCategories() {
    return _visualizers.keys.toList()..sort();
  }

  /// 按名称查询
  AlgorithmVisualizer? getByName(String name) {
    return _byName[name];
  }

  /// 所有算法总数
  int get totalCount => _byName.length;

  /// 一次性注册所有内置算法
  void registerAll() {
    register(BubbleSortVisualizer());
    register(QuickSortVisualizer());
    register(DfsTraversalVisualizer());
    register(BfsTraversalVisualizer());
  }
}
