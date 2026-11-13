import 'package:algorithm_visual/algorithms/tree/bfs_traversal.dart';
import 'package:algorithm_visual/algorithms/tree/dfs_traversal.dart';
import 'package:algorithm_visual/algorithms/tree/level_order_tree.dart';
import 'package:algorithm_visual/core/scene/action.dart';
import 'package:algorithm_visual/core/scene/element.dart';
import 'package:algorithm_visual/core/scene/scene_frame.dart';
import 'package:flutter_test/flutter_test.dart';

/// 从帧序列中提取节点的访问顺序 (去重, 按首次 Mark(visited) 出现的顺序)
List<int> visitedOrder(List<SceneFrame> frames) {
  final seen = <String>{};
  final order = <int>[];
  for (final frame in frames) {
    final dataById = {
      for (final e in frame.elements.whereType<TreeNode>()) e.id: e.data as int,
    };
    for (final action in frame.actions) {
      if (action is Mark &&
          action.state == 'visited' &&
          !seen.contains(action.targetId)) {
        seen.add(action.targetId);
        order.add(dataById[action.targetId]!);
      }
    }
  }
  return order;
}

void main() {
  group('LevelOrderTree', () {
    test('按堆式下标建立父子关系', () {
      final tree = LevelOrderTree.fromArray([1, 2, 3, -1, 4]);
      expect(tree.nodeCount, 4);
      expect(tree.valueOf(tree.rootPos), 1);
      expect(tree.leftOf(0), 1);
      expect(tree.rightOf(0), 2);
      expect(tree.leftOf(1), null);
      expect(tree.rightOf(1), 4);
    });

    test('空位之后的位置会被忽略', () {
      // 位置 0=1, 1=空, 2=3, 3=4 (3 的父位置 1 为空 -> 忽略)
      final tree = LevelOrderTree.fromArray([1, -1, 3, 4]);
      expect(tree.nodeCount, 2);
      expect(tree.levelOrder, [0, 2]);
    });

    test('坐标互不重叠', () {
      final tree = LevelOrderTree.fromArray([1, 2, 3, 4, 5, 6, 7]);
      final points = tree.toElements().map((e) => e.position).toList();
      final unique = points.map((p) => '${p.x},${p.y}').toSet();
      expect(unique.length, points.length);
      // 根节点 y = 0
      final root = tree.toElements().firstWhere((e) => e.id == tree.idOf(0));
      expect(root.position.y, 0);
    });

    test('根节点为空位时报错', () {
      expect(() => LevelOrderTree.fromArray([-1, 1]), throwsArgumentError);
    });

    test('非法负值时(小于 -1)报错', () {
      expect(() => LevelOrderTree.fromArray([1, -2]), throwsArgumentError);
    });
  });

  group('DfsTraversalVisualizer', () {
    late DfsTraversalVisualizer algo;

    setUp(() {
      algo = DfsTraversalVisualizer();
    });

    test('declares correct metadata', () {
      expect(algo.name, 'DFS 深度优先遍历');
      expect(algo.category, 'tree');
      expect(algo.maxInputSize, 31);
    });

    test('前序访问顺序正确', () {
      // 树结构: 1 -> 左 2 (右 4), 右 3
      final frames = algo.visualize({
        'arr': [1, 2, 3, -1, 4]
      });
      expect(visitedOrder(frames), [1, 2, 4, 3]);
    });

    test('每一帧都有树节点元素', () {
      final frames = algo.visualize({
        'arr': [1, 2, 3]
      });
      for (final frame in frames) {
        expect(frame.elements.whereType<TreeNode>(), isNotEmpty,
            reason: 'frame ${frame.frameId} should have tree nodes');
      }
    });

    test('首帧为初始状态, 末帧记录访问顺序', () {
      final frames = algo.visualize({
        'arr': [1, 2, 3]
      });
      expect(frames.first.caption, contains('初始二叉树'));
      expect(frames.first.actions, isEmpty);
      expect(frames.last.caption, contains('遍历完成'));
      expect(frames.last.caption, contains('1 → 2 → 3'));
    });

    test('访问帧携带代码行号', () {
      final frames = algo.visualize({
        'arr': [1, 2, 3]
      });
      final withLine = frames.where((f) => f.currentLine != null).toList();
      expect(withLine, isNotEmpty);
    });

    test('throws on empty input', () {
      expect(() => algo.visualize({'arr': []}), throwsArgumentError);
    });

    test('throws when input exceeds maxInputSize', () {
      final big = List<int>.filled(32, 1);
      expect(() => algo.visualize({'arr': big}), throwsArgumentError);
    });

    test('throws when root position is empty', () {
      expect(() => algo.visualize({'arr': [-1, 1]}), throwsArgumentError);
    });
  });

  group('BfsTraversalVisualizer', () {
    late BfsTraversalVisualizer algo;

    setUp(() {
      algo = BfsTraversalVisualizer();
    });

    test('declares correct metadata', () {
      expect(algo.name, 'BFS 广度优先遍历');
      expect(algo.category, 'tree');
      expect(algo.maxInputSize, 31);
    });

    test('层序访问顺序正确', () {
      final frames = algo.visualize({
        'arr': [1, 2, 3, -1, 4]
      });
      expect(visitedOrder(frames), [1, 2, 3, 4]);
    });

    test('出队帧与入队帧都有代码行号', () {
      final frames = algo.visualize({
        'arr': [1, 2, 3]
      });
      final lines = frames.map((f) => f.currentLine).whereType<int>().toSet();
      expect(lines, containsAll(<int>[6, 8, 11]));
    });

    test('throws on empty input', () {
      expect(() => algo.visualize({'arr': []}), throwsArgumentError);
    });

    test('throws when input exceeds maxInputSize', () {
      final big = List<int>.filled(32, 1);
      expect(() => algo.visualize({'arr': big}), throwsArgumentError);
    });
  });
}
