import 'package:algorithm_visual/core/scene/input_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputField 工厂', () {
    test('array 字段带最大长度', () {
      final f = InputField.array('arr', maxLength: 50, label: '数组');
      expect(f.type, InputFieldType.array);
      expect(f.maxLength, 50);
      expect(f.label, '数组');
    });

    test('int 字段带取值范围', () {
      final f = InputField.int('k', minValue: 1, maxValue: 9);
      expect(f.type, InputFieldType.int);
      expect(f.minValue, 1);
      expect(f.maxValue, 9);
      expect(f.label, 'k');
    });

    test('string 字段带最大长度', () {
      final f = InputField.string('word', maxLength: 20, label: '单词');
      expect(f.type, InputFieldType.string);
      expect(f.maxLength, 20);
      expect(f.label, '单词');
    });

    test('matrix 字段带行列上限', () {
      final f = InputField.matrix('grid', maxRows: 10, maxCols: 12, label: '矩阵');
      expect(f.type, InputFieldType.matrix);
      expect(f.maxRows, 10);
      expect(f.maxCols, 12);
      expect(f.label, '矩阵');
    });
  });

  group('InputSchema', () {
    test('按名称查找字段', () {
      final schema = InputSchema(
        fields: [
          InputField.matrix('grid', maxRows: 4, maxCols: 4),
          InputField.string('word', maxLength: 10),
        ],
      );
      expect(schema.findField('grid')!.type, InputFieldType.matrix);
      expect(schema.findField('word')!.type, InputFieldType.string);
      expect(schema.findField('missing'), isNull);
    });

    test('多字段组合保留顺序', () {
      final schema = InputSchema(
        fields: [
          InputField.array('weights', maxLength: 30),
          InputField.array('values', maxLength: 30),
          InputField.int('capacity', minValue: 1, maxValue: 1000),
        ],
      );
      expect(schema.fields.map((f) => f.name).toList(), ['weights', 'values', 'capacity']);
    });
  });
}
