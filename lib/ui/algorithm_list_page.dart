import 'package:material_ui/material_ui.dart';
import '../algorithms/registry.dart';
import 'legacy_problems.dart';
import 'visualization_page.dart';

/// 算法详情列表页 —— 显示某分类下所有算法
class AlgorithmListPage extends StatelessWidget {
  final String category;
  final String? title;

  const AlgorithmListPage({super.key, required this.category, this.title});

  @override
  Widget build(BuildContext context) {
    final algorithms = AlgorithmRegistry.instance.getByCategory(category);

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? category),
      ),
      body: algorithms.isEmpty
          ? const Center(child: Text('该分类下暂无算法'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: algorithms.length,
              itemBuilder: (context, index) {
                final algo = algorithms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VisualizationPage(
                            problem: legacyProblem(algo),
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            algo.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            algo.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
