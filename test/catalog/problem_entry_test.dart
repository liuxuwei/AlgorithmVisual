import 'package:algorithm_visual/catalog/problem_entry.dart';
import 'package:algorithm_visual/core/scene/input_schema.dart';
import 'package:algorithm_visual/core/scene/scene_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProblemEntry JSON', () {
    test('构造后序列化往返一致', () {
      final entry = ProblemEntry(
        titleSlug: 'two-sum',
        number: 1,
        title: '两数之和',
        difficulty: ProblemDifficulty.easy,
        groupSlug: 'hash-table',
        patternId: 'hash-table',
        code: 'int[] twoSum(int[] nums, int target) {\n  return null;\n}',
        presets: const [
          ProblemPreset(label: '示例 1', input: {
            'nums': [2, 7, 11, 15],
            'target': 9,
          }),
        ],
        inputSchema: InputSchema(fields: [
          InputField.array('nums', maxLength: 30),
          InputField.int('target', minValue: -100, maxValue: 100),
        ]),
        maxInputSize: 30,
        maxFrames: 600,
        statementHtml: '<p>给定一个整数数组 nums 和一个整数目标值 target。</p>',
        script: (input) => const <SceneFrame>[],
      );

      final json = entry.toJson();
      final restored = ProblemEntry.fromJson(json);

      expect(restored.titleSlug, entry.titleSlug);
      expect(restored.number, entry.number);
      expect(restored.title, entry.title);
      expect(restored.difficulty, entry.difficulty);
      expect(restored.groupSlug, entry.groupSlug);
      expect(restored.patternId, entry.patternId);
      expect(restored.code, entry.code);
      expect(restored.maxInputSize, entry.maxInputSize);
      expect(restored.maxFrames, entry.maxFrames);
      expect(restored.statementHtml, entry.statementHtml);
      expect(restored.presets.single.label, '示例 1');
      expect(restored.presets.single.input['nums'], [2, 7, 11, 15]);
      expect(restored.presets.single.input['target'], 9);
      // 脚本属于本地实现, 不参与序列化
      expect(restored.script, isNull);
    });

    test('applyRemote 保留本地脚本与代码', () {
      final local = ProblemEntry(
        titleSlug: 'two-sum',
        number: 1,
        title: '旧标题',
        difficulty: ProblemDifficulty.easy,
        groupSlug: 'hash-table',
        patternId: 'hash-table',
        code: 'local code',
        presets: const [],
        inputSchema: const InputSchema(fields: []),
        maxInputSize: 10,
        maxFrames: 100,
        script: (input) => const <SceneFrame>[],
      );
      final remote = local.copyWith(
        title: '两数之和',
        statementHtml: '<p>新题面</p>',
      );

      final merged = local.applyRemote(remote);
      expect(merged.title, '两数之和');
      expect(merged.statementHtml, '<p>新题面</p>');
      expect(merged.code, 'local code');
      expect(merged.script, isNotNull);
    });

    test('难度枚举可从 LeetCode 名称解析', () {
      expect(ProblemDifficulty.fromLeetCode('EASY'), ProblemDifficulty.easy);
      expect(ProblemDifficulty.fromLeetCode('MEDIUM'), ProblemDifficulty.medium);
      expect(ProblemDifficulty.fromLeetCode('HARD'), ProblemDifficulty.hard);
      expect(ProblemDifficulty.easy.label, '简单');
    });
  });
}
