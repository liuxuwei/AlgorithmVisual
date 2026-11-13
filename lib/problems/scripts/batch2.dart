import '../../catalog/problem_entry.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/scene_frame.dart';
import '../script_helpers.dart';

// ===========================================================================
// 普通数组 (5)
// ===========================================================================

const String maxSubArrayCode = '''class Solution {
    public int maxSubArray(int[] nums) {
        int cur = nums[0], best = nums[0];
        for (int i = 1; i < nums.length; i++) {
            cur = Math.max(nums[i], cur + nums[i]);
            best = Math.max(best, cur);
        }
        return best;
    }
}''';

List<SceneFrame> maxSubArrayScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, maxSubArrayCode);
  var cur = nums.first;
  var best = nums.first;
  var start = 0;

  scene.show('cur = best = nums[0] = $cur', line: 'int cur', pointers: {'i': 0});
  for (var i = 1; i < nums.length; i++) {
    if (nums[i] > cur + nums[i]) {
      cur = nums[i];
      start = i;
    } else {
      cur = cur + nums[i];
    }
    if (cur > best) best = cur;
    scene.show(
      'i = $i, 当前和 cur = $cur, 历史最大 best = $best',
      line: 'cur = Math.max',
      pointers: {'i': i},
      highlight: {i},
      rangeStart: start,
      rangeEnd: i,
      rangeLabel: '当前子数组',
    );
  }
  scene.show('最大子数组和 = $best', line: 'return best');
  return collector.build();
}

const String mergeIntervalsCode = '''class Solution {
    public int[][] merge(int[][] intervals) {
        Arrays.sort(intervals, (a, b) -> a[0] - b[0]);
        List<int[]> ans = new ArrayList<>();
        for (int[] interval : intervals) {
            if (ans.isEmpty() || ans.get(ans.size() - 1)[1] < interval[0]) {
                ans.add(interval);
            } else {
                ans.get(ans.size() - 1)[1] = Math.max(ans.get(ans.size() - 1)[1], interval[1]);
            }
        }
        return ans.toArray(new int[0][]);
    }
}''';

List<SceneFrame> mergeIntervalsScript(Map<String, dynamic> input) {
  final matrix = intMatrix(input['intervals']);
  checkSize(matrix.length, 20, 'intervals');
  final collector = FrameCollector();
  final grid = [for (final row in matrix) <dynamic>[...row]];
  final scene = GridScene(collector, grid, mergeIntervalsCode);

  scene.show('原始区间, 先按左端点排序', line: 'Arrays.sort');
  grid.sort((a, b) => (a[0] as int).compareTo(b[0] as int));
  scene.show('排序完成: ${_intervalsText(grid)}', line: 'Arrays.sort');

  final merged = <List<int>>[];
  for (var i = 0; i < grid.length; i++) {
    final start = grid[i][0] as int;
    final end = grid[i][1] as int;
    if (merged.isEmpty || merged.last[1] < start) {
      merged.add([start, end]);
      scene.show(
        '区间 [$start, $end] 与前面不重叠, 加入结果',
        line: 'ans.add',
        highlight: {(i, 0), (i, 1)},
      );
    } else {
      merged.last[1] = merged.last[1] > end ? merged.last[1] : end;
      scene.show(
        '区间 [$start, $end] 与上一段重叠, 合并为 [${merged.last[0]}, ${merged.last[1]}]',
        line: 'ans.get(ans.size() - 1)[1]',
        highlight: {(i, 0), (i, 1)},
      );
    }
  }
  scene.show('合并结果: $merged', line: 'return ans');
  return collector.build();
}

String _intervalsText(List<List<dynamic>> grid) {
  return '[${grid.map((row) => '[${row[0]}, ${row[1]}]').join(', ')}]';
}

const String rotateArrayCode = '''class Solution {
    public void rotate(int[] nums, int k) {
        k %= nums.length;
        reverse(nums, 0, nums.length - 1);
        reverse(nums, 0, k - 1);
        reverse(nums, k, nums.length - 1);
    }
    void reverse(int[] a, int i, int j) {
        while (i < j) {
            int t = a[i]; a[i] = a[j]; a[j] = t;
            i++; j--;
        }
    }
}''';

List<SceneFrame> rotateArrayScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final k0 = intOf(input['k']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, rotateArrayCode);
  final k = nums.isEmpty ? 0 : k0 % nums.length;

  scene.show('k = $k0 % ${nums.length} = $k', line: 'k %=');
  void reverse(int from, int to, String label) {
    var i = from;
    var j = to;
    scene.show('反转区间 [$from, $to] ($label)', line: 'while (i < j)', pointers: {'i': i, 'j': j});
    while (i < j) {
      final tmp = nums[i];
      nums[i] = nums[j];
      nums[j] = tmp;
      scene.show(
        '交换 nums[$i] 与 nums[$j]',
        line: 'int t = a[i]',
        pointers: {'i': i, 'j': j},
        highlight: {i, j},
      );
      i++;
      j--;
    }
  }

  reverse(0, nums.length - 1, '整体反转');
  reverse(0, k - 1, '前 k 个反转');
  reverse(k, nums.length - 1, '剩余部分反转');
  scene.show('旋转完成: $nums', line: 'reverse(nums, k');
  return collector.build();
}

const String productExceptSelfCode = '''class Solution {
    public int[] productExceptSelf(int[] nums) {
        int n = nums.length;
        int[] ans = new int[n];
        ans[0] = 1;
        for (int i = 1; i < n; i++) ans[i] = ans[i - 1] * nums[i - 1];
        int right = 1;
        for (int i = n - 1; i >= 0; i--) {
            ans[i] = ans[i] * right;
            right *= nums[i];
        }
        return ans;
    }
}''';

List<SceneFrame> productExceptSelfScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  checkSize(nums.length, 60, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, List<int>.from(nums), productExceptSelfCode);
  final ans = List<int>.filled(nums.length, 1);

  scene.show('答案数组初始化为 1', line: 'int[] ans');
  for (var i = 1; i < nums.length; i++) {
    ans[i] = ans[i - 1] * nums[i - 1];
    scene.show(
      '左前缀 ans[$i] = ${ans[i]}',
      line: 'ans[i] = ans[i - 1]',
      pointers: {'i': i},
      highlight: {i},
    );
  }
  var right = 1;
  for (var i = nums.length - 1; i >= 0; i--) {
    final old = ans[i];
    ans[i] = old * right;
    scene.show(
      '右后缀 right = $right, ans[$i] = $old × $right = ${ans[i]}',
      line: 'ans[i] = ans[i] * right',
      pointers: {'i': i},
      highlight: {i},
    );
    right *= nums[i];
  }
  scene.show('除自身以外乘积 = $ans', line: 'return ans', sorted: {for (var i = 0; i < ans.length; i++) i});
  return collector.build();
}

const String firstMissingPositiveCode = '''class Solution {
    public int firstMissingPositive(int[] nums) {
        int n = nums.length;
        for (int i = 0; i < n; i++) {
            while (nums[i] > 0 && nums[i] <= n && nums[nums[i] - 1] != nums[i]) {
                int j = nums[i] - 1;
                int t = nums[i]; nums[i] = nums[j]; nums[j] = t;
            }
        }
        for (int i = 0; i < n; i++) {
            if (nums[i] != i + 1) return i + 1;
        }
        return n + 1;
    }
}''';

List<SceneFrame> firstMissingPositiveScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  checkSize(nums.length, 60, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, firstMissingPositiveCode);
  final n = nums.length;

  scene.show('把每个数放回自己的位置', line: 'int n = nums.length');
  for (var i = 0; i < n; i++) {
    while (nums[i] > 0 && nums[i] <= n && nums[nums[i] - 1] != nums[i]) {
      final j = nums[i] - 1;
      final tmp = nums[i];
      nums[i] = nums[j];
      nums[j] = tmp;
      scene.show(
        'nums[$i] = $tmp 应放在下标 $j, 交换',
        line: 'int j = nums[i] - 1',
        pointers: {'i': i, 'j': j},
        highlight: {i, j},
      );
    }
  }
  for (var i = 0; i < n; i++) {
    if (nums[i] != i + 1) {
      scene.show('下标 $i 上是 ${nums[i]}, 缺失 ${i + 1}', line: 'if (nums[i]', pointers: {'i': i}, highlight: {i});
      return collector.build();
    }
  }
  scene.show('1..$n 都齐全, 缺失 ${n + 1}', line: 'return n + 1');
  return collector.build();
}

// ===========================================================================
// 矩阵 (4)
// ===========================================================================

const String setZeroesCode = '''class Solution {
    public void setZeroes(int[][] matrix) {
        int m = matrix.length, n = matrix[0].length;
        boolean firstRow = false, firstCol = false;
        for (int i = 0; i < m; i++) if (matrix[i][0] == 0) firstCol = true;
        for (int j = 0; j < n; j++) if (matrix[0][j] == 0) firstRow = true;
        for (int i = 1; i < m; i++)
            for (int j = 1; j < n; j++)
                if (matrix[i][j] == 0) { matrix[i][0] = 0; matrix[0][j] = 0; }
        for (int i = 1; i < m; i++)
            for (int j = 1; j < n; j++)
                if (matrix[i][0] == 0 || matrix[0][j] == 0) matrix[i][j] = 0;
        if (firstRow) for (int j = 0; j < n; j++) matrix[0][j] = 0;
        if (firstCol) for (int i = 0; i < m; i++) matrix[i][0] = 0;
    }
}''';

List<SceneFrame> setZeroesScript(Map<String, dynamic> input) {
  final matrix = intMatrix(input['matrix']);
  checkSize(matrix.length, 20, 'matrix');
  final collector = FrameCollector();
  final grid = [for (final row in matrix) <dynamic>[...row]];
  final scene = GridScene(collector, grid, setZeroesCode);
  final zeroRows = <int>{};
  final zeroCols = <int>{};

  scene.show('扫描矩阵, 记录需要置零的行列', line: 'int m = matrix.length');
  for (var i = 0; i < grid.length; i++) {
    for (var j = 0; j < grid[i].length; j++) {
      if (grid[i][j] == 0) {
        zeroRows.add(i);
        zeroCols.add(j);
        scene.show(
          '发现 0 在 ($i, $j), 第 $i 行与第 $j 列都要置零',
          line: 'if (matrix[i][j] == 0)',
          highlight: {(i, j)},
        );
      }
    }
  }
  for (final i in zeroRows) {
    for (var j = 0; j < grid[i].length; j++) {
      grid[i][j] = 0;
    }
  }
  for (final j in zeroCols) {
    for (var i = 0; i < grid.length; i++) {
      if (j < grid[i].length) grid[i][j] = 0;
    }
  }
  scene.show('置零完成', line: 'if (firstCol)', highlight: {
    for (final i in zeroRows)
      for (var j = 0; j < grid[i].length; j++) (i, j),
    for (final j in zeroCols)
      for (var i = 0; i < grid.length; i++) (i, j),
  });
  return collector.build();
}

const String spiralOrderCode = '''class Solution {
    public List<Integer> spiralOrder(int[][] matrix) {
        List<Integer> ans = new ArrayList<>();
        int top = 0, bottom = matrix.length - 1;
        int left = 0, right = matrix[0].length - 1;
        while (top <= bottom && left <= right) {
            for (int j = left; j <= right; j++) ans.add(matrix[top][j]);
            top++;
            for (int i = top; i <= bottom; i++) ans.add(matrix[i][right]);
            right--;
            if (top <= bottom) for (int j = right; j >= left; j--) ans.add(matrix[bottom][j]);
            bottom--;
            if (left <= right) for (int i = bottom; i >= top; i--) ans.add(matrix[i][left]);
            left++;
        }
        return ans;
    }
}''';

List<SceneFrame> spiralOrderScript(Map<String, dynamic> input) {
  final matrix = intMatrix(input['matrix']);
  checkSize(matrix.length, 20, 'matrix');
  final collector = FrameCollector();
  final grid = [for (final row in matrix) <dynamic>[...row]];
  final scene = GridScene(collector, grid, spiralOrderCode);
  final visited = <(int, int)>{};
  var top = 0;
  var bottom = grid.length - 1;
  var left = 0;
  var right = grid.isEmpty ? -1 : grid.first.length - 1;
  final order = <int>[];

  scene.show('初始化四条边界', line: 'int top');
  while (top <= bottom && left <= right) {
    for (var j = left; j <= right; j++) {
      order.add(grid[top][j] as int);
      visited.add((top, j));
      scene.show('向右: 访问 ($top, $j) = ${grid[top][j]}', line: 'ans.add(matrix[top][j])', visited: visited);
    }
    top++;
    for (var i = top; i <= bottom; i++) {
      order.add(grid[i][right] as int);
      visited.add((i, right));
      scene.show('向下: 访问 ($i, $right) = ${grid[i][right]}', line: 'ans.add(matrix[i][right])', visited: visited);
    }
    right--;
    if (top <= bottom) {
      for (var j = right; j >= left; j--) {
        order.add(grid[bottom][j] as int);
        visited.add((bottom, j));
        scene.show('向左: 访问 ($bottom, $j) = ${grid[bottom][j]}', line: 'ans.add(matrix[bottom][j])', visited: visited);
      }
      bottom--;
    }
    if (left <= right) {
      for (var i = bottom; i >= top; i--) {
        order.add(grid[i][left] as int);
        visited.add((i, left));
        scene.show('向上: 访问 ($i, $left) = ${grid[i][left]}', line: 'ans.add(matrix[i][left])', visited: visited);
      }
      left++;
    }
  }
  scene.show('螺旋顺序 = $order', line: 'return ans', visited: visited);
  return collector.build();
}

const String rotateImageCode = '''class Solution {
    public void rotate(int[][] matrix) {
        int n = matrix.length;
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                int t = matrix[i][j];
                matrix[i][j] = matrix[j][i];
                matrix[j][i] = t;
            }
        }
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n / 2; j++) {
                int t = matrix[i][j];
                matrix[i][j] = matrix[i][n - 1 - j];
                matrix[i][n - 1 - j] = t;
            }
        }
    }
}''';

List<SceneFrame> rotateImageScript(Map<String, dynamic> input) {
  final matrix = intMatrix(input['matrix']);
  checkSize(matrix.length, 20, 'matrix');
  final collector = FrameCollector();
  final grid = [for (final row in matrix) <dynamic>[...row]];
  final scene = GridScene(collector, grid, rotateImageCode);
  final n = grid.length;

  scene.show('第一步: 沿主对角线转置', line: 'int n = matrix.length');
  for (var i = 0; i < n; i++) {
    for (var j = i + 1; j < n; j++) {
      final tmp = grid[i][j];
      grid[i][j] = grid[j][i];
      grid[j][i] = tmp;
      scene.show(
        '交换 ($i, $j) 与 ($j, $i)',
        line: 'int t = matrix[i][j]',
        highlight: {(i, j), (j, i)},
      );
    }
  }
  scene.show('第二步: 每行左右翻转', line: 'for (int i = 0; i < n; i++) {');
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < n ~/ 2; j++) {
      final tmp = grid[i][j];
      grid[i][j] = grid[i][n - 1 - j];
      grid[i][n - 1 - j] = tmp;
      scene.show(
        '交换 ($i, $j) 与 ($i, ${n - 1 - j})',
        line: 'matrix[i][j] = matrix[i][n - 1 - j]',
        highlight: {(i, j), (i, n - 1 - j)},
      );
    }
  }
  scene.show('旋转 90 度完成', line: 'matrix[i][n - 1 - j] = t');
  return collector.build();
}

const String searchMatrix2Code = '''class Solution {
    public boolean searchMatrix(int[][] matrix, int target) {
        int m = matrix.length, n = matrix[0].length;
        int r = 0, c = n - 1;
        while (r < m && c >= 0) {
            if (matrix[r][c] == target) return true;
            if (matrix[r][c] > target) c--;
            else r++;
        }
        return false;
    }
}''';

List<SceneFrame> searchMatrix2Script(Map<String, dynamic> input) {
  final matrix = intMatrix(input['matrix']);
  final target = intOf(input['target']);
  checkSize(matrix.length, 20, 'matrix');
  final collector = FrameCollector();
  final grid = [for (final row in matrix) <dynamic>[...row]];
  final scene = GridScene(collector, grid, searchMatrix2Code);
  var r = 0;
  var c = grid.isEmpty ? -1 : grid.first.length - 1;

  scene.show('从右上角 ($r, $c) 开始', line: 'int r = 0', pointers: {'cur': (r, c)});
  while (r < grid.length && c >= 0) {
    final value = grid[r][c];
    scene.show(
      '($r, $c) = $value, target = $target',
      line: 'while (r < m',
      pointers: {'cur': (r, c)},
      highlight: {(r, c)},
    );
    if (value == target) {
      scene.show('找到 target, 返回 true', line: 'return true', visited: {(r, c)});
      return collector.build();
    }
    if (value > target) {
      c--;
      scene.show('当前值偏大, 左移到列 $c', line: 'c--', pointers: c >= 0 ? {'cur': (r, c)} : const {});
    } else {
      r++;
      scene.show('当前值偏小, 下移到行 $r', line: 'else r++', pointers: r < grid.length ? {'cur': (r, c)} : const {});
    }
  }
  scene.show('未找到 target, 返回 false', line: 'return false');
  return collector.build();
}

// ===========================================================================
// 二分查找 (6)
// ===========================================================================

const String searchInsertCode = '''class Solution {
    public int searchInsert(int[] nums, int target) {
        int left = 0, right = nums.length - 1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) return mid;
            if (nums[mid] < target) left = mid + 1;
            else right = mid - 1;
        }
        return left;
    }
}''';

List<SceneFrame> searchInsertScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final target = intOf(input['target']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, searchInsertCode);
  var left = 0;
  var right = nums.length - 1;

  scene.show('区间 [$left, $right]', line: 'int left');
  while (left <= right) {
    final mid = left + (right - left) ~/ 2;
    scene.show(
      'mid = $mid, nums[$mid] = ${nums[mid]}',
      line: 'int mid',
      pointers: {'left': left, 'mid': mid, 'right': right},
      highlight: {mid},
      rangeStart: left,
      rangeEnd: right,
      rangeLabel: '搜索区间',
    );
    if (nums[mid] == target) {
      scene.show('找到 target, 下标 $mid', line: 'return mid', highlight: {mid}, sorted: {mid});
      return collector.build();
    }
    if (nums[mid] < target) {
      left = mid + 1;
      scene.show('nums[$mid] < $target, left = $left', line: 'left = mid + 1', pointers: {'left': left, 'right': right});
    } else {
      right = mid - 1;
      scene.show('nums[$mid] > $target, right = $right', line: 'right = mid - 1', pointers: {'left': left, 'right': right});
    }
  }
  scene.show('未找到, 插入位置 $left', line: 'return left', pointers: {'插入位置': left});
  return collector.build();
}

const String searchMatrixCode = '''class Solution {
    public boolean searchMatrix(int[][] matrix, int target) {
        int m = matrix.length, n = matrix[0].length;
        int left = 0, right = m * n - 1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            int v = matrix[mid / n][mid % n];
            if (v == target) return true;
            if (v < target) left = mid + 1;
            else right = mid - 1;
        }
        return false;
    }
}''';

List<SceneFrame> searchMatrixScript(Map<String, dynamic> input) {
  final matrix = intMatrix(input['matrix']);
  final target = intOf(input['target']);
  checkSize(matrix.length, 20, 'matrix');
  final collector = FrameCollector();
  final grid = [for (final row in matrix) <dynamic>[...row]];
  final scene = GridScene(collector, grid, searchMatrixCode);
  final cols = grid.isEmpty ? 0 : grid.first.length;
  var left = 0;
  var right = grid.length * cols - 1;

  scene.show('把矩阵视为长度 ${grid.length * cols} 的有序数组', line: 'int left');
  while (left <= right && cols > 0) {
    final mid = left + (right - left) ~/ 2;
    final r = mid ~/ cols;
    final c = mid % cols;
    final value = grid[r][c];
    scene.show(
      'mid = $mid → ($r, $c) = $value',
      line: 'int v = matrix',
      pointers: {'mid': (r, c)},
      highlight: {(r, c)},
    );
    if (value == target) {
      scene.show('找到 target, 返回 true', line: 'return true', visited: {(r, c)});
      return collector.build();
    }
    if (value < target) {
      left = mid + 1;
      scene.show('偏小, left = $left', line: 'left = mid + 1');
    } else {
      right = mid - 1;
      scene.show('偏大, right = $right', line: 'right = mid - 1');
    }
  }
  scene.show('未找到 target', line: 'return false');
  return collector.build();
}

const String searchRangeCode = '''class Solution {
    public int[] searchRange(int[] nums, int target) {
        int first = lowerBound(nums, target, true);
        int last = lowerBound(nums, target, false);
        return new int[]{first, last};
    }
    int lowerBound(int[] nums, int target, boolean first) {
        int left = 0, right = nums.length - 1, ans = -1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) {
                ans = mid;
                if (first) right = mid - 1; else left = mid + 1;
            } else if (nums[mid] < target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }
        return ans;
    }
}''';

List<SceneFrame> searchRangeScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final target = intOf(input['target']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, searchRangeCode);

  int bound(bool first) {
    var left = 0;
    var right = nums.length - 1;
    var ans = -1;
    while (left <= right) {
      final mid = left + (right - left) ~/ 2;
      scene.show(
        '${first ? "找左边界" : "找右边界"}: mid = $mid, nums[$mid] = ${nums[mid]}',
        line: 'int mid',
        pointers: {'left': left, 'mid': mid, 'right': right},
        highlight: {mid},
      );
      if (nums[mid] == target) {
        ans = mid;
        if (first) {
          right = mid - 1;
        } else {
          left = mid + 1;
        }
      } else if (nums[mid] < target) {
        left = mid + 1;
      } else {
        right = mid - 1;
      }
    }
    return ans;
  }

  scene.show('第一次二分找左边界', line: 'int first');
  final first = bound(true);
  scene.show('第二次二分找右边界', line: 'int last');
  final last = bound(false);
  scene.show(
    'target 出现区间 [$first, $last]',
    line: 'return new int[]',
    sorted: {if (first >= 0) first, if (last >= 0) last},
  );
  return collector.build();
}

const String searchRotatedCode = '''class Solution {
    public int search(int[] nums, int target) {
        int left = 0, right = nums.length - 1;
        while (left <= right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] == target) return mid;
            if (nums[left] <= nums[mid]) {
                if (target >= nums[left] && target < nums[mid]) right = mid - 1;
                else left = mid + 1;
            } else {
                if (target > nums[mid] && target <= nums[right]) left = mid + 1;
                else right = mid - 1;
            }
        }
        return -1;
    }
}''';

List<SceneFrame> searchRotatedScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final target = intOf(input['target']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, searchRotatedCode);
  var left = 0;
  var right = nums.length - 1;

  scene.show('在旋转有序数组中搜索 $target', line: 'int left');
  while (left <= right) {
    final mid = left + (right - left) ~/ 2;
    final pivotSide = nums[left] <= nums[mid];
    scene.show(
      'mid = $mid, nums[$mid] = ${nums[mid]}, ${pivotSide ? "左半段有序" : "右半段有序"}',
      line: 'int mid',
      pointers: {'left': left, 'mid': mid, 'right': right},
      highlight: {mid},
    );
    if (nums[mid] == target) {
      scene.show('找到 target, 下标 $mid', line: 'return mid', highlight: {mid}, sorted: {mid});
      return collector.build();
    }
    if (pivotSide) {
      if (target >= nums[left] && target < nums[mid]) {
        right = mid - 1;
        scene.show('target 在有序左半段, right = $right', line: 'right = mid - 1');
      } else {
        left = mid + 1;
        scene.show('target 不在左半段, left = $left', line: 'else left = mid + 1');
      }
    } else {
      if (target > nums[mid] && target <= nums[right]) {
        left = mid + 1;
        scene.show('target 在有序右半段, left = $left', line: 'left = mid + 1');
      } else {
        right = mid - 1;
        scene.show('target 不在右半段, right = $right', line: 'else right = mid - 1');
      }
    }
  }
  scene.show('未找到 target, 返回 -1', line: 'return -1');
  return collector.build();
}

const String findMinRotatedCode = '''class Solution {
    public int findMin(int[] nums) {
        int left = 0, right = nums.length - 1;
        while (left < right) {
            int mid = left + (right - left) / 2;
            if (nums[mid] > nums[right]) left = mid + 1;
            else right = mid;
        }
        return nums[left];
    }
}''';

List<SceneFrame> findMinRotatedScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, findMinRotatedCode);
  var left = 0;
  var right = nums.length - 1;

  scene.show('最小值一定在无序的那一侧', line: 'int left');
  while (left < right) {
    final mid = left + (right - left) ~/ 2;
    scene.show(
      'mid = $mid, nums[$mid] = ${nums[mid]}, nums[$right] = ${nums[right]}',
      line: 'int mid',
      pointers: {'left': left, 'mid': mid, 'right': right},
      highlight: {mid},
    );
    if (nums[mid] > nums[right]) {
      left = mid + 1;
      scene.show('左半段有序, 最小值在右边, left = $left', line: 'left = mid + 1');
    } else {
      right = mid;
      scene.show('右半段有序, 最小值在左边, right = $right', line: 'else right = mid');
    }
  }
  scene.show('最小值 = ${nums[left]}', line: 'return nums[left]', highlight: {left}, sorted: {left});
  return collector.build();
}

const String findMedianCode = '''class Solution {
    public double findMedianSortedArrays(int[] a, int[] b) {
        if (a.length > b.length) return findMedianSortedArrays(b, a);
        int m = a.length, n = b.length, half = (m + n + 1) / 2;
        int left = 0, right = m;
        while (left <= right) {
            int i = left + (right - left) / 2;
            int j = half - i;
            int aL = i == 0 ? Integer.MIN_VALUE : a[i - 1];
            int aR = i == m ? Integer.MAX_VALUE : a[i];
            int bL = j == 0 ? Integer.MIN_VALUE : b[j - 1];
            int bR = j == n ? Integer.MAX_VALUE : b[j];
            if (aL <= bR && bL <= aR) {
                int maxL = Math.max(aL, bL);
                int minR = Math.min(aR, bR);
                return (m + n) % 2 == 1 ? maxL : (maxL + minR) / 2.0;
            }
            if (aL > bR) right = i - 1;
            else left = i + 1;
        }
        return 0.0;
    }
}''';

List<SceneFrame> findMedianScript(Map<String, dynamic> input) {
  final a = intList(input['nums1']);
  final b = intList(input['nums2']);
  checkSize(a.length + b.length, 60, 'nums');
  final collector = FrameCollector();
  final grid = <List<dynamic>>[List<dynamic>.from(a), List<dynamic>.from(b)];
  final scene = GridScene(collector, grid, findMedianCode);

  scene.show('在较短数组上划分: 第一行长度 ${a.length}', line: 'if (a.length > b.length)');
  final m = a.length;
  final n = b.length;
  final half = (m + n + 1) ~/ 2;
  var left = 0;
  var right = m;
  while (left <= right) {
    final i = left + (right - left) ~/ 2;
    final j = half - i;
    final aL = i == 0 ? -999999 : a[i - 1];
    final aR = i == m ? 999999 : a[i];
    final bL = j <= 0 ? -999999 : b[j - 1];
    final bR = j >= n ? 999999 : b[j];
    scene.show(
      'i = $i, j = $j, aL=$aL aR=$aR bL=$bL bR=$bR',
      line: 'int i = left',
      pointers: {
        if (i > 0) 'aL': (0, i - 1),
        if (i < m) 'aR': (0, i),
        if (j > 0) 'bL': (1, j - 1),
        if (j < n) 'bR': (1, j),
      },
    );
    if (aL <= bR && bL <= aR) {
      final maxL = aL > bL ? aL : bL;
      final minR = aR < bR ? aR : bR;
      final median = (m + n).isOdd ? maxL : (maxL + minR) / 2.0;
      scene.show('划分成立, 中位数 = $median', line: 'return (m + n)', highlight: {
        if (i > 0) (0, i - 1),
        if (i < m) (0, i),
        if (j > 0) (1, j - 1),
        if (j < n) (1, j),
      });
      return collector.build();
    }
    if (aL > bR) {
      right = i - 1;
      scene.show('aL > bR, right = $right', line: 'right = i - 1');
    } else {
      left = i + 1;
      scene.show('bL > aR, left = $left', line: 'else left = i + 1');
    }
  }
  return collector.build();
}

// ===========================================================================
// 题目注册
// ===========================================================================

List<ProblemEntry> batch2Problems() => [
      buildProblem(
        slug: 'maximum-subarray',
        number: 53,
        title: '最大子数组和',
        difficulty: ProblemDifficulty.medium,
        group: 'array',
        pattern: 'array-basic',
        code: maxSubArrayCode,
        presets: [
          preset('示例 1', {'nums': [-2, 1, -3, 4, -1, 2, 1, -5, 4]}),
          preset('示例 2', {'nums': [1]}),
          preset('示例 3', {'nums': [5, 4, -1, 7, 8]}),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: maxSubArrayScript,
      ),
      buildProblem(
        slug: 'merge-intervals',
        number: 56,
        title: '合并区间',
        difficulty: ProblemDifficulty.medium,
        group: 'array',
        pattern: 'array-basic',
        code: mergeIntervalsCode,
        presets: [
          preset('示例 1', {
            'intervals': [
              [1, 3],
              [2, 6],
              [8, 10],
              [15, 18],
            ],
          }),
          preset('示例 2', {
            'intervals': [
              [1, 4],
              [4, 5],
            ],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.matrix('intervals', maxRows: 20, maxCols: 2),
        ]),
        script: mergeIntervalsScript,
        maxInputSize: 20,
      ),
      buildProblem(
        slug: 'rotate-array',
        number: 189,
        title: '轮转数组',
        difficulty: ProblemDifficulty.medium,
        group: 'array',
        pattern: 'array-basic',
        code: rotateArrayCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3, 4, 5, 6, 7],
            'k': 3,
          }),
          preset('示例 2', {
            'nums': [-1, -100, 3, 99],
            'k': 2,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('k', minValue: 0, maxValue: 1000),
        ]),
        script: rotateArrayScript,
      ),
      buildProblem(
        slug: 'product-of-array-except-self',
        number: 238,
        title: '除自身以外数组的乘积',
        difficulty: ProblemDifficulty.medium,
        group: 'array',
        pattern: 'array-basic',
        code: productExceptSelfCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3, 4],
          }),
          preset('示例 2', {
            'nums': [-1, 1, 0, -3, 3],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 60)]),
        script: productExceptSelfScript,
      ),
      buildProblem(
        slug: 'first-missing-positive',
        number: 41,
        title: '缺失的第一个正数',
        difficulty: ProblemDifficulty.hard,
        group: 'array',
        pattern: 'array-basic',
        code: firstMissingPositiveCode,
        presets: [
          preset('示例 1', {'nums': [1, 2, 0]}),
          preset('示例 2', {'nums': [3, 4, -1, 1]}),
          preset('示例 3', {'nums': [7, 8, 9, 11, 12]}),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 60)]),
        script: firstMissingPositiveScript,
      ),
      buildProblem(
        slug: 'set-matrix-zeroes',
        number: 73,
        title: '矩阵置零',
        difficulty: ProblemDifficulty.medium,
        group: 'matrix',
        pattern: 'matrix-grid',
        code: setZeroesCode,
        presets: [
          preset('示例 1', {
            'matrix': [
              [1, 1, 1],
              [1, 0, 1],
              [1, 1, 1],
            ],
          }),
          preset('示例 2', {
            'matrix': [
              [0, 1, 2, 0],
              [3, 4, 5, 2],
              [1, 3, 1, 5],
            ],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.matrix('matrix', maxRows: 20, maxCols: 20),
        ]),
        script: setZeroesScript,
        maxInputSize: 20,
      ),
      buildProblem(
        slug: 'spiral-matrix',
        number: 54,
        title: '螺旋矩阵',
        difficulty: ProblemDifficulty.medium,
        group: 'matrix',
        pattern: 'matrix-grid',
        code: spiralOrderCode,
        presets: [
          preset('示例 1', {
            'matrix': [
              [1, 2, 3],
              [4, 5, 6],
              [7, 8, 9],
            ],
          }),
          preset('示例 2', {
            'matrix': [
              [1, 2, 3, 4],
              [5, 6, 7, 8],
              [9, 10, 11, 12],
            ],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.matrix('matrix', maxRows: 20, maxCols: 20),
        ]),
        script: spiralOrderScript,
        maxInputSize: 20,
      ),
      buildProblem(
        slug: 'rotate-image',
        number: 48,
        title: '旋转图像',
        difficulty: ProblemDifficulty.medium,
        group: 'matrix',
        pattern: 'matrix-grid',
        code: rotateImageCode,
        presets: [
          preset('示例 1', {
            'matrix': [
              [1, 2, 3],
              [4, 5, 6],
              [7, 8, 9],
            ],
          }),
          preset('示例 2', {
            'matrix': [
              [5, 1, 9, 11],
              [2, 4, 8, 10],
              [13, 3, 6, 7],
              [15, 14, 12, 16],
            ],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.matrix('matrix', maxRows: 20, maxCols: 20),
        ]),
        script: rotateImageScript,
        maxInputSize: 20,
      ),
      buildProblem(
        slug: 'search-a-2d-matrix-ii',
        number: 240,
        title: '搜索二维矩阵 II',
        difficulty: ProblemDifficulty.medium,
        group: 'matrix',
        pattern: 'matrix-grid',
        code: searchMatrix2Code,
        presets: [
          preset('示例 1', {
            'matrix': [
              [1, 4, 7, 11, 15],
              [2, 5, 8, 12, 19],
              [3, 6, 9, 16, 22],
              [10, 13, 14, 17, 24],
            ],
            'target': 5,
          }),
          preset('示例 2', {
            'matrix': [
              [1, 4, 7],
              [2, 5, 8],
            ],
            'target': 6,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.matrix('matrix', maxRows: 20, maxCols: 20),
          InputField.int('target', minValue: -10000, maxValue: 10000),
        ]),
        script: searchMatrix2Script,
        maxInputSize: 20,
      ),
      buildProblem(
        slug: 'search-insert-position',
        number: 35,
        title: '搜索插入位置',
        difficulty: ProblemDifficulty.easy,
        group: 'binary-search',
        pattern: 'array-binary-search',
        code: searchInsertCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 3, 5, 6],
            'target': 5,
          }),
          preset('示例 2', {
            'nums': [1, 3, 5, 6],
            'target': 2,
          }),
          preset('示例 3', {
            'nums': [1, 3, 5, 6],
            'target': 7,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('target', minValue: -10000, maxValue: 10000),
        ]),
        script: searchInsertScript,
      ),
      buildProblem(
        slug: 'search-a-2d-matrix',
        number: 74,
        title: '搜索二维矩阵',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-search',
        pattern: 'array-binary-search',
        code: searchMatrixCode,
        presets: [
          preset('示例 1', {
            'matrix': [
              [1, 3, 5, 7],
              [10, 11, 16, 20],
              [23, 30, 34, 60],
            ],
            'target': 3,
          }),
          preset('示例 2', {
            'matrix': [
              [1, 3, 5, 7],
              [10, 11, 16, 20],
            ],
            'target': 13,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.matrix('matrix', maxRows: 20, maxCols: 20),
          InputField.int('target', minValue: -10000, maxValue: 10000),
        ]),
        script: searchMatrixScript,
        maxInputSize: 20,
      ),
      buildProblem(
        slug: 'find-first-and-last-position-of-element-in-sorted-array',
        number: 34,
        title: '在排序数组中查找元素的第一个和最后一个位置',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-search',
        pattern: 'array-binary-search',
        code: searchRangeCode,
        presets: [
          preset('示例 1', {
            'nums': [5, 7, 7, 8, 8, 10],
            'target': 8,
          }),
          preset('示例 2', {
            'nums': [5, 7, 7, 8, 8, 10],
            'target': 6,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('target', minValue: -10000, maxValue: 10000),
        ]),
        script: searchRangeScript,
      ),
      buildProblem(
        slug: 'search-in-rotated-sorted-array',
        number: 33,
        title: '搜索旋转排序数组',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-search',
        pattern: 'array-binary-search',
        code: searchRotatedCode,
        presets: [
          preset('示例 1', {
            'nums': [4, 5, 6, 7, 0, 1, 2],
            'target': 0,
          }),
          preset('示例 2', {
            'nums': [4, 5, 6, 7, 0, 1, 2],
            'target': 3,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('target', minValue: -10000, maxValue: 10000),
        ]),
        script: searchRotatedScript,
      ),
      buildProblem(
        slug: 'find-minimum-in-rotated-sorted-array',
        number: 153,
        title: '寻找旋转排序数组中的最小值',
        difficulty: ProblemDifficulty.medium,
        group: 'binary-search',
        pattern: 'array-binary-search',
        code: findMinRotatedCode,
        presets: [
          preset('示例 1', {
            'nums': [3, 4, 5, 1, 2],
          }),
          preset('示例 2', {
            'nums': [4, 5, 6, 7, 0, 1, 2],
          }),
          preset('示例 3', {
            'nums': [11, 13, 15, 17],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: findMinRotatedScript,
      ),
      buildProblem(
        slug: 'median-of-two-sorted-arrays',
        number: 4,
        title: '寻找两个正序数组的中位数',
        difficulty: ProblemDifficulty.hard,
        group: 'binary-search',
        pattern: 'array-binary-search',
        code: findMedianCode,
        presets: [
          preset('示例 1', {
            'nums1': [1, 3],
            'nums2': [2],
          }),
          preset('示例 2', {
            'nums1': [1, 2],
            'nums2': [3, 4],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums1', maxLength: 40),
          InputField.array('nums2', maxLength: 40),
        ]),
        script: findMedianScript,
      ),
    ];
