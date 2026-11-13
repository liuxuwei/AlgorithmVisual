import 'package:material_ui/material_ui.dart';

import '../catalog/problem_catalog.dart';
import '../catalog/problem_entry.dart';
import '../catalog/problem_repository.dart';
import 'visualization_page.dart';

/// 专题题目列表: 展示题号、中文标题与难度
class ProblemListPage extends StatelessWidget {
  final ProblemGroup group;
  final ProblemCatalog catalog;
  final ProblemRepository? repository;
  final ProblemDifficulty? difficulty;

  const ProblemListPage({
    super.key,
    required this.group,
    required this.catalog,
    this.repository,
    this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final all = catalog.byGroup(group.slug);
    final problems = difficulty == null
        ? all
        : all.where((p) => p.difficulty == difficulty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${group.name} · ${problems.length} 题'),
      ),
      body: problems.isEmpty
          ? const Center(child: Text('该专题下暂无题目'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: problems.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final problem = problems[index];
                return _ProblemTile(
                  problem: problem,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VisualizationPage(
                          problem: problem,
                          repository: repository,
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

class _ProblemTile extends StatelessWidget {
  final ProblemEntry problem;
  final VoidCallback onTap;

  const _ProblemTile({required this.problem, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  '${problem.number}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  problem.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              DifficultyBadge(difficulty: problem.difficulty),
            ],
          ),
        ),
      ),
    );
  }
}

/// 难度标签
class DifficultyBadge extends StatelessWidget {
  final ProblemDifficulty difficulty;

  const DifficultyBadge({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      ProblemDifficulty.easy => Colors.green,
      ProblemDifficulty.medium => Colors.orange,
      ProblemDifficulty.hard => Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(fontSize: 12, color: color.shade700),
      ),
    );
  }
}
