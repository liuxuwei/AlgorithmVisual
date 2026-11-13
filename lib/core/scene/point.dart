/// 纯 Dart 二维坐标点 (替代 Flutter 的 Offset, 避免 scene 层依赖 Flutter)
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  Point copyWith({double? x, double? y}) =>
      Point(x ?? this.x, y ?? this.y);
}
