import 'package:algorithm_visual/catalog/problem_catalog.dart';
import 'package:algorithm_visual/catalog/problem_entry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'snapshot_test_data.dart';

void main() {
  late ProblemCatalog catalog;

  setUpAll(() {
    catalog = ProblemCatalog.fromJson(loadSnapshotJson());
  });

  group('ProblemCatalog', () {
    test('从快照解析出 100 道题与 17 个专题', () {
      expect(catalog.count, 100);
      expect(catalog.groups.length, 17);
      expect(catalog.groups.map((g) => g.slug).toSet().length, 17);
    });

    test('每个专题的题目数量与官方一致', () {
      expect(catalog.byGroup('hash-table').length, 3);
      expect(catalog.byGroup('two-pointers').length, 4);
      expect(catalog.byGroup('sliding-window').length, 2);
      expect(catalog.byGroup('substring').length, 3);
      expect(catalog.byGroup('array').length, 5);
      expect(catalog.byGroup('matrix').length, 4);
      expect(catalog.byGroup('linked-list').length, 14);
      expect(catalog.byGroup('binary-tree').length, 15);
      expect(catalog.byGroup('graph').length, 4);
      expect(catalog.byGroup('backtracking').length, 8);
      expect(catalog.byGroup('binary-search').length, 6);
      expect(catalog.byGroup('stack').length, 5);
      expect(catalog.byGroup('heap').length, 3);
      expect(catalog.byGroup('greedy').length, 4);
      expect(catalog.byGroup('dp').length, 10);
      expect(catalog.byGroup('dp-multidim').length, 5);
      expect(catalog.byGroup('tricks').length, 5);
    });

    test('按 titleSlug 与题号均可定位', () {
      final twoSum = catalog.bySlug('two-sum');
      expect(twoSum, isNotNull);
      expect(twoSum!.title, '两数之和');
      expect(catalog.byNumber(1)!.titleSlug, 'two-sum');
    });

    test('难度筛选只返回包含该难度的专题', () {
      final hardGroups = catalog.visibleGroups(difficulty: ProblemDifficulty.hard);
      expect(hardGroups, isNotEmpty);
      expect(hardGroups.length, lessThan(17));
      for (final g in hardGroups) {
        expect(catalog.countOf(g.slug, difficulty: ProblemDifficulty.hard), greaterThan(0));
      }
    });

    test('重复 titleSlug 被拒绝', () {
      final entry = catalog.problems.first;
      expect(
        () => ProblemCatalog([entry, entry]),
        throwsArgumentError,
      );
    });
  });
}
