import 'problem_entry.dart';

/// 热题 100 的 17 个专题分组 (顺序与 LeetCode 学习计划一致)
const List<ProblemGroup> kProblemGroups = [
  ProblemGroup(slug: 'hash-table', name: '哈希', order: 0),
  ProblemGroup(slug: 'two-pointers', name: '双指针', order: 1),
  ProblemGroup(slug: 'sliding-window', name: '滑动窗口', order: 2),
  ProblemGroup(slug: 'substring', name: '子串', order: 3),
  ProblemGroup(slug: 'array', name: '普通数组', order: 4),
  ProblemGroup(slug: 'matrix', name: '矩阵', order: 5),
  ProblemGroup(slug: 'linked-list', name: '链表', order: 6),
  ProblemGroup(slug: 'binary-tree', name: '二叉树', order: 7),
  ProblemGroup(slug: 'graph', name: '图论', order: 8),
  ProblemGroup(slug: 'backtracking', name: '回溯', order: 9),
  ProblemGroup(slug: 'binary-search', name: '二分查找', order: 10),
  ProblemGroup(slug: 'stack', name: '栈', order: 11),
  ProblemGroup(slug: 'heap', name: '堆', order: 12),
  ProblemGroup(slug: 'greedy', name: '贪心算法', order: 13),
  ProblemGroup(slug: 'dp', name: '动态规划', order: 14),
  ProblemGroup(slug: 'dp-multidim', name: '多维动态规划', order: 15),
  ProblemGroup(slug: 'tricks', name: '技巧', order: 16),
];

/// 题库目录: 按 titleSlug 与专题建立索引
class ProblemCatalog {
  final List<ProblemEntry> problems;

  final Map<String, ProblemEntry> _bySlug = {};
  final Map<String, List<ProblemEntry>> _byGroup = {};

  ProblemCatalog(List<ProblemEntry> problems)
      : problems = List<ProblemEntry>.unmodifiable(problems) {
    for (final p in this.problems) {
      if (_bySlug.containsKey(p.titleSlug)) {
        throw ArgumentError('重复的 titleSlug: ${p.titleSlug}');
      }
      _bySlug[p.titleSlug] = p;
      _byGroup.putIfAbsent(p.groupSlug, () => []).add(p);
    }
    for (final list in _byGroup.values) {
      list.sort((a, b) => a.number.compareTo(b.number));
    }
  }

  int get count => problems.length;

  ProblemEntry? bySlug(String titleSlug) => _bySlug[titleSlug];

  ProblemEntry? byNumber(int number) {
    for (final p in problems) {
      if (p.number == number) return p;
    }
    return null;
  }

  List<ProblemGroup> get groups => kProblemGroups;

  List<ProblemEntry> byGroup(String groupSlug) => _byGroup[groupSlug] ?? const [];

  /// 某专题下指定难度的题目数量 (difficulty 为 null 表示全部)
  int countOf(String groupSlug, {ProblemDifficulty? difficulty}) {
    final list = byGroup(groupSlug);
    if (difficulty == null) return list.length;
    return list.where((p) => p.difficulty == difficulty).length;
  }

  /// 至少包含一道指定难度题目的专题 (difficulty 为 null 表示全部专题)
  List<ProblemGroup> visibleGroups({ProblemDifficulty? difficulty}) {
    return [
      for (final g in kProblemGroups)
        if (countOf(g.slug, difficulty: difficulty) > 0) g,
    ];
  }

  Map<String, dynamic> toJson({bool includeStatement = true}) => {
        'problems': [
          for (final p in problems) p.toJson(includeStatement: includeStatement),
        ],
      };

  factory ProblemCatalog.fromJson(Map<String, dynamic> json) {
    final raw = json['problems'] as List? ?? const [];
    return ProblemCatalog([
      for (final item in raw)
        ProblemEntry.fromJson(Map<String, dynamic>.from(item as Map)),
    ]);
  }
}
