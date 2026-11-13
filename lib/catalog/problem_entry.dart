import '../core/scene/input_schema.dart';
import '../core/scene/scene_frame.dart';

/// 单题步骤脚本签名: 接收该题输入, 返回完整帧序列
typedef ProblemScript = List<SceneFrame> Function(Map<String, dynamic> input);

/// 题目难度
enum ProblemDifficulty {
  easy('简单'),
  medium('中等'),
  hard('困难');

  const ProblemDifficulty(this.label);

  final String label;

  /// 从 LeetCode 返回的大写难度名解析
  static ProblemDifficulty fromLeetCode(String value) {
    switch (value.toUpperCase()) {
      case 'EASY':
        return ProblemDifficulty.easy;
      case 'HARD':
        return ProblemDifficulty.hard;
      default:
        return ProblemDifficulty.medium;
    }
  }

  /// 从序列化的小写名称解析
  static ProblemDifficulty fromName(String value) {
    return ProblemDifficulty.values.firstWhere(
      (d) => d.name == value,
      orElse: () => ProblemDifficulty.medium,
    );
  }
}

/// 专题分组 (热题 100 共 17 组)
class ProblemGroup {
  final String slug;
  final String name;
  final int order;

  const ProblemGroup({
    required this.slug,
    required this.name,
    required this.order,
  });
}

/// 一道题的预置输入用例
class ProblemPreset {
  final String label;
  final Map<String, dynamic> input;

  const ProblemPreset({required this.label, required this.input});

  Map<String, dynamic> toJson() => {
        'label': label,
        'input': _encodeInput(input),
      };

  factory ProblemPreset.fromJson(Map<String, dynamic> json) {
    return ProblemPreset(
      label: json['label'] as String? ?? '',
      input: Map<String, dynamic>.from(json['input'] as Map? ?? const {}),
    );
  }

  static Map<String, dynamic> _encodeInput(Map<String, dynamic> input) {
    return input.map((key, value) => MapEntry(key, _encodeValue(value)));
  }

  static dynamic _encodeValue(dynamic value) {
    if (value is List) {
      return value.map(_encodeValue).toList();
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry('$k', _encodeValue(v)));
    }
    return value;
  }
}

/// 热题 100 中一道题的完整描述符
///
/// 网络 / 快照只提供题号、中文标题、难度、分组与题面；
/// 代码、预置输入、输入描述与步骤脚本均由本地提供。
class ProblemEntry {
  final String titleSlug;
  final int number;
  final String title;
  final ProblemDifficulty difficulty;
  final String groupSlug;
  final String patternId;
  final String code;
  final List<ProblemPreset> presets;
  final InputSchema inputSchema;
  final int maxInputSize;
  final int maxFrames;

  /// 步骤脚本 (本地实现, 不参与 JSON 序列化)
  final ProblemScript? script;

  /// 中文题面 HTML (懒加载, 可能为空)
  final String? statementHtml;

  const ProblemEntry({
    required this.titleSlug,
    required this.number,
    required this.title,
    required this.difficulty,
    required this.groupSlug,
    required this.patternId,
    required this.code,
    required this.presets,
    required this.inputSchema,
    required this.maxInputSize,
    required this.maxFrames,
    this.script,
    this.statementHtml,
  });

  String get id => titleSlug;

  ProblemEntry copyWith({
    String? titleSlug,
    int? number,
    String? title,
    ProblemDifficulty? difficulty,
    String? groupSlug,
    String? patternId,
    String? code,
    List<ProblemPreset>? presets,
    InputSchema? inputSchema,
    int? maxInputSize,
    int? maxFrames,
    ProblemScript? script,
    String? statementHtml,
  }) {
    return ProblemEntry(
      titleSlug: titleSlug ?? this.titleSlug,
      number: number ?? this.number,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
      groupSlug: groupSlug ?? this.groupSlug,
      patternId: patternId ?? this.patternId,
      code: code ?? this.code,
      presets: presets ?? this.presets,
      inputSchema: inputSchema ?? this.inputSchema,
      maxInputSize: maxInputSize ?? this.maxInputSize,
      maxFrames: maxFrames ?? this.maxFrames,
      script: script ?? this.script,
      statementHtml: statementHtml ?? this.statementHtml,
    );
  }

  /// 用网络 / 缓存中的元数据覆盖本地条目的可变部分, 保留本地脚本与代码
  ProblemEntry applyRemote(ProblemEntry remote) {
    return copyWith(
      number: remote.number,
      title: remote.title,
      difficulty: remote.difficulty,
      groupSlug: remote.groupSlug,
      statementHtml: remote.statementHtml,
    );
  }

  Map<String, dynamic> toJson({bool includeStatement = true}) => {
        'titleSlug': titleSlug,
        'number': number,
        'title': title,
        'difficulty': difficulty.name,
        'groupSlug': groupSlug,
        'patternId': patternId,
        'code': code,
        'presets': presets.map((p) => p.toJson()).toList(),
        'maxInputSize': maxInputSize,
        'maxFrames': maxFrames,
        if (includeStatement && statementHtml != null) 'statementHtml': statementHtml,
      };

  factory ProblemEntry.fromJson(Map<String, dynamic> json) {
    final rawPresets = json['presets'] as List? ?? const [];
    return ProblemEntry(
      titleSlug: json['titleSlug'] as String,
      number: (json['number'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      difficulty: ProblemDifficulty.fromName(json['difficulty'] as String? ?? 'medium'),
      groupSlug: json['groupSlug'] as String? ?? '',
      patternId: json['patternId'] as String? ?? 'array-basic',
      code: json['code'] as String? ?? '',
      presets: [
        for (final p in rawPresets)
          ProblemPreset.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      inputSchema: const InputSchema(fields: []),
      maxInputSize: (json['maxInputSize'] as num?)?.toInt() ?? 0,
      maxFrames: (json['maxFrames'] as num?)?.toInt() ?? 2000,
      statementHtml: json['statementHtml'] as String?,
    );
  }
}
