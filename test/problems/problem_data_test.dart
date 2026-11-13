import 'package:algorithm_visual/problems/problem_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = builtinCatalog;

  group('题库覆盖', () {
    test('共 100 道题, 题号与 slug 唯一', () {
      expect(catalog.count, 100);
      final slugs = catalog.problems.map((p) => p.titleSlug).toSet();
      final numbers = catalog.problems.map((p) => p.number).toSet();
      expect(slugs.length, 100);
      expect(numbers.length, 100);
    });

    test('17 个专题的题目数量符合热题 100', () {
      const expected = {
        'hash-table': 3,
        'two-pointers': 4,
        'sliding-window': 2,
        'substring': 3,
        'array': 5,
        'matrix': 4,
        'linked-list': 14,
        'binary-tree': 15,
        'graph': 4,
        'backtracking': 8,
        'binary-search': 6,
        'stack': 5,
        'heap': 3,
        'greedy': 4,
        'dp': 10,
        'dp-multidim': 5,
        'tricks': 5,
      };
      expect(catalog.groups.length, 17);
      for (final group in catalog.groups) {
        expect(
          catalog.countOf(group.slug),
          expected[group.slug],
          reason: '专题 ${group.slug} 数量不符',
        );
      }
    });

    test('每道题都有代码、输入结构、预置用例与脚本', () {
      for (final problem in catalog.problems) {
        expect(problem.code.trim(), isNotEmpty, reason: problem.titleSlug);
        expect(problem.inputSchema.fields, isNotEmpty, reason: problem.titleSlug);
        expect(problem.presets, isNotEmpty, reason: problem.titleSlug);
        expect(problem.script, isNotNull, reason: problem.titleSlug);
        expect(problem.maxFrames, greaterThan(0), reason: problem.titleSlug);
        expect(problem.maxInputSize, greaterThan(0), reason: problem.titleSlug);
        expect(problem.patternId, isNotEmpty, reason: problem.titleSlug);
      }
    });
  });

  group('脚本执行', () {
    test('所有预置用例都能生成连续帧且行号合法', () {
      for (final problem in catalog.problems) {
        final codeLines = problem.code.split('\n').length;
        for (final preset in problem.presets) {
          final frames =
              problem.script!(Map<String, dynamic>.from(preset.input));
          expect(frames, isNotEmpty, reason: '${problem.titleSlug} / ${preset.label}');
          expect(
            frames.length,
            lessThanOrEqualTo(problem.maxFrames),
            reason: '${problem.titleSlug} 帧数超过 maxFrames',
          );
          for (var i = 0; i < frames.length; i++) {
            final frame = frames[i];
            expect(frame.frameId, i, reason: '${problem.titleSlug} 帧号不连续');
            expect(frame.caption, isNotEmpty, reason: '${problem.titleSlug} 缺少说明');
            if (frame.currentLine != null) {
              expect(frame.currentLine, greaterThanOrEqualTo(1));
              expect(frame.currentLine, lessThanOrEqualTo(codeLines));
            }
          }
        }
      }
    });
  });
}
