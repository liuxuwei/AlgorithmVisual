import 'package:algorithm_visual/catalog/problem_entry.dart';
import 'package:algorithm_visual/problems/scripts/batch1.dart';
import 'package:algorithm_visual/problems/scripts/batch2.dart';
import 'package:algorithm_visual/problems/scripts/batch3.dart';
import 'package:algorithm_visual/problems/scripts/batch4.dart';
import 'package:algorithm_visual/problems/scripts/batch5.dart';
import 'package:algorithm_visual/problems/scripts/batch6.dart';
import 'package:algorithm_visual/problems/scripts/batch7.dart';
import 'package:flutter_test/flutter_test.dart';

void _checkBatch(String name, List<ProblemEntry> problems, int expected) {
  group(name, () {
    test('题目数量为 $expected', () {
      expect(problems.length, expected);
    });

    test('每个预置用例都能执行并生成合法帧', () {
      for (final problem in problems) {
        final codeLines = problem.code.split('\n').length;
        for (final preset in problem.presets) {
          final frames =
              problem.script!(Map<String, dynamic>.from(preset.input));
          expect(frames, isNotEmpty, reason: '${problem.titleSlug}/${preset.label}');
          for (var i = 0; i < frames.length; i++) {
            expect(frames[i].frameId, i);
            if (frames[i].currentLine != null) {
              expect(frames[i].currentLine! <= codeLines, isTrue,
                  reason: '${problem.titleSlug} 行号越界');
            }
          }
        }
      }
    });
  });
}

void main() {
  _checkBatch('batch1 哈希/双指针/滑动窗口/子串', batch1Problems(), 12);
  _checkBatch('batch2 数组/矩阵/二分', batch2Problems(), 15);
  _checkBatch('batch3 链表', batch3Problems(), 14);
  _checkBatch('batch4 二叉树', batch4Problems(), 15);
  _checkBatch('batch5 图论/回溯', batch5Problems(), 12);
  _checkBatch('batch6 栈/堆/贪心', batch6Problems(), 12);
  _checkBatch('batch7 动态规划/技巧', batch7Problems(), 20);
}
