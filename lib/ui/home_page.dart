import 'package:material_ui/material_ui.dart';

import '../catalog/problem_catalog.dart';
import '../catalog/problem_entry.dart';
import '../catalog/problem_repository.dart';
import '../problems/problem_data.dart';
import 'basic_algorithms_page.dart';
import 'offline_banner.dart';
import 'problem_list_page.dart';

/// 首页: 以 LeetCode 热题 100 为主入口, 按 17 个专题分组展示,
/// 另设「基础算法」入口保留原有算法分类。
class HomePage extends StatefulWidget {
  final ProblemRepository? repository;

  const HomePage({super.key, this.repository});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Map<String, IconData> _groupIcons = {
    'hash-table': Icons.tag,
    'two-pointers': Icons.swap_horiz,
    'sliding-window': Icons.crop_free,
    'substring': Icons.text_fields,
    'array': Icons.view_list,
    'matrix': Icons.grid_on,
    'linked-list': Icons.link,
    'binary-tree': Icons.account_tree,
    'graph': Icons.hub,
    'backtracking': Icons.u_turn_left,
    'binary-search': Icons.search,
    'stack': Icons.layers,
    'heap': Icons.account_balance,
    'greedy': Icons.trending_up,
    'dp': Icons.table_chart,
    'dp-multidim': Icons.grid_4x4,
    'tricks': Icons.lightbulb_outline,
  };

  ProblemDifficulty? _difficulty;
  bool _retrying = false;

  Future<void> _retry() async {
    final repository = widget.repository;
    if (repository == null || _retrying) return;
    setState(() => _retrying = true);
    await repository.refresh();
    if (!mounted) return;
    setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository;
    if (repository == null) {
      return _buildScaffold(
        context,
        builtinCatalog,
        offline: false,
        loading: false,
      );
    }
    return ValueListenableBuilder<CatalogState>(
      valueListenable: repository.state,
      builder: (context, state, _) => _buildScaffold(
        context,
        state.catalog ?? builtinCatalog,
        offline: state.isOffline,
        loading: state.isLoading && state.catalog == null,
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ProblemCatalog catalog, {
    required bool offline,
    required bool loading,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('算法可视化'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('题库加载中...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (offline)
                    OfflineBanner(onRetry: _retry, retrying: _retrying),
                  _buildHotHeader(context, catalog),
                  const SizedBox(height: 12),
                  _buildFilterRow(context, catalog),
                  const SizedBox(height: 8),
                  ..._buildGroupCards(context, catalog),
                  const SizedBox(height: 4),
                  _buildBasicEntry(context),
                ],
              ),
            ),
    );
  }

  Widget _buildHotHeader(BuildContext context, ProblemCatalog catalog) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            size: 32,
            color: scheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '热题 100',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                ),
                Text(
                  'LeetCode 热题 100 · ${catalog.count} 道题 · '
                  '${catalog.groups.length} 个专题',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, ProblemCatalog catalog) {
    final options = <(String, ProblemDifficulty?)>[
      ('全部', null),
      for (final difficulty in ProblemDifficulty.values)
        (difficulty.label, difficulty),
    ];

    return Wrap(
      spacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(
              '${option.$1} ${_countOf(catalog, option.$2)}',
            ),
            selected: _difficulty == option.$2,
            onSelected: (_) => setState(() => _difficulty = option.$2),
          ),
      ],
    );
  }

  int _countOf(ProblemCatalog catalog, ProblemDifficulty? difficulty) {
    if (difficulty == null) return catalog.count;
    return catalog.problems.where((p) => p.difficulty == difficulty).length;
  }

  List<Widget> _buildGroupCards(BuildContext context, ProblemCatalog catalog) {
    final groups = catalog.visibleGroups(difficulty: _difficulty);
    if (groups.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: Text('该难度下暂无题目')),
        ),
      ];
    }
    return [
      for (final group in groups)
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.secondaryContainer,
              child: Icon(
                _groupIcons[group.slug] ?? Icons.auto_graph,
                size: 20,
              ),
            ),
            title: Text(group.name),
            subtitle: Text(
              '${catalog.countOf(group.slug, difficulty: _difficulty)} 道题',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProblemListPage(
                    group: group,
                    catalog: catalog,
                    repository: widget.repository,
                    difficulty: _difficulty,
                  ),
                ),
              );
            },
          ),
        ),
    ];
  }

  Widget _buildBasicEntry(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: const Icon(Icons.school, size: 20),
        ),
        title: const Text('基础算法'),
        subtitle: const Text('排序 · 树遍历'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BasicAlgorithmsPage()),
          );
        },
      ),
    );
  }
}
