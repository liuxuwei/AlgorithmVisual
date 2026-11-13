import '../catalog/problem_entry.dart';
import '../core/scene/action.dart';
import '../core/scene/element.dart';
import '../core/scene/input_schema.dart';
import '../core/scene/point.dart';
import '../core/scene/scene_frame.dart';

/// 把源码拆成行, 通过内容标记定位行号, 避免手写行号漂移
class CodeLines {
  CodeLines(String source) : _lines = source.split('\n');

  final List<String> _lines;

  int operator [](String marker) {
    final index = _lines.indexWhere((line) => line.contains(marker));
    if (index < 0) {
      throw ArgumentError('代码中未找到标记: $marker');
    }
    return index + 1;
  }

  int get lineCount => _lines.length;
}

/// 收集帧并做规模保护: 超过上限立即抛错, 避免内存峰值
class FrameCollector {
  FrameCollector({this.maxFrames = 2000});

  final int maxFrames;
  final List<SceneFrame> _frames = [];

  void add({
    String caption = '',
    required List<Element> elements,
    List<Action> actions = const [],
    int? currentLine,
    List<int>? activeLines,
  }) {
    if (_frames.length >= maxFrames) {
      throw ArgumentError('帧数超过上限 $maxFrames');
    }
    _frames.add(SceneFrame(
      frameId: _frames.length,
      caption: caption,
      elements: elements,
      actions: actions,
      currentLine: currentLine,
      activeLines: activeLines,
    ));
  }

  int get length => _frames.length;

  List<SceneFrame> build() => List<SceneFrame>.unmodifiable(_frames);
}

// ---------------------------------------------------------------------------
// 输入解析
// ---------------------------------------------------------------------------

List<int> intList(dynamic value) {
  if (value is List) {
    return [for (final item in value) (item as num).toInt()];
  }
  return const [];
}

List<List<int>> intMatrix(dynamic value) {
  if (value is List) {
    return [
      for (final row in value)
        if (row is List) [for (final item in row) (item as num).toInt()],
    ];
  }
  return const [];
}

List<String> stringList(dynamic value) {
  if (value is List) return [for (final item in value) '$item'];
  return const [];
}

/// 二叉树输入: -1 表示空位, 转换为 null
List<int?> treeInput(dynamic value) {
  return [for (final v in intList(value)) v == -1 ? null : v];
}

int intOf(dynamic value, [int fallback = 0]) {
  return value is num ? value.toInt() : fallback;
}

String strOf(dynamic value, [String fallback = '']) {
  return value == null ? fallback : '$value';
}

List<String> splitWords(String text) {
  return text
      .split(RegExp(r'[\s,，]+'))
      .where((part) => part.trim().isNotEmpty)
      .map((part) => part.trim())
      .toList();
}

/// 字符网格输入: 支持字符串列表或 "11000/11000/00100" 形式
List<List<String>> gridOfChars(dynamic value) {
  final rows = value is List
      ? [for (final row in value) '$row']
      : strOf(value).split(RegExp(r'[/;|]'));
  return [
    for (final row in rows)
      if (row.trim().isNotEmpty) row.trim().split(''),
  ];
}

void checkSize(int size, int maxInputSize, [String name = '输入']) {
  if (size > maxInputSize) {
    throw ArgumentError('$name 规模 $size 超过上限 $maxInputSize');
  }
}

// ---------------------------------------------------------------------------
// 基础构件
// ---------------------------------------------------------------------------

List<Element> barElements(List<int> values) {
  return [
    for (var i = 0; i < values.length; i++)
      ArrayBar(
        id: 'bar_$i',
        position: Point(i.toDouble(), 0),
        value: values[i],
        index: i,
      ),
  ];
}

List<Element> textRowElements(List<String> items, {int row = 0}) {
  return [
    for (var i = 0; i < items.length; i++)
      MatrixCell(
        id: 'm_${row}_$i',
        position: Point(i.toDouble(), row.toDouble()),
        row: row,
        col: i,
        value: items[i],
      ),
  ];
}

String barId(int index) => 'bar_$index';
String cellId(int row, int col) => 'm_${row}_$col';
String dpId(int row, int col) => 'dp_${row}_$col';

Action pointerTo(String label, String targetId) =>
    Pointer(targetId: targetId, label: label);

/// 过滤掉值为 null / 空串的指针条目, 便于链表中可选指针的组装
Map<String, String> livePointers(Map<String, String?> entries) {
  return {
    for (final entry in entries.entries)
      if (entry.value != null && entry.value!.isNotEmpty)
        entry.key: entry.value!,
  };
}

Action rangeTo(String label, String startId, String endId) =>
    Range(targetId: startId, label: label, startId: startId, endId: endId);

// ---------------------------------------------------------------------------
// 数组场景
// ---------------------------------------------------------------------------

class ArrayScene {
  ArrayScene(this.collector, this.values, this.code) : lines = CodeLines(code);

  final FrameCollector collector;
  final List<int> values;
  final String code;
  final CodeLines lines;

  int get length => values.length;

  void show(
    String caption, {
    String? line,
    Map<String, int> pointers = const {},
    Set<int> highlight = const {},
    Set<int> sorted = const {},
    int? rangeStart,
    int? rangeEnd,
    String rangeLabel = '',
  }) {
    final actions = <Action>[
      for (final entry in pointers.entries)
        if (entry.value >= 0 && entry.value < values.length)
          pointerTo(entry.key, barId(entry.value)),
      for (final index in highlight)
        if (index >= 0 && index < values.length)
          Highlight(targetId: barId(index)),
      for (final index in sorted)
        if (index >= 0 && index < values.length)
          Mark(targetId: barId(index), state: 'sorted'),
    ];
    if (rangeStart != null && rangeEnd != null) {
      actions.add(rangeTo(rangeLabel, barId(rangeStart), barId(rangeEnd)));
    }
    collector.add(
      caption: caption,
      elements: barElements(values),
      actions: actions,
      currentLine: line == null ? null : lines[line],
    );
  }
}

/// 字符 / 字符串数组场景 (一行矩阵格子)
class TextRowScene {
  TextRowScene(this.collector, this.items, this.code) : lines = CodeLines(code);

  final FrameCollector collector;
  final List<String> items;
  final String code;
  final CodeLines lines;

  int get length => items.length;

  void show(
    String caption, {
    String? line,
    Map<String, int> pointers = const {},
    Set<int> highlight = const {},
    Set<int> visited = const {},
    int? rangeStart,
    int? rangeEnd,
    String rangeLabel = '',
  }) {
    final actions = <Action>[
      for (final entry in pointers.entries)
        if (entry.value >= 0 && entry.value < items.length)
          pointerTo(entry.key, cellId(0, entry.value)),
      for (final index in highlight)
        if (index >= 0 && index < items.length)
          Highlight(targetId: cellId(0, index)),
      for (final index in visited)
        if (index >= 0 && index < items.length)
          Mark(targetId: cellId(0, index), state: 'visited'),
    ];
    if (rangeStart != null && rangeEnd != null) {
      actions.add(
        rangeTo(rangeLabel, cellId(0, rangeStart), cellId(0, rangeEnd)),
      );
    }
    collector.add(
      caption: caption,
      elements: textRowElements(items),
      actions: actions,
      currentLine: line == null ? null : lines[line],
    );
  }
}

// ---------------------------------------------------------------------------
// 链表场景
// ---------------------------------------------------------------------------

class ListNodeSpec {
  ListNodeSpec(
    this.id,
    this.value, {
    this.nextId,
    this.prevId,
    this.randomId,
    this.visible = true,
  });

  final String id;
  int value;
  String? nextId;
  String? prevId;
  String? randomId;
  bool visible;
}

/// 生成一条 id 以 prefix 开头的链
List<ListNodeSpec> chain(List<int> values, {String prefix = 'n'}) {
  return [
    for (var i = 0; i < values.length; i++)
      ListNodeSpec(
        '$prefix$i',
        values[i],
        nextId: i + 1 < values.length ? '$prefix${i + 1}' : null,
      ),
  ];
}

class ListScene {
  ListScene(this.collector, this.nodes, this.code) : lines = CodeLines(code);

  final FrameCollector collector;
  final List<ListNodeSpec> nodes;
  final String code;
  final CodeLines lines;

  ListNodeSpec byId(String id) => nodes.firstWhere((n) => n.id == id);

  void setNext(String id, String? nextId) => byId(id).nextId = nextId;

  /// 取下一个节点 id, 空指针返回 null
  String? nextOf(String? id) => id == null ? null : byId(id).nextId;

  /// 取节点值
  int valueOf(String id) => byId(id).value;

  void show(
    String caption, {
    String? line,
    Map<String, String> pointers = const {},
    Set<String> highlight = const {},
    Set<String> visited = const {},
  }) {
    final actions = <Action>[
      for (final entry in pointers.entries)
        pointerTo(entry.key, entry.value),
      for (final id in highlight) Highlight(targetId: id),
      for (final id in visited) Mark(targetId: id, state: 'visited'),
    ];
    collector.add(
      caption: caption,
      elements: [
        for (final node in nodes)
          if (node.visible)
            LinkedListNode(
              id: node.id,
              position: const Point(0, 0),
              data: node.value,
              nextId: node.nextId,
              prevId: node.prevId,
              randomId: node.randomId,
            ),
      ],
      actions: actions,
      currentLine: line == null ? null : lines[line],
    );
  }
}

// ---------------------------------------------------------------------------
// 二叉树场景
// ---------------------------------------------------------------------------

class TreeScene {
  TreeScene(this.collector, List<int?> raw, this.code) : lines = CodeLines(code) {
    _build(raw);
  }

  final FrameCollector collector;
  final String code;
  final CodeLines lines;

  final Map<int, int> _values = {};
  final Map<int, int?> _left = {};
  final Map<int, int?> _right = {};
  final Map<int, Point> _positions = {};
  final Map<int, int?> _parent = {};

  void _build(List<int?> raw) {
    if (raw.isEmpty || raw[0] == null) {
      throw ArgumentError('树不能为空');
    }
    final all = <int, int>{};
    for (var i = 0; i < raw.length; i++) {
      final value = raw[i];
      if (value != null) all[i] = value;
    }
    final queue = <int>[0];
    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      final value = all[pos];
      if (value == null) continue;
      _values[pos] = value;
      queue.addAll([2 * pos + 1, 2 * pos + 2]);
    }
    for (final pos in _values.keys) {
      _left[pos] = null;
      _right[pos] = null;
    }
    for (final pos in _values.keys) {
      if (pos == 0) continue;
      final parent = (pos - 1) ~/ 2;
      if (!_values.containsKey(parent)) continue;
      _parent[pos] = parent;
      if (pos.isOdd) {
        _left[parent] = pos;
      } else {
        _right[parent] = pos;
      }
    }

    var column = 0;
    void assign(int pos, int depth) {
      final l = _left[pos];
      if (l != null) assign(l, depth + 1);
      _positions[pos] = Point(column.toDouble(), depth.toDouble());
      column++;
      final r = _right[pos];
      if (r != null) assign(r, depth + 1);
    }

    assign(0, 0);
  }

  int get rootPos => 0;
  int get nodeCount => _values.length;
  int valueOf(int pos) => _values[pos]!;
  int? leftOf(int pos) => _left[pos];
  int? rightOf(int pos) => _right[pos];
  int? parentOf(int pos) => _parent[pos];
  String idOf(int pos) => 'node_$pos';

  /// 交换左右子树 (用于翻转二叉树)
  void swapChildren(int pos) {
    final left = _left[pos];
    _left[pos] = _right[pos];
    _right[pos] = left;
  }

  /// 修改子节点 (用于展开链表等结构变化)
  void setChildren(int pos, {int? left, int? right, bool changeLeft = true, bool changeRight = true}) {
    if (changeLeft) _left[pos] = left;
    if (changeRight) _right[pos] = right;
  }

  /// 结构变化后重新计算布局坐标
  void relayout() {
    _positions.clear();
    var column = 0;
    void assign(int pos, int depth) {
      final l = _left[pos];
      if (l != null) assign(l, depth + 1);
      _positions[pos] = Point(column.toDouble(), depth.toDouble());
      column++;
      final r = _right[pos];
      if (r != null) assign(r, depth + 1);
    }

    assign(rootPos, 0);
  }

  List<int> get levelOrder {
    final order = <int>[];
    final queue = <int>[rootPos];
    while (queue.isNotEmpty) {
      final pos = queue.removeAt(0);
      order.add(pos);
      final l = _left[pos];
      final r = _right[pos];
      if (l != null) queue.add(l);
      if (r != null) queue.add(r);
    }
    return order;
  }

  List<int> get preorder {
    final order = <int>[];
    void walk(int pos) {
      order.add(pos);
      final l = _left[pos];
      final r = _right[pos];
      if (l != null) walk(l);
      if (r != null) walk(r);
    }

    walk(rootPos);
    return order;
  }

  List<int> get inorder {
    final order = <int>[];
    void walk(int pos) {
      final l = _left[pos];
      if (l != null) walk(l);
      order.add(pos);
      final r = _right[pos];
      if (r != null) walk(r);
    }

    walk(rootPos);
    return order;
  }

  int depthOf(int pos) {
    var depth = 0;
    var current = pos;
    while (parentOf(current) != null) {
      current = parentOf(current)!;
      depth++;
    }
    return depth;
  }

  List<Element> elements() {
    return [
      for (final entry in _positions.entries)
        TreeNode(
          id: idOf(entry.key),
          position: entry.value,
          data: _values[entry.key]!,
          leftId: _left[entry.key] == null ? null : idOf(_left[entry.key]!),
          rightId: _right[entry.key] == null ? null : idOf(_right[entry.key]!),
        ),
    ];
  }

  void show(
    String caption, {
    String? line,
    Set<int> highlight = const {},
    Set<int> visited = const {},
    Map<String, int> pointers = const {},
  }) {
    collector.add(
      caption: caption,
      elements: elements(),
      actions: [
        for (final pos in highlight) Highlight(targetId: idOf(pos)),
        for (final pos in visited) Mark(targetId: idOf(pos), state: 'visited'),
        for (final entry in pointers.entries)
          pointerTo(entry.key, idOf(entry.value)),
      ],
      currentLine: line == null ? null : lines[line],
    );
  }
}

// ---------------------------------------------------------------------------
// 矩阵场景
// ---------------------------------------------------------------------------

class GridScene {
  GridScene(this.collector, this.grid, this.code) : lines = CodeLines(code);

  final FrameCollector collector;
  final List<List<dynamic>> grid;
  final String code;
  final CodeLines lines;

  int get rows => grid.length;
  int get cols => grid.isEmpty ? 0 : grid.first.length;

  void set(int row, int col, dynamic value) {
    grid[row][col] = value;
  }

  void show(
    String caption, {
    String? line,
    Map<String, (int, int)> pointers = const {},
    Set<(int, int)> highlight = const {},
    Set<(int, int)> visited = const {},
    Set<(int, int)> path = const {},
    (int, int)? rangeStart,
    (int, int)? rangeEnd,
    String rangeLabel = '',
  }) {
    final actions = <Action>[
      for (final entry in pointers.entries)
        pointerTo(entry.key, cellId(entry.value.$1, entry.value.$2)),
      for (final cell in highlight)
        Highlight(targetId: cellId(cell.$1, cell.$2)),
      for (final cell in visited)
        Mark(targetId: cellId(cell.$1, cell.$2), state: 'visited'),
      for (final cell in path)
        Mark(targetId: cellId(cell.$1, cell.$2), state: 'path'),
    ];
    if (rangeStart != null && rangeEnd != null) {
      actions.add(rangeTo(
        rangeLabel,
        cellId(rangeStart.$1, rangeStart.$2),
        cellId(rangeEnd.$1, rangeEnd.$2),
      ));
    }
    collector.add(
      caption: caption,
      elements: [
        for (var r = 0; r < rows; r++)
          for (var c = 0; c < grid[r].length; c++)
            MatrixCell(
              id: cellId(r, c),
              position: Point(c.toDouble(), r.toDouble()),
              row: r,
              col: c,
              value: grid[r][c],
              state: visited.contains((r, c))
                  ? 'visited'
                  : (path.contains((r, c)) ? 'path' : null),
            ),
      ],
      actions: actions,
      currentLine: line == null ? null : lines[line],
    );
  }
}

// ---------------------------------------------------------------------------
// 动态规划场景
// ---------------------------------------------------------------------------

class DpScene {
  DpScene(this.collector, this.rows, this.cols, this.code)
      : lines = CodeLines(code),
        table = List.generate(rows, (_) => List<dynamic>.filled(cols, null));

  final FrameCollector collector;
  final int rows;
  final int cols;
  final String code;
  final CodeLines lines;
  final List<List<dynamic>> table;
  final Set<(int, int)> computed = {};

  void set(int row, int col, dynamic value) {
    table[row][col] = value;
    computed.add((row, col));
  }

  void show(
    String caption, {
    String? line,
    Set<(int, int)> highlight = const {},
    Map<String, (int, int)> pointers = const {},
  }) {
    collector.add(
      caption: caption,
      elements: [
        for (var r = 0; r < rows; r++)
          for (var c = 0; c < cols; c++)
            DpCell(
              id: dpId(r, c),
              position: Point(c.toDouble(), r.toDouble()),
              row: r,
              col: c,
              value: table[r][c],
            ),
      ],
      actions: [
        for (final cell in computed)
          Mark(targetId: dpId(cell.$1, cell.$2), state: 'computed'),
        for (final cell in highlight)
          Highlight(targetId: dpId(cell.$1, cell.$2)),
        for (final entry in pointers.entries)
          pointerTo(entry.key, dpId(entry.value.$1, entry.value.$2)),
      ],
      currentLine: line == null ? null : lines[line],
    );
  }
}

// ---------------------------------------------------------------------------
// 栈 / 哈希场景
// ---------------------------------------------------------------------------

class StackScene {
  StackScene(this.collector, this.code) : lines = CodeLines(code);

  final FrameCollector collector;
  final String code;
  final CodeLines lines;
  final List<dynamic> items = [];

  void push(dynamic value) => items.add(value);

  void pop() {
    if (items.isNotEmpty) items.removeLast();
  }

  void clear() => items.clear();

  void show(
    String caption, {
    String? line,
    Map<String, int> pointers = const {},
    Set<int> highlight = const {},
    Set<int> visited = const {},
  }) {
    collector.add(
      caption: caption,
      elements: [
        for (var i = 0; i < items.length; i++)
          StackFrame(
            id: 's_$i',
            position: Point(0, i.toDouble()),
            index: i,
            value: items[i],
          ),
      ],
      actions: [
        for (final entry in pointers.entries)
          if (entry.value >= 0 && entry.value < items.length)
            pointerTo(entry.key, 's_${entry.value}'),
        for (final index in highlight)
          if (index >= 0 && index < items.length)
            Highlight(targetId: 's_$index'),
        for (final index in visited)
          if (index >= 0 && index < items.length)
            Mark(targetId: 's_$index', state: 'visited'),
      ],
      currentLine: line == null ? null : lines[line],
    );
  }
}

class HashItem {
  HashItem(this.key, this.value, this.bucket);

  final dynamic key;
  dynamic value;
  final int bucket;
}

class HashScene {
  HashScene(this.collector, this.code) : lines = CodeLines(code);

  final FrameCollector collector;
  final String code;
  final CodeLines lines;
  final List<HashItem> items = [];

  void add(dynamic key, dynamic value, {int? bucket}) {
    items.add(HashItem(key, value, bucket ?? items.length));
  }

  void show(
    String caption, {
    String? line,
    Set<dynamic> highlightKeys = const {},
  }) {
    collector.add(
      caption: caption,
      elements: [
        for (var i = 0; i < items.length; i++)
          HashEntry(
            id: 'h_$i',
            position: Point(items[i].bucket.toDouble(), i.toDouble()),
            key: items[i].key,
            value: items[i].value,
            bucket: items[i].bucket,
          ),
      ],
      actions: [
        for (var i = 0; i < items.length; i++)
          if (highlightKeys.contains(items[i].key))
            Highlight(targetId: 'h_$i'),
      ],
      currentLine: line == null ? null : lines[line],
    );
  }
}

// ---------------------------------------------------------------------------
// 题目描述符构造
// ---------------------------------------------------------------------------

ProblemPreset preset(String label, Map<String, dynamic> input) {
  return ProblemPreset(label: label, input: input);
}

ProblemEntry buildProblem({
  required String slug,
  required int number,
  required String title,
  required ProblemDifficulty difficulty,
  required String group,
  required String pattern,
  required String code,
  required List<ProblemPreset> presets,
  required InputSchema schema,
  required ProblemScript script,
  int maxInputSize = 80,
  int maxFrames = 2000,
}) {
  return ProblemEntry(
    titleSlug: slug,
    number: number,
    title: title,
    difficulty: difficulty,
    groupSlug: group,
    patternId: pattern,
    code: code,
    presets: presets,
    inputSchema: schema,
    maxInputSize: maxInputSize,
    maxFrames: maxFrames,
    script: script,
  );
}
