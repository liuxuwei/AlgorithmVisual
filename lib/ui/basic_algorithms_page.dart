import 'package:material_ui/material_ui.dart';
import '../algorithms/registry.dart';
import 'algorithm_list_page.dart';

/// 基础算法入口: 保留原有的算法分类列表
class BasicAlgorithmsPage extends StatelessWidget {
  const BasicAlgorithmsPage({super.key});

  static const Map<String, IconData> _icons = {
    'sorting': Icons.sort_rounded,
    'tree': Icons.account_tree_rounded,
    'graph': Icons.hub_rounded,
    'dp': Icons.table_chart_rounded,
    'search': Icons.search_rounded,
    'recursion': Icons.loop_rounded,
  };

  static const Map<String, String> _names = {
    'sorting': '排序算法',
    'tree': '树遍历',
    'graph': '图算法',
    'dp': '动态规划',
    'search': '搜索',
    'recursion': '递归/回溯',
  };

  @override
  Widget build(BuildContext context) {
    final registry = AlgorithmRegistry.instance;
    final categories = registry.getCategories();

    return Scaffold(
      appBar: AppBar(title: const Text('基础算法')),
      body: categories.isEmpty
          ? const Center(child: Text('暂无已注册算法'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final algorithms = registry.getByCategory(category);
                return _CategoryCard(
                  icon: _icons[category] ?? Icons.auto_graph_rounded,
                  label: _names[category] ?? category,
                  count: algorithms.length,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AlgorithmListPage(
                          category: category,
                          title: _names[category] ?? category,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '$count 个算法',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
