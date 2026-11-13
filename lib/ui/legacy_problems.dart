import '../algorithms/base.dart';
import '../catalog/problem_entry.dart';

/// 基础算法 (冒泡/快排/DFS/BFS) 的源码与预置用例
///
/// 这些内容属于题目描述符, 不再由播放页按名称硬编码。

const String bubbleSortCode = '''void bubbleSort(List<int> arr) {
  final n = arr.length;
  for (int i = 0; i < n - 1; i++) {
    for (int j = 0; j < n - i - 1; j++) {
      if (arr[j] > arr[j + 1]) {
        final temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
      }
    }
  }
}''';

const String quickSortCode = '''int quickSort(List<int> arr, int low, int high) {
  if (low < high) {
    final pi = partition(arr, low, high);
    quickSort(arr, low, pi - 1);
    quickSort(arr, pi + 1, high);
  }
  return 0;
}

int partition(List<int> arr, int low, int high) {
  final pivot = arr[high];
  var i = low - 1;
  for (int j = low; j < high; j++) {
    if (arr[j] < pivot) {
      i++;
      final temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }
  final temp = arr[i + 1];
  arr[i + 1] = arr[high];
  arr[high] = temp;
  return i + 1;
}''';

const String dfsCode = '''void dfs(TreeNode? node) {
  if (node == null) return;
  visit(node);
  dfs(node.left);
  dfs(node.right);
}''';

const String bfsCode = '''void bfs(TreeNode? root) {
  if (root == null) return;
  final queue = <TreeNode>[root];
  while (queue.isNotEmpty) {
    final node = queue.removeAt(0);
    visit(node);
    if (node.left != null) {
      queue.add(node.left!);
    }
    if (node.right != null) {
      queue.add(node.right!);
    }
  }
}''';

const Map<String, String> _legacyCode = {
  '冒泡排序': bubbleSortCode,
  '快速排序': quickSortCode,
  'DFS 深度优先遍历': dfsCode,
  'BFS 广度优先遍历': bfsCode,
};

List<ProblemPreset> _numberPresets() => const [
      ProblemPreset(label: '逆序 [5,4,3,2,1]', input: {'arr': [5, 4, 3, 2, 1]}),
      ProblemPreset(label: '已排序 [1,2,3,4,5]', input: {'arr': [1, 2, 3, 4, 5]}),
      ProblemPreset(label: '有重复 [3,1,4,1,5]', input: {'arr': [3, 1, 4, 1, 5]}),
      ProblemPreset(
          label: '随机 [9,7,5,3,1,8,6,2,4]',
          input: {
            'arr': [9, 7, 5, 3, 1, 8, 6, 2, 4],
          }),
      ProblemPreset(label: '单元素 [42]', input: {'arr': [42]}),
    ];

List<ProblemPreset> _treePresets() => const [
      ProblemPreset(
          label: '满二叉树 [1,2,3,4,5,6,7]',
          input: {
            'arr': [1, 2, 3, 4, 5, 6, 7],
          }),
      ProblemPreset(
          label: '稀疏 [1,2,3,-1,4,-1,5]',
          input: {
            'arr': [1, 2, 3, -1, 4, -1, 5],
          }),
      ProblemPreset(
          label: '左斜链 [1,2,-1,3]',
          input: {
            'arr': [1, 2, -1, 3],
          }),
      ProblemPreset(
          label: '随机 [8,3,10,1,6,-1,14]',
          input: {
            'arr': [8, 3, 10, 1, 6, -1, 14],
          }),
      ProblemPreset(label: '单节点 [42]', input: {'arr': [42]}),
    ];

/// 把基础算法包装成统一的题目描述符, 供播放页复用同一套布局
ProblemEntry legacyProblem(AlgorithmVisualizer visualizer) {
  final isTree = visualizer.category == 'tree';
  return ProblemEntry(
    titleSlug: 'legacy-${visualizer.name}',
    number: 0,
    title: visualizer.name,
    difficulty: ProblemDifficulty.easy,
    groupSlug: visualizer.category,
    patternId: isTree ? 'binary-tree' : 'array-basic',
    code: _legacyCode[visualizer.name] ?? '// 暂无代码',
    presets: isTree ? _treePresets() : _numberPresets(),
    inputSchema: visualizer.inputSchema,
    maxInputSize: visualizer.maxInputSize,
    maxFrames: 2000,
    script: visualizer.visualize,
    statementHtml: '<p>${visualizer.description}</p>',
  );
}
