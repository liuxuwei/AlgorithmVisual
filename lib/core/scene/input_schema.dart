/// 输入字段类型
enum InputFieldType { array, int, string, matrix, map }

/// 单个输入字段的描述
class InputField {
  final String name;
  final InputFieldType type;
  final String label;
  final int? maxLength; // array / string 类型的最大长度
  final int? minValue; // int 类型的最小值
  final int? maxValue; // int 类型的最大值
  final int? maxRows; // matrix 类型的最大行数
  final int? maxCols; // matrix 类型的最大列数

  const InputField({
    required this.name,
    required this.type,
    required this.label,
    this.maxLength,
    this.minValue,
    this.maxValue,
    this.maxRows,
    this.maxCols,
  });

  factory InputField.array(String name, {int? maxLength, String? label}) {
    return InputField(
      name: name,
      type: InputFieldType.array,
      label: label ?? name,
      maxLength: maxLength,
    );
  }

  factory InputField.int(String name, {int? minValue, int? maxValue, String? label}) {
    return InputField(
      name: name,
      type: InputFieldType.int,
      label: label ?? name,
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  factory InputField.string(String name, {int? maxLength, String? label}) {
    return InputField(
      name: name,
      type: InputFieldType.string,
      label: label ?? name,
      maxLength: maxLength,
    );
  }

  factory InputField.matrix(
    String name, {
    int? maxRows,
    int? maxCols,
    String? label,
  }) {
    return InputField(
      name: name,
      type: InputFieldType.matrix,
      label: label ?? name,
      maxRows: maxRows,
      maxCols: maxCols,
    );
  }
}

/// 描述算法 visualize 所需的输入结构
///
/// UI 层据此自动生成输入表单和校验逻辑
class InputSchema {
  final List<InputField> fields;

  const InputSchema({required this.fields});

  InputField? findField(String name) {
    for (final f in fields) {
      if (f.name == name) return f;
    }
    return null;
  }
}
