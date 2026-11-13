import 'package:material_ui/material_ui.dart';

/// 把题库返回的 HTML 题面转换为纯文本
///
/// 当前 Flutter SDK 与 flutter_html 3.0.0 不兼容, 按设计预留方案
/// 退化为白名单标签转换 + 纯文本展示, 保证不出现原始标签。
String htmlToPlainText(String html) {
  var text = html
      .replaceAll(RegExp(r'<(script|style)[^>]*>[\s\S]*?</\1>', caseSensitive: false), '')
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<sup[^>]*>', caseSensitive: false), '^')
      .replaceAll(RegExp(r'<sub[^>]*>', caseSensitive: false), '_')
      .replaceAll(
        RegExp(r'</(p|div|pre|li|ul|ol|tr|h[1-6]|table)\s*>', caseSensitive: false),
        '\n\n',
      )
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '· ')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&amp;', '&');

  text = text.replaceAllMapped(
    RegExp(r'&#(x?)([0-9a-fA-F]+);'),
    (match) {
      final code = int.tryParse(
        match.group(2)!,
        radix: match.group(1)!.isEmpty ? 10 : 16,
      );
      return code == null ? match.group(0)! : String.fromCharCode(code);
    },
  );

  return text
      .split('\n')
      .map((line) => line.trimRight())
      .join('\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

/// 题面纯文本展示
class StatementText extends StatelessWidget {
  final String html;

  const StatementText({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    return Text(
      htmlToPlainText(html),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
    );
  }
}
