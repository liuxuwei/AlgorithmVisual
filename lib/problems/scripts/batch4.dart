import '../../catalog/problem_entry.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/scene_frame.dart';
import '../script_helpers.dart';

// ===========================================================================
// 二叉树 (15)
// ===========================================================================

class _TNode {
  _TNode(this.value);

  final int value;
  _TNode? left;
  _TNode? right;
}

/// 把节点树序列化为层序数组 (-1 表示空位)
List<int?> _toLevelOrder(_TNode? root) {
  if (root == null) return const [];
  final cells = <int, _TNode>{};
  var maxIndex = 0;
  void walk(_TNode? node, int index) {
    if (node == null) return;
    cells[index] = node;
    if (index > maxIndex) maxIndex = index;
    walk(node.left, 2 * index + 1);
    walk(node.right, 2 * index + 2);
  }

  walk(root, 0);
  final out = List<int?>.generate(maxIndex + 1, (_) => null);
  for (final entry in cells.entries) {
    out[entry.key] = entry.value.value;
  }
  return out;
}

/// 升序数组 -> 平衡二叉搜索树
_TNode? _buildBalanced(List<int> values, int lo, int hi) {
  if (lo > hi) return null;
  final mid = (lo + hi) ~/ 2;
  final node = _TNode(values[mid]);
  node.left = _buildBalanced(values, lo, mid - 1);
  node.right = _buildBalanced(values, mid + 1, hi);
  return node;
}

/// 前序 + 中序 -> 树
_TNode? _buildFromPreIn(
  List<int> preorder,
  Map<int, int> inIndex,
  List<int> cursor,
  int lo,
  int hi,
) {
  if (lo > hi) return null;
  final value = preorder[cursor[0]++];
  final mid = inIndex[value]!;
  final node = _TNode(value);
  node.left = _buildFromPreIn(preorder, inIndex, cursor, lo, mid - 1);
  node.right = _buildFromPreIn(preorder, inIndex, cursor, mid + 1, hi);
  return node;
}

const String inorderCode = '''class Solution {
    public List<Integer> inorderTraversal(TreeNode root) {
        List<Integer> res = new ArrayList<>();
        dfs(root, res);
        return res;
    }
    void dfs(TreeNode node, List<Integer> res) {
        if (node == null) return;
        dfs(node.left, res);
        res.add(node.val);
        dfs(node.right, res);
    }
}''';

List<SceneFrame> inorderScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, inorderCode);
  final visited = <int>{};
  final result = <int>[];

  scene.show('中序遍历: 左 → 根 → 右', line: 'dfs(node.left, res)');

  void dfs(int pos) {
    final left = scene.leftOf(pos);
    if (left != null) dfs(left);
    visited.add(pos);
    result.add(scene.valueOf(pos));
    scene.show(
      '访问 ${scene.valueOf(pos)}, 结果 = $result',
      line: 'res.add(node.val)',
      visited: visited,
      highlight: {pos},
    );
    final right = scene.rightOf(pos);
    if (right != null) dfs(right);
  }

  dfs(scene.rootPos);
  scene.show('中序遍历完成: $result', line: 'return res', visited: visited);
  return collector.build();
}

const String maxDepthCode = '''class Solution {
    public int maxDepth(TreeNode root) {
        if (root == null) return 0;
        int left = maxDepth(root.left);
        int right = maxDepth(root.right);
        return Math.max(left, right) + 1;
    }
}''';

List<SceneFrame> maxDepthScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, maxDepthCode);
  final computed = <int>{};

  scene.show('后序遍历计算每个节点的深度', line: 'if (root == null)');

  int depth(int pos) {
    final left = scene.leftOf(pos);
    final right = scene.rightOf(pos);
    final hl = left == null ? 0 : depth(left);
    final hr = right == null ? 0 : depth(right);
    final value = (hl > hr ? hl : hr) + 1;
    computed.add(pos);
    scene.show(
      '节点 ${scene.valueOf(pos)}: 左子树深度 $hl, 右子树深度 $hr, 深度 = $value',
      line: 'return Math.max(left, right) + 1',
      visited: computed,
      highlight: {pos},
    );
    return value;
  }

  final result = depth(scene.rootPos);
  scene.show('二叉树的最大深度 = $result', line: 'return Math.max(left, right) + 1', visited: computed);
  return collector.build();
}

const String invertTreeCode = '''class Solution {
    public TreeNode invertTree(TreeNode root) {
        if (root == null) return null;
        TreeNode tmp = root.left;
        root.left = root.right;
        root.right = tmp;
        invertTree(root.left);
        invertTree(root.right);
        return root;
    }
}''';

List<SceneFrame> invertTreeScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, invertTreeCode);
  final visited = <int>{};

  scene.show('从根节点开始交换左右子树', line: 'if (root == null)');

  void invert(int pos) {
    scene.swapChildren(pos);
    scene.relayout();
    visited.add(pos);
    scene.show(
      '交换 ${scene.valueOf(pos)} 的左右子树',
      line: 'root.left = root.right',
      visited: visited,
      highlight: {pos},
    );
    final left = scene.leftOf(pos);
    if (left != null) invert(left);
    final right = scene.rightOf(pos);
    if (right != null) invert(right);
  }

  invert(scene.rootPos);
  scene.show('翻转完成', line: 'return root', visited: visited);
  return collector.build();
}

const String symmetricCode = '''class Solution {
    public boolean isSymmetric(TreeNode root) {
        return check(root.left, root.right);
    }
    boolean check(TreeNode a, TreeNode b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        if (a.val != b.val) return false;
        return check(a.left, b.right) && check(a.right, b.left);
    }
}''';

List<SceneFrame> symmetricScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, symmetricCode);
  final visited = <int>{};

  scene.show('从根节点的左右子树开始镜像比较', line: 'return check(root.left, root.right)');

  bool check(int? a, int? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) {
      scene.show('一侧为空一侧不为空, 不对称', line: 'if (a == null || b == null) return false', visited: visited);
      return false;
    }
    scene.show(
      '比较 ${scene.valueOf(a)} 与 ${scene.valueOf(b)}',
      line: 'if (a.val != b.val) return false',
      visited: visited,
      highlight: {a, b},
    );
    if (scene.valueOf(a) != scene.valueOf(b)) {
      scene.show('值不相等, 不对称', line: 'if (a.val != b.val) return false', visited: visited);
      return false;
    }
    visited.add(a);
    visited.add(b);
    return check(scene.leftOf(a), scene.rightOf(b)) &&
        check(scene.rightOf(a), scene.leftOf(b));
  }

  final root = scene.rootPos;
  final result = check(scene.leftOf(root), scene.rightOf(root));
  scene.show(result ? '左右镜像, 是对称二叉树' : '不是对称二叉树', line: 'return check(a.left, b.right)', visited: visited);
  return collector.build();
}

const String diameterCode = '''class Solution {
    int best = 0;
    public int diameterOfBinaryTree(TreeNode root) {
        depth(root);
        return best;
    }
    int depth(TreeNode node) {
        if (node == null) return 0;
        int left = depth(node.left);
        int right = depth(node.right);
        best = Math.max(best, left + right);
        return Math.max(left, right) + 1;
    }
}''';

List<SceneFrame> diameterScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, diameterCode);
  final computed = <int>{};
  var best = 0;

  scene.show('后序遍历, 在每个节点统计左右深度之和', line: 'int best = 0');

  int depth(int pos) {
    final left = scene.leftOf(pos);
    final right = scene.rightOf(pos);
    final hl = left == null ? 0 : depth(left);
    final hr = right == null ? 0 : depth(right);
    final through = hl + hr;
    if (through > best) best = through;
    computed.add(pos);
    scene.show(
      '节点 ${scene.valueOf(pos)}: 左深 $hl + 右深 $hr = $through, 当前最大直径 $best',
      line: 'best = Math.max(best, left + right)',
      visited: computed,
      highlight: {pos},
    );
    return (hl > hr ? hl : hr) + 1;
  }

  depth(scene.rootPos);
  scene.show('二叉树的直径 = $best', line: 'return best', visited: computed);
  return collector.build();
}

const String levelOrderCode = '''class Solution {
    public List<List<Integer>> levelOrder(TreeNode root) {
        List<List<Integer>> ans = new ArrayList<>();
        if (root == null) return ans;
        Queue<TreeNode> queue = new LinkedList<>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            int size = queue.size();
            List<Integer> level = new ArrayList<>();
            for (int i = 0; i < size; i++) {
                TreeNode node = queue.poll();
                level.add(node.val);
                if (node.left != null) queue.offer(node.left);
                if (node.right != null) queue.offer(node.right);
            }
            ans.add(level);
        }
        return ans;
    }
}''';

List<SceneFrame> levelOrderScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, levelOrderCode);
  final visited = <int>{};
  final answer = <List<int>>[];

  scene.show('用队列做层序遍历', line: 'queue.offer(root)');
  var level = <int>[scene.rootPos];
  var depth = 0;
  while (level.isNotEmpty) {
    final values = <int>[];
    final next = <int>[];
    for (final pos in level) {
      values.add(scene.valueOf(pos));
      final left = scene.leftOf(pos);
      final right = scene.rightOf(pos);
      if (left != null) next.add(left);
      if (right != null) next.add(right);
    }
    answer.add(values);
    scene.show(
      '第 $depth 层: $values',
      line: 'ans.add(level)',
      visited: visited,
      highlight: level.toSet(),
    );
    visited.addAll(level);
    level = next;
    depth++;
  }

  scene.show('层序遍历结果: $answer', line: 'return ans', visited: visited);
  return collector.build();
}

const String sortedArrayToBstCode = '''class Solution {
    public TreeNode sortedArrayToBST(int[] nums) {
        return build(nums, 0, nums.length - 1);
    }
    TreeNode build(int[] nums, int lo, int hi) {
        if (lo > hi) return null;
        int mid = (lo + hi) / 2;
        TreeNode node = new TreeNode(nums[mid]);
        node.left = build(nums, lo, mid - 1);
        node.right = build(nums, mid + 1, hi);
        return node;
    }
}''';

List<SceneFrame> sortedArrayToBstScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  if (values.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(values.length, 63, 'nums');
  final collector = FrameCollector();
  final tree = _buildBalanced(values, 0, values.length - 1);
  final scene = TreeScene(collector, _toLevelOrder(tree), sortedArrayToBstCode);
  final positionOf = {
    for (final pos in scene.levelOrder) scene.valueOf(pos): pos,
  };
  final visited = <int>{};

  scene.show('有序数组 $values, 每次取中点作为根节点', line: 'int mid = (lo + hi) / 2');

  void build(int lo, int hi, int depth) {
    if (lo > hi) return;
    final mid = (lo + hi) ~/ 2;
    final value = values[mid];
    final pos = positionOf[value]!;
    visited.add(pos);
    scene.show(
      '区间 [$lo, $hi] 的中点下标 $mid, 值 $value 作为节点',
      line: 'TreeNode node = new TreeNode(nums[mid])',
      visited: visited,
      highlight: {pos},
    );
    build(lo, mid - 1, depth + 1);
    build(mid + 1, hi, depth + 1);
  }

  build(0, values.length - 1, 0);
  scene.show('高度平衡二叉搜索树构造完成', line: 'return build(nums, 0, nums.length - 1)', visited: visited);
  return collector.build();
}

const String validateBstCode = '''class Solution {
    Integer prev = null;
    public boolean isValidBST(TreeNode root) {
        if (root == null) return true;
        if (!isValidBST(root.left)) return false;
        if (prev != null && root.val <= prev) return false;
        prev = root.val;
        return isValidBST(root.right);
    }
}''';

List<SceneFrame> validateBstScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, validateBstCode);
  final visited = <int>{};
  int? prev;
  var valid = true;

  scene.show('中序遍历二叉搜索树应得到严格递增序列', line: 'Integer prev = null');

  void inorder(int pos) {
    if (!valid) return;
    final left = scene.leftOf(pos);
    if (left != null) inorder(left);
    if (prev != null && scene.valueOf(pos) <= prev!) {
      valid = false;
      scene.show(
        '节点 ${scene.valueOf(pos)} 不大于前一个值 $prev, 不是二叉搜索树',
        line: 'if (prev != null && root.val <= prev) return false',
        visited: visited,
        highlight: {pos},
      );
      return;
    }
    prev = scene.valueOf(pos);
    visited.add(pos);
    scene.show(
      '访问 ${scene.valueOf(pos)}, 前一个值 $prev, 满足递增',
      line: 'prev = root.val',
      visited: visited,
      highlight: {pos},
    );
    final right = scene.rightOf(pos);
    if (right != null) inorder(right);
  }

  inorder(scene.rootPos);
  scene.show(valid ? '中序序列严格递增, 是二叉搜索树' : '不是二叉搜索树', line: 'return isValidBST(root.right)', visited: visited);
  return collector.build();
}

const String kthSmallestCode = '''class Solution {
    int count = 0;
    int answer = -1;
    public int kthSmallest(TreeNode root, int k) {
        inorder(root, k);
        return answer;
    }
    void inorder(TreeNode node, int k) {
        if (node == null || answer != -1) return;
        inorder(node.left, k);
        count++;
        if (count == k) {
            answer = node.val;
            return;
        }
        inorder(node.right, k);
    }
}''';

List<SceneFrame> kthSmallestScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  final k = intOf(input['k']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, kthSmallestCode);
  final visited = <int>{};
  var count = 0;
  int? answer;

  scene.show('中序遍历, 第 $k 个访问到的节点就是答案', line: 'int count = 0');

  void inorder(int pos) {
    if (answer != null) return;
    final left = scene.leftOf(pos);
    if (left != null) inorder(left);
    if (answer != null) return;
    count++;
    visited.add(pos);
    scene.show(
      '访问第 $count 个节点: ${scene.valueOf(pos)}',
      line: 'count++',
      visited: visited,
      highlight: {pos},
    );
    if (count == k) {
      answer = scene.valueOf(pos);
      scene.show(
        '第 $k 小元素是 $answer',
        line: 'answer = node.val',
        visited: visited,
        highlight: {pos},
      );
      return;
    }
    final right = scene.rightOf(pos);
    if (right != null) inorder(right);
  }

  inorder(scene.rootPos);
  scene.show('二叉搜索树中第 $k 小的元素 = ${answer ?? 'null'}', line: 'return answer', visited: visited);
  return collector.build();
}

const String rightSideViewCode = '''class Solution {
    public List<Integer> rightSideView(TreeNode root) {
        List<Integer> ans = new ArrayList<>();
        if (root == null) return ans;
        Queue<TreeNode> queue = new LinkedList<>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            int size = queue.size();
            for (int i = 0; i < size; i++) {
                TreeNode node = queue.poll();
                if (i == size - 1) ans.add(node.val);
                if (node.left != null) queue.offer(node.left);
                if (node.right != null) queue.offer(node.right);
            }
        }
        return ans;
    }
}''';

List<SceneFrame> rightSideViewScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, rightSideViewCode);
  final visited = <int>{};
  final answer = <int>[];

  scene.show('层序遍历, 每层最后一个节点就是右视图', line: 'queue.offer(root)');
  var level = <int>[scene.rootPos];
  while (level.isNotEmpty) {
    final next = <int>[];
    for (var i = 0; i < level.length; i++) {
      final pos = level[i];
      final left = scene.leftOf(pos);
      final right = scene.rightOf(pos);
      if (left != null) next.add(left);
      if (right != null) next.add(right);
      if (i == level.length - 1) {
        answer.add(scene.valueOf(pos));
        scene.show(
          '本层最右侧节点 ${scene.valueOf(pos)} 加入结果 $answer',
          line: 'if (i == size - 1) ans.add(node.val)',
          visited: visited,
          highlight: {pos},
        );
      }
    }
    visited.addAll(level);
    level = next;
  }

  scene.show('右视图 = $answer', line: 'return ans', visited: visited);
  return collector.build();
}

const String flattenCode = '''class Solution {
    public void flatten(TreeNode root) {
        TreeNode cur = root;
        while (cur != null) {
            if (cur.left != null) {
                TreeNode pre = cur.left;
                while (pre.right != null) pre = pre.right;
                pre.right = cur.right;
                cur.right = cur.left;
                cur.left = null;
            }
            cur = cur.right;
        }
    }
}''';

List<SceneFrame> flattenScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, flattenCode);
  final order = scene.preorder;
  final visited = <int>{};

  scene.show('按前序顺序把节点串成只有右指针的链表', line: 'TreeNode cur = root');

  for (var i = 0; i < order.length - 1; i++) {
    final current = order[i];
    final next = order[i + 1];
    scene.setChildren(current, left: null, right: next);
    scene.setChildren(next, left: null, changeRight: false);
    scene.relayout();
    visited.add(current);
    scene.show(
      '把 ${scene.valueOf(current)} 的右指针接向 ${scene.valueOf(next)}',
      line: 'cur.right = cur.left',
      visited: visited,
      highlight: {current, next},
    );
  }

  final last = order.isEmpty ? null : order.last;
  if (last != null) {
    scene.setChildren(last, left: null, right: null);
    scene.relayout();
    visited.add(last);
  }
  scene.show('展开完成, 每个节点只有右指针', line: 'cur = cur.right', visited: visited);
  return collector.build();
}

const String buildTreeCode = '''class Solution {
    Map<Integer, Integer> index = new HashMap<>();
    int pre = 0;
    public TreeNode buildTree(int[] preorder, int[] inorder) {
        for (int i = 0; i < inorder.length; i++) index.put(inorder[i], i);
        return build(preorder, 0, inorder.length - 1);
    }
    TreeNode build(int[] preorder, int lo, int hi) {
        if (lo > hi) return null;
        int rootVal = preorder[pre++];
        int mid = index.get(rootVal);
        TreeNode root = new TreeNode(rootVal);
        root.left = build(preorder, lo, mid - 1);
        root.right = build(preorder, mid + 1, hi);
        return root;
    }
}''';

List<SceneFrame> buildTreeScript(Map<String, dynamic> input) {
  final preorder = intList(input['preorder']);
  final inorder = intList(input['inorder']);
  if (preorder.length != inorder.length || preorder.isEmpty) {
    throw ArgumentError('前序与中序序列长度必须相等且非空');
  }
  checkSize(preorder.length, 63, 'preorder');
  final inIndex = <int, int>{};
  for (var i = 0; i < inorder.length; i++) {
    inIndex[inorder[i]] = i;
  }
  final cursor = [0];
  final tree = _buildFromPreIn(preorder, inIndex, cursor, 0, inorder.length - 1);
  final collector = FrameCollector();
  final scene = TreeScene(collector, _toLevelOrder(tree), buildTreeCode);
  final positionOf = {
    for (final pos in scene.levelOrder) scene.valueOf(pos): pos,
  };
  final visited = <int>{};
  var pre = 0;

  scene.show('前序确定根, 中序划分左右区间', line: 'for (int i = 0; i < inorder.length; i++)');

  void build(int lo, int hi) {
    if (lo > hi) return;
    final rootValue = preorder[pre++];
    final mid = inIndex[rootValue]!;
    final pos = positionOf[rootValue]!;
    visited.add(pos);
    scene.show(
      '根 $rootValue: 中序下标 $mid, 左区间 [$lo, ${mid - 1}], 右区间 [${mid + 1}, $hi]',
      line: 'int mid = index.get(rootVal)',
      visited: visited,
      highlight: {pos},
    );
    build(lo, mid - 1);
    build(mid + 1, hi);
  }

  build(0, inorder.length - 1);
  scene.show('二叉树构造完成', line: 'return build(preorder, 0, inorder.length - 1)', visited: visited);
  return collector.build();
}

const String pathSumCode = '''class Solution {
    int count = 0;
    Map<Long, Integer> prefix = new HashMap<>();
    public int pathSum(TreeNode root, int targetSum) {
        prefix.put(0L, 1);
        dfs(root, 0L, targetSum);
        return count;
    }
    void dfs(TreeNode node, long cur, int target) {
        if (node == null) return;
        cur += node.val;
        count += prefix.getOrDefault(cur - target, 0);
        prefix.put(cur, prefix.getOrDefault(cur, 0) + 1);
        dfs(node.left, cur, target);
        dfs(node.right, cur, target);
        prefix.put(cur, prefix.get(cur) - 1);
    }
}''';

List<SceneFrame> pathSumScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  final target = intOf(input['targetSum']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, pathSumCode);
  final prefix = <int, int>{0: 1};
  final path = <int>[];
  final visited = <int>{};
  var count = 0;

  scene.show('前缀和 + 回溯: 统计路径和等于 $target 的路径', line: 'prefix.put(0L, 1)');

  void dfs(int pos, int cur) {
    final sum = cur + scene.valueOf(pos);
    path.add(pos);
    final need = sum - target;
    count += prefix[need] ?? 0;
    scene.show(
      '节点 ${scene.valueOf(pos)}: 前缀和 $sum, 需要 $need, 命中 ${prefix[need] ?? 0} 条, 累计 $count',
      line: 'count += prefix.getOrDefault(cur - target, 0)',
      visited: visited,
      highlight: path.toSet(),
    );
    prefix[sum] = (prefix[sum] ?? 0) + 1;
    visited.add(pos);
    final left = scene.leftOf(pos);
    if (left != null) dfs(left, sum);
    final right = scene.rightOf(pos);
    if (right != null) dfs(right, sum);
    prefix[sum] = prefix[sum]! - 1;
    path.removeLast();
  }

  dfs(scene.rootPos, 0);
  scene.show('路径和等于 $target 的路径共 $count 条', line: 'return count', visited: visited);
  return collector.build();
}

const String lcaCode = '''class Solution {
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        if (root == null || root == p || root == q) return root;
        TreeNode left = lowestCommonAncestor(root.left, p, q);
        TreeNode right = lowestCommonAncestor(root.right, p, q);
        if (left != null && right != null) return root;
        return left != null ? left : right;
    }
}''';

List<SceneFrame> lcaScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  final p = intOf(input['p']);
  final q = intOf(input['q']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, lcaCode);
  final positionOf = {
    for (final pos in scene.levelOrder) scene.valueOf(pos): pos,
  };
  if (!positionOf.containsKey(p) || !positionOf.containsKey(q)) {
    throw ArgumentError('p 与 q 必须都存在于树中');
  }
  final pPos = positionOf[p]!;
  final qPos = positionOf[q]!;
  final visited = <int>{};

  scene.show('寻找节点 $p 与 $q 的最近公共祖先', line: 'if (root == null || root == p || root == q)');

  int? find(int? pos) {
    if (pos == null) return null;
    if (pos == pPos || pos == qPos) {
      visited.add(pos);
      scene.show(
        '找到目标节点 ${scene.valueOf(pos)}',
        line: 'if (root == null || root == p || root == q) return root',
        visited: visited,
        highlight: {pos},
      );
      return pos;
    }
    final left = find(scene.leftOf(pos));
    final right = find(scene.rightOf(pos));
    if (left != null && right != null) {
      visited.add(pos);
      scene.show(
        '左右子树都找到目标, ${scene.valueOf(pos)} 是最近公共祖先',
        line: 'if (left != null && right != null) return root',
        visited: visited,
        highlight: {pos},
      );
      return pos;
    }
    return left ?? right;
  }

  final result = find(scene.rootPos);
  scene.show(
    '最近公共祖先是 ${result == null ? 'null' : scene.valueOf(result)}',
    line: 'return left != null ? left : right',
    visited: visited,
    highlight: {?result, pPos, qPos},
  );
  return collector.build();
}

const String maxPathSumCode = '''class Solution {
    int best = Integer.MIN_VALUE;
    public int maxPathSum(TreeNode root) {
        gain(root);
        return best;
    }
    int gain(TreeNode node) {
        if (node == null) return 0;
        int left = Math.max(gain(node.left), 0);
        int right = Math.max(gain(node.right), 0);
        best = Math.max(best, node.val + left + right);
        return node.val + Math.max(left, right);
    }
}''';

List<SceneFrame> maxPathSumScript(Map<String, dynamic> input) {
  final raw = treeInput(input['tree']);
  checkSize(raw.length, 63, 'tree');
  final collector = FrameCollector();
  final scene = TreeScene(collector, raw, maxPathSumCode);
  final computed = <int>{};
  var best = -1000000;

  scene.show('后序遍历: 每个节点计算向下的最大贡献', line: 'int best = Integer.MIN_VALUE');

  int gain(int pos) {
    final left = scene.leftOf(pos);
    final right = scene.rightOf(pos);
    final lg = left == null ? 0 : gain(left);
    final rg = right == null ? 0 : gain(right);
    final l = lg > 0 ? lg : 0;
    final r = rg > 0 ? rg : 0;
    final through = scene.valueOf(pos) + l + r;
    if (through > best) best = through;
    computed.add(pos);
    scene.show(
      '节点 ${scene.valueOf(pos)}: 左贡献 $l, 右贡献 $r, 经过该节点的路径和 $through, 最大 $best',
      line: 'best = Math.max(best, node.val + left + right)',
      visited: computed,
      highlight: {pos},
    );
    return scene.valueOf(pos) + (l > r ? l : r);
  }

  gain(scene.rootPos);
  scene.show('二叉树中的最大路径和 = $best', line: 'return best', visited: computed);
  return collector.build();
}

// ===========================================================================
// 题目描述符
// ===========================================================================

List<ProblemEntry> batch4Problems() => [
      buildProblem(
        slug: 'binary-tree-inorder-traversal',
        number: 94,
        title: '二叉树的中序遍历',
        difficulty: ProblemDifficulty.easy,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: inorderCode,
        presets: [
          preset('示例 1', {
            'tree': [1, -1, 2, 3],
          }),
          preset('示例 2', {
            'tree': [1, 2, 3, 4, 5, -1, 8],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: inorderScript,
      ),
      buildProblem(
        slug: 'maximum-depth-of-binary-tree',
        number: 104,
        title: '二叉树的最大深度',
        difficulty: ProblemDifficulty.easy,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: maxDepthCode,
        presets: [
          preset('示例 1', {
            'tree': [3, 9, 20, -1, -1, 15, 7],
          }),
          preset('示例 2', {
            'tree': [1, -1, 2],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: maxDepthScript,
      ),
      buildProblem(
        slug: 'invert-binary-tree',
        number: 226,
        title: '翻转二叉树',
        difficulty: ProblemDifficulty.easy,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: invertTreeCode,
        presets: [
          preset('示例 1', {
            'tree': [4, 2, 7, 1, 3, 6, 9],
          }),
          preset('示例 2', {
            'tree': [2, 1, 3],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: invertTreeScript,
      ),
      buildProblem(
        slug: 'symmetric-tree',
        number: 101,
        title: '对称二叉树',
        difficulty: ProblemDifficulty.easy,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: symmetricCode,
        presets: [
          preset('示例 1', {
            'tree': [1, 2, 2, 3, 4, 4, 3],
          }),
          preset('示例 2', {
            'tree': [1, 2, 2, -1, 3, -1, 3],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: symmetricScript,
      ),
      buildProblem(
        slug: 'diameter-of-binary-tree',
        number: 543,
        title: '二叉树的直径',
        difficulty: ProblemDifficulty.easy,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: diameterCode,
        presets: [
          preset('示例 1', {
            'tree': [1, 2, 3, 4, 5],
          }),
          preset('示例 2', {
            'tree': [1, 2],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: diameterScript,
      ),
      buildProblem(
        slug: 'binary-tree-level-order-traversal',
        number: 102,
        title: '二叉树的层序遍历',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: levelOrderCode,
        presets: [
          preset('示例 1', {
            'tree': [3, 9, 20, -1, -1, 15, 7],
          }),
          preset('示例 2', {
            'tree': [1],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: levelOrderScript,
      ),
      buildProblem(
        slug: 'convert-sorted-array-to-binary-search-tree',
        number: 108,
        title: '将有序数组转换为二叉搜索树',
        difficulty: ProblemDifficulty.easy,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: sortedArrayToBstCode,
        presets: [
          preset('示例 1', {
            'nums': [-10, -3, 0, 5, 9],
          }),
          preset('示例 2', {
            'nums': [1, 3],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 63)]),
        script: sortedArrayToBstScript,
      ),
      buildProblem(
        slug: 'validate-binary-search-tree',
        number: 98,
        title: '验证二叉搜索树',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: validateBstCode,
        presets: [
          preset('示例 1', {
            'tree': [2, 1, 3],
          }),
          preset('示例 2', {
            'tree': [5, 1, 4, -1, -1, 3, 6],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: validateBstScript,
      ),
      buildProblem(
        slug: 'kth-smallest-element-in-a-bst',
        number: 230,
        title: '二叉搜索树中第 K 小的元素',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: kthSmallestCode,
        presets: [
          preset('示例 1', {
            'tree': [3, 1, 4, -1, 2],
            'k': 1,
          }),
          preset('示例 2', {
            'tree': [5, 3, 6, 2, 4, -1, -1, 1],
            'k': 3,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('tree', maxLength: 63),
          InputField.int('k', minValue: 1, maxValue: 63),
        ]),
        script: kthSmallestScript,
      ),
      buildProblem(
        slug: 'binary-tree-right-side-view',
        number: 199,
        title: '二叉树的右视图',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: rightSideViewCode,
        presets: [
          preset('示例 1', {
            'tree': [1, 2, 3, -1, 5, -1, 4],
          }),
          preset('示例 2', {
            'tree': [1, 2, 3, 4],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: rightSideViewScript,
      ),
      buildProblem(
        slug: 'flatten-binary-tree-to-linked-list',
        number: 114,
        title: '二叉树展开为链表',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: flattenCode,
        presets: [
          preset('示例 1', {
            'tree': [1, 2, 5, 3, 4, -1, 6],
          }),
          preset('示例 2', {
            'tree': [1, 2, 3],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: flattenScript,
      ),
      buildProblem(
        slug: 'construct-binary-tree-from-preorder-and-inorder-traversal',
        number: 105,
        title: '从前序与中序遍历序列构造二叉树',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: buildTreeCode,
        presets: [
          preset('示例 1', {
            'preorder': [3, 9, 20, 15, 7],
            'inorder': [9, 3, 15, 20, 7],
          }),
          preset('示例 2', {
            'preorder': [1],
            'inorder': [1],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('preorder', maxLength: 63),
          InputField.array('inorder', maxLength: 63),
        ]),
        script: buildTreeScript,
      ),
      buildProblem(
        slug: 'path-sum-iii',
        number: 437,
        title: '路径总和 III',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: pathSumCode,
        presets: [
          preset('示例 1', {
            'tree': [10, 5, -3, 3, 2, -1, 11, 3, -2, -1, 1],
            'targetSum': 8,
          }),
          preset('示例 2', {
            'tree': [1, 2, 3],
            'targetSum': 3,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('tree', maxLength: 63),
          InputField.int('targetSum', minValue: -1000, maxValue: 1000),
        ]),
        script: pathSumScript,
      ),
      buildProblem(
        slug: 'lowest-common-ancestor-of-a-binary-tree',
        number: 236,
        title: '二叉树的最近公共祖先',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: lcaCode,
        presets: [
          preset('示例 1', {
            'tree': [3, 5, 1, 6, 2, 0, 8, -1, -1, 7, 4],
            'p': 5,
            'q': 4,
          }),
          preset('示例 2', {
            'tree': [3, 5, 1, 6, 2, 0, 8, -1, -1, 7, 4],
            'p': 5,
            'q': 1,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('tree', maxLength: 63),
          InputField.int('p'),
          InputField.int('q'),
        ]),
        script: lcaScript,
      ),
      buildProblem(
        slug: 'binary-tree-maximum-path-sum',
        number: 124,
        title: '二叉树中的最大路径和',
        difficulty: ProblemDifficulty.hard,
        group: 'binary-tree',
        pattern: 'binary-tree',
        code: maxPathSumCode,
        presets: [
          preset('示例 1', {
            'tree': [1, 2, 3],
          }),
          preset('示例 2', {
            'tree': [-10, 9, 20, -1, -1, 15, 7],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('tree', maxLength: 63)]),
        script: maxPathSumScript,
      ),
    ];
