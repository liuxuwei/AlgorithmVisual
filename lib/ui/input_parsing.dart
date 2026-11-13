import '../core/scene/input_schema.dart';

/// 单个输入字段的解析结果 (value 与 error 二者其一非空)
class ParsedField {
  final dynamic value;
  final String? error;

  const ParsedField.ok(this.value) : error = null;

  const ParsedField.fail(this.error) : value = null;

  bool get hasError => error != null;
}

/// 按字段声明解析用户输入, 并做类型与规模校验
ParsedField parseInputField(InputField field, String text) {
  final trimmed = text.trim();
  switch (field.type) {
    case InputFieldType.array:
      return _parseArray(field, trimmed);
    case InputFieldType.int:
      return _parseInt(field, trimmed);
    case InputFieldType.string:
      return _parseString(field, trimmed);
    case InputFieldType.matrix:
      return _parseMatrix(field, trimmed);
    case InputFieldType.map:
      return _parseString(field, trimmed);
  }
}

/// 输入框提示文本
String hintOf(InputField field) {
  switch (field.type) {
    case InputFieldType.array:
      return '输入数组, 逗号分隔: 1,2,3,4,5';
    case InputFieldType.int:
      return '输入整数';
    case InputFieldType.string:
      return '输入文本';
    case InputFieldType.matrix:
      return '行用分号分隔, 单元格用逗号: 1,2;3,4';
    case InputFieldType.map:
      return '输入文本';
  }
}

ParsedField _parseArray(InputField field, String text) {
  if (text.isEmpty) {
    return const ParsedField.fail('请输入数组, 用逗号分隔');
  }
  final parts = text.split(RegExp(r'[\s,，]+'));
  final values = <int>[];
  for (final part in parts) {
    final value = int.tryParse(part);
    if (value == null) {
      return const ParsedField.fail('请输入有效数字, 用逗号分隔');
    }
    values.add(value);
  }
  final maxLength = field.maxLength;
  if (maxLength != null && values.length > maxLength) {
    return ParsedField.fail('超过最大长度 $maxLength');
  }
  return ParsedField.ok(values);
}

ParsedField _parseInt(InputField field, String text) {
  if (text.isEmpty) {
    return const ParsedField.fail('请输入整数');
  }
  final value = int.tryParse(text);
  if (value == null) {
    return const ParsedField.fail('请输入有效整数');
  }
  final min = field.minValue;
  final max = field.maxValue;
  if ((min != null && value < min) || (max != null && value > max)) {
    if (min != null && max != null) {
      return ParsedField.fail('超出范围 [$min, $max]');
    }
    if (min != null) return ParsedField.fail('不能小于 $min');
    return ParsedField.fail('不能大于 $max');
  }
  return ParsedField.ok(value);
}

ParsedField _parseString(InputField field, String text) {
  if (text.isEmpty) {
    return const ParsedField.fail('请输入内容');
  }
  final maxLength = field.maxLength;
  if (maxLength != null && text.length > maxLength) {
    return ParsedField.fail('超过最大长度 $maxLength');
  }
  return ParsedField.ok(text);
}

ParsedField _parseMatrix(InputField field, String text) {
  if (text.isEmpty) {
    return const ParsedField.fail('请输入矩阵, 行用分号分隔');
  }
  final rows = text
      .split(RegExp(r'[;；\n]'))
      .map((row) => row.trim())
      .where((row) => row.isNotEmpty)
      .toList();
  if (rows.isEmpty) {
    return const ParsedField.fail('请输入矩阵, 行用分号分隔');
  }

  final grid = <List<int>>[];
  for (final row in rows) {
    final cells = row.split(RegExp(r'[\s,，]+')).where((c) => c.isNotEmpty);
    final values = <int>[];
    for (final cell in cells) {
      final value = int.tryParse(cell);
      if (value == null) {
        return const ParsedField.fail('请输入有效的整数矩阵');
      }
      values.add(value);
    }
    if (values.isEmpty) {
      return const ParsedField.fail('请输入有效的整数矩阵');
    }
    grid.add(values);
  }

  final cols = grid.first.length;
  if (grid.any((row) => row.length != cols)) {
    return const ParsedField.fail('每行元素数量必须一致');
  }
  final maxRows = field.maxRows;
  if (maxRows != null && grid.length > maxRows) {
    return ParsedField.fail('超过最大行数 $maxRows');
  }
  final maxCols = field.maxCols;
  if (maxCols != null && cols > maxCols) {
    return ParsedField.fail('超过最大列数 $maxCols');
  }
  return ParsedField.ok(grid);
}
