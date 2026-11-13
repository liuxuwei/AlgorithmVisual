import '../../catalog/problem_entry.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/scene_frame.dart';
import '../script_helpers.dart';

// ===========================================================================
// 一维动态规划 (10)
// ===========================================================================

const String climbStairsCode = '''class Solution {
    public int climbStairs(int n) {
        if (n <= 2) return n;
        int[] dp = new int[n + 1];
        dp[1] = 1;
        dp[2] = 2;
        for (int i = 3; i <= n; i++) {
            dp[i] = dp[i - 1] + dp[i - 2];
        }
        return dp[n];
    }
}''';

List<SceneFrame> climbStairsScript(Map<String, dynamic> input) {
  final n = intOf(input['n']);
  if (n <= 0 || n > 60) throw ArgumentError('n 必须在 1 到 60 之间');
  final collector = FrameCollector();
  final scene = DpScene(collector, 1, n + 1, climbStairsCode);

  scene.set(0, 1, 1);
  if (n >= 2) scene.set(0, 2, 2);
  scene.show('dp[1] = 1, dp[2] = 2', line: 'dp[2] = 2', highlight: {(0, n <= 2 ? n : 2)});

  for (var i = 3; i <= n; i++) {
    final value = (scene.table[0][i - 1] as int) + (scene.table[0][i - 2] as int);
    scene.set(0, i, value);
    scene.show(
      'dp[$i] = dp[${i - 1}] + dp[${i - 2}] = $value',
      line: 'dp[i] = dp[i - 1] + dp[i - 2]',
      highlight: {(0, i)},
      pointers: {'i': (0, i)},
    );
  }

  scene.show('爬到第 $n 阶共有 ${scene.table[0][n]} 种方法', line: 'return dp[n]', highlight: {(0, n)});
  return collector.build();
}

const String pascalsCode = '''class Solution {
    public List<List<Integer>> generate(int numRows) {
        List<List<Integer>> ans = new ArrayList<>();
        for (int i = 0; i < numRows; i++) {
            List<Integer> row = new ArrayList<>();
            for (int j = 0; j <= i; j++) {
                if (j == 0 || j == i) row.add(1);
                else row.add(ans.get(i - 1).get(j - 1) + ans.get(i - 1).get(j));
            }
            ans.add(row);
        }
        return ans;
    }
}''';

List<SceneFrame> pascalsScript(Map<String, dynamic> input) {
  final n = intOf(input['numRows']);
  if (n <= 0 || n > 30) throw ArgumentError('行数必须在 1 到 30 之间');
  final collector = FrameCollector();
  final scene = DpScene(collector, n, n, pascalsCode);

  scene.show('杨辉三角: 每行首尾为 1, 中间为上一行两数之和', line: 'List<List<Integer>> ans');

  for (var i = 0; i < n; i++) {
    for (var j = 0; j <= i; j++) {
      if (j == 0 || j == i) {
        scene.set(i, j, 1);
      } else {
        final value = (scene.table[i - 1][j - 1] as int) + (scene.table[i - 1][j] as int);
        scene.set(i, j, value);
      }
    }
    scene.show(
      '第 $i 行: ${scene.table[i].sublist(0, i + 1)}',
      line: 'ans.add(row)',
      highlight: {
        for (var j = 0; j <= i; j++) (i, j),
      },
    );
  }

  scene.show('杨辉三角前 $n 行生成完成', line: 'return ans');
  return collector.build();
}

const String houseRobberCode = '''class Solution {
    public int rob(int[] nums) {
        int n = nums.length;
        int[] dp = new int[n + 1];
        dp[1] = nums[0];
        for (int i = 2; i <= n; i++) {
            dp[i] = Math.max(dp[i - 1], dp[i - 2] + nums[i - 1]);
        }
        return dp[n];
    }
}''';

List<SceneFrame> houseRobberScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = DpScene(collector, 1, nums.length + 1, houseRobberCode);

  scene.set(0, 0, 0);
  scene.set(0, 1, nums[0]);
  scene.show('dp[0] = 0, dp[1] = ${nums[0]}', line: 'dp[1] = nums[0]', highlight: {(0, 1)});

  for (var i = 2; i <= nums.length; i++) {
    final skip = scene.table[0][i - 1] as int;
    final take = (scene.table[0][i - 2] as int) + nums[i - 1];
    final value = skip > take ? skip : take;
    scene.set(0, i, value);
    scene.show(
      '到第 $i 间: 不偷 = $skip, 偷 = ${nums[i - 1]} + dp[${i - 2}] = $take, 取 $value',
      line: 'dp[i] = Math.max(dp[i - 1], dp[i - 2] + nums[i - 1])',
      highlight: {(0, i)},
    );
  }

  scene.show('能偷到的最高金额 = ${scene.table[0][nums.length]}', line: 'return dp[n]', highlight: {(0, nums.length)});
  return collector.build();
}

const String perfectSquaresCode = '''class Solution {
    public int numSquares(int n) {
        int[] dp = new int[n + 1];
        for (int i = 1; i <= n; i++) {
            dp[i] = i;
            for (int j = 1; j * j <= i; j++) {
                dp[i] = Math.min(dp[i], dp[i - j * j] + 1);
            }
        }
        return dp[n];
    }
}''';

List<SceneFrame> perfectSquaresScript(Map<String, dynamic> input) {
  final n = intOf(input['n']);
  if (n <= 0 || n > 100) throw ArgumentError('n 必须在 1 到 100 之间');
  final collector = FrameCollector();
  final scene = DpScene(collector, 1, n + 1, perfectSquaresCode);
  scene.set(0, 0, 0);

  scene.show('dp[i] 表示和为 i 的最少完全平方数个数', line: 'int[] dp = new int[n + 1]');

  for (var i = 1; i <= n; i++) {
    var best = i;
    for (var j = 1; j * j <= i; j++) {
      final candidate = (scene.table[0][i - j * j] as int) + 1;
      if (candidate < best) best = candidate;
    }
    scene.set(0, i, best);
    scene.show(
      'dp[$i] = $best',
      line: 'dp[i] = Math.min(dp[i], dp[i - j * j] + 1)',
      highlight: {(0, i)},
    );
  }

  scene.show('和为 $n 的最少完全平方数个数 = ${scene.table[0][n]}', line: 'return dp[n]', highlight: {(0, n)});
  return collector.build();
}

const String coinChangeCode = '''class Solution {
    public int coinChange(int[] coins, int amount) {
        int[] dp = new int[amount + 1];
        Arrays.fill(dp, amount + 1);
        dp[0] = 0;
        for (int i = 1; i <= amount; i++) {
            for (int coin : coins) {
                if (coin <= i) {
                    dp[i] = Math.min(dp[i], dp[i - coin] + 1);
                }
            }
        }
        return dp[amount] > amount ? -1 : dp[amount];
    }
}''';

List<SceneFrame> coinChangeScript(Map<String, dynamic> input) {
  final coins = intList(input['coins']);
  final amount = intOf(input['amount']);
  if (coins.isEmpty) throw ArgumentError('硬币数组不能为空');
  if (amount < 0 || amount > 100) throw ArgumentError('金额必须在 0 到 100 之间');
  checkSize(coins.length, 20, 'coins');
  final collector = FrameCollector();
  final scene = DpScene(collector, 1, amount + 1, coinChangeCode);
  final inf = amount + 1;
  for (var i = 0; i <= amount; i++) {
    scene.set(0, i, inf);
  }
  scene.set(0, 0, 0);

  scene.show('dp[i] 表示凑出金额 i 的最少硬币数, 初始为无穷大', line: 'Arrays.fill(dp, amount + 1)');

  for (var i = 1; i <= amount; i++) {
    var best = inf;
    for (final coin in coins) {
      if (coin <= i) {
        final candidate = (scene.table[0][i - coin] as int) + 1;
        if (candidate < best) best = candidate;
      }
    }
    scene.set(0, i, best);
    scene.show(
      'dp[$i] = $best',
      line: 'dp[i] = Math.min(dp[i], dp[i - coin] + 1)',
      highlight: {(0, i)},
    );
  }

  final result = scene.table[0][amount] as int;
  scene.show(
    result > amount ? '无法凑出金额 $amount' : '凑出金额 $amount 最少需要 $result 枚硬币',
    line: 'return dp[amount] > amount ? -1 : dp[amount]',
    highlight: {(0, amount)},
  );
  return collector.build();
}

const String wordBreakCode = '''class Solution {
    public boolean wordBreak(String s, List<String> wordDict) {
        Set<String> dict = new HashSet<>(wordDict);
        boolean[] dp = new boolean[s.length() + 1];
        dp[0] = true;
        for (int i = 1; i <= s.length(); i++) {
            for (int j = 0; j < i; j++) {
                if (dp[j] && dict.contains(s.substring(j, i))) {
                    dp[i] = true;
                    break;
                }
            }
        }
        return dp[s.length()];
    }
}''';

List<SceneFrame> wordBreakScript(Map<String, dynamic> input) {
  final text = strOf(input['s']);
  final words = splitWords(strOf(input['wordDict']));
  if (text.isEmpty || words.isEmpty) throw ArgumentError('字符串与字典都不能为空');
  checkSize(text.length, 40, 's');
  final dict = words.toSet();
  final collector = FrameCollector();
  final scene = DpScene(collector, 1, text.length + 1, wordBreakCode);
  for (var i = 0; i <= text.length; i++) {
    scene.set(0, i, i == 0);
  }

  scene.show('dp[i] 表示前 i 个字符能否被拆分', line: 'boolean[] dp');

  for (var i = 1; i <= text.length; i++) {
    var ok = false;
    String? hit;
    for (var j = 0; j < i; j++) {
      if (scene.table[0][j] == true && dict.contains(text.substring(j, i))) {
        ok = true;
        hit = text.substring(j, i);
        break;
      }
    }
    scene.table[0][i] = ok;
    scene.computed.add((0, i));
    scene.show(
      ok ? '前 $i 个字符可拆分, 末尾匹配单词 "$hit"' : '前 $i 个字符不可拆分',
      line: 'if (dp[j] && dict.contains(s.substring(j, i)))',
      highlight: {(0, i)},
    );
  }

  scene.show(
    scene.table[0][text.length] == true ? '"$text" 可以被拆分' : '"$text" 不能被拆分',
    line: 'return dp[s.length()]',
    highlight: {(0, text.length)},
  );
  return collector.build();
}

const String lisCode = '''class Solution {
    public int lengthOfLIS(int[] nums) {
        int n = nums.length;
        int[] dp = new int[n];
        int best = 1;
        for (int i = 0; i < n; i++) {
            dp[i] = 1;
            for (int j = 0; j < i; j++) {
                if (nums[j] < nums[i]) dp[i] = Math.max(dp[i], dp[j] + 1);
            }
            best = Math.max(best, dp[i]);
        }
        return best;
    }
}''';

List<SceneFrame> lisScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = DpScene(collector, 1, nums.length, lisCode);
  var best = 1;

  scene.show('dp[i] 表示以 nums[i] 结尾的最长递增子序列长度', line: 'int[] dp');

  for (var i = 0; i < nums.length; i++) {
    var value = 1;
    for (var j = 0; j < i; j++) {
      if (nums[j] < nums[i]) {
        final candidate = (scene.table[0][j] as int) + 1;
        if (candidate > value) value = candidate;
      }
    }
    scene.set(0, i, value);
    if (value > best) best = value;
    scene.show(
      'dp[$i] = $value (nums[$i] = ${nums[i]}), 当前最长 $best',
      line: 'best = Math.max(best, dp[i])',
      highlight: {(0, i)},
    );
  }

  scene.show('最长递增子序列长度 = $best', line: 'return best');
  return collector.build();
}

const String maxProductCode = '''class Solution {
    public int maxProduct(int[] nums) {
        int max = nums[0], min = nums[0], best = nums[0];
        for (int i = 1; i < nums.length; i++) {
            int a = max * nums[i];
            int b = min * nums[i];
            max = Math.max(nums[i], Math.max(a, b));
            min = Math.min(nums[i], Math.min(a, b));
            best = Math.max(best, max);
        }
        return best;
    }
}''';

List<SceneFrame> maxProductScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, maxProductCode);
  var max = nums[0];
  var min = nums[0];
  var best = nums[0];

  scene.show('同时维护最大和最小乘积, 处理负数', line: 'int max = nums[0]', pointers: {'i': 0}, highlight: {0});

  for (var i = 1; i < nums.length; i++) {
    final a = max * nums[i];
    final b = min * nums[i];
    var nextMax = nums[i];
    if (a > nextMax) nextMax = a;
    if (b > nextMax) nextMax = b;
    var nextMin = nums[i];
    if (a < nextMin) nextMin = a;
    if (b < nextMin) nextMin = b;
    max = nextMax;
    min = nextMin;
    if (max > best) best = max;
    scene.show(
      'nums[$i] = ${nums[i]}, max = $max, min = $min, 最大乘积 $best',
      line: 'best = Math.max(best, max)',
      pointers: {'i': i},
      highlight: {i},
    );
  }

  scene.show('乘积最大的连续子数组乘积 = $best', line: 'return best');
  return collector.build();
}

const String canPartitionCode = '''class Solution {
    public boolean canPartition(int[] nums) {
        int sum = 0;
        for (int num : nums) sum += num;
        if (sum % 2 != 0) return false;
        int target = sum / 2;
        boolean[] dp = new boolean[target + 1];
        dp[0] = true;
        for (int num : nums) {
            for (int j = target; j >= num; j--) {
                dp[j] = dp[j] || dp[j - num];
            }
        }
        return dp[target];
    }
}''';

List<SceneFrame> canPartitionScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 60, 'nums');
  final total = nums.fold<int>(0, (a, b) => a + b);
  final collector = FrameCollector();
  final target = total ~/ 2;
  final scene = DpScene(collector, 1, target + 1, canPartitionCode);
  if (total.isOdd) {
    scene.show('总和 $total 为奇数, 无法分成两个等和子集', line: 'if (sum % 2 != 0) return false');
    return collector.build();
  }
  for (var i = 0; i <= target; i++) {
    scene.set(0, i, i == 0);
  }

  scene.show('目标和 = $total / 2 = $target, dp[0] = true', line: 'int target = sum / 2');

  for (final num in nums) {
    for (var j = target; j >= num; j--) {
      final ok = scene.table[0][j] == true || scene.table[0][j - num] == true;
      scene.table[0][j] = ok;
      scene.computed.add((0, j));
    }
    scene.show(
      '处理数字 $num, 更新可达子集和',
      line: 'dp[j] = dp[j] || dp[j - num]',
      highlight: {(0, target)},
    );
  }

  scene.show(
    scene.table[0][target] == true ? '可以分割成两个等和子集' : '无法分割成两个等和子集',
    line: 'return dp[target]',
    highlight: {(0, target)},
  );
  return collector.build();
}

const String longestValidParenthesesCode = '''class Solution {
    public int longestValidParentheses(String s) {
        int n = s.length();
        int[] dp = new int[n];
        int best = 0;
        for (int i = 1; i < n; i++) {
            if (s.charAt(i) == ')') {
                if (s.charAt(i - 1) == '(') {
                    dp[i] = (i >= 2 ? dp[i - 2] : 0) + 2;
                } else if (i - dp[i - 1] - 1 >= 0 && s.charAt(i - dp[i - 1] - 1) == '(') {
                    dp[i] = dp[i - 1] + 2 + (i - dp[i - 1] - 2 >= 0 ? dp[i - dp[i - 1] - 2] : 0);
                }
                best = Math.max(best, dp[i]);
            }
        }
        return best;
    }
}''';

List<SceneFrame> longestValidParenthesesScript(Map<String, dynamic> input) {
  final text = strOf(input['s']);
  if (text.isEmpty) throw ArgumentError('字符串不能为空');
  checkSize(text.length, 60, 's');
  final collector = FrameCollector();
  final scene = DpScene(collector, 1, text.length, longestValidParenthesesCode);
  for (var i = 0; i < text.length; i++) {
    scene.set(0, i, 0);
  }
  var best = 0;

  scene.show('dp[i] 表示以 i 结尾的最长有效括号长度', line: 'int[] dp');

  for (var i = 1; i < text.length; i++) {
    if (text[i] == ')') {
      if (text[i - 1] == '(') {
        final value = (i >= 2 ? scene.table[0][i - 2] as int : 0) + 2;
        scene.set(0, i, value);
      } else {
        final match = i - (scene.table[0][i - 1] as int) - 1;
        if (match >= 0 && text[match] == '(') {
          final previous = scene.table[0][i - 1] as int;
          final extra = match - 1 >= 0 ? scene.table[0][match - 1] as int : 0;
          scene.set(0, i, previous + 2 + extra);
        }
      }
      final value = scene.table[0][i] as int;
      if (value > best) best = value;
      scene.show(
        '到下标 $i 为止最长有效长度 = $value',
        line: 'best = Math.max(best, dp[i])',
        highlight: {(0, i)},
      );
    }
  }

  scene.show('最长有效括号长度 = $best', line: 'return best');
  return collector.build();
}

// ===========================================================================
// 二维动态规划 (5)
// ===========================================================================

const String uniquePathsCode = '''class Solution {
    public int uniquePaths(int m, int n) {
        int[][] dp = new int[m][n];
        for (int i = 0; i < m; i++) dp[i][0] = 1;
        for (int j = 0; j < n; j++) dp[0][j] = 1;
        for (int i = 1; i < m; i++) {
            for (int j = 1; j < n; j++) {
                dp[i][j] = dp[i - 1][j] + dp[i][j - 1];
            }
        }
        return dp[m - 1][n - 1];
    }
}''';

List<SceneFrame> uniquePathsScript(Map<String, dynamic> input) {
  final m = intOf(input['m']);
  final n = intOf(input['n']);
  if (m <= 0 || n <= 0 || m > 20 || n > 20) throw ArgumentError('m 与 n 必须在 1 到 20 之间');
  final collector = FrameCollector();
  final scene = DpScene(collector, m, n, uniquePathsCode);

  for (var i = 0; i < m; i++) {
    scene.set(i, 0, 1);
  }
  for (var j = 0; j < n; j++) {
    scene.set(0, j, 1);
  }
  scene.show('第一行与第一列都只有一种走法', line: 'dp[i][0] = 1');

  for (var i = 1; i < m; i++) {
    for (var j = 1; j < n; j++) {
      final value = (scene.table[i - 1][j] as int) + (scene.table[i][j - 1] as int);
      scene.set(i, j, value);
      scene.show(
        'dp[$i][$j] = ${scene.table[i - 1][j]} + ${scene.table[i][j - 1]} = $value',
        line: 'dp[i][j] = dp[i - 1][j] + dp[i][j - 1]',
        highlight: {(i, j)},
      );
    }
  }

  scene.show('不同路径数 = ${scene.table[m - 1][n - 1]}', line: 'return dp[m - 1][n - 1]', highlight: {(m - 1, n - 1)});
  return collector.build();
}

const String minPathSumCode = '''class Solution {
    public int minPathSum(int[][] grid) {
        int m = grid.length, n = grid[0].length;
        int[][] dp = new int[m][n];
        dp[0][0] = grid[0][0];
        for (int i = 1; i < m; i++) dp[i][0] = dp[i - 1][0] + grid[i][0];
        for (int j = 1; j < n; j++) dp[0][j] = dp[0][j - 1] + grid[0][j];
        for (int i = 1; i < m; i++) {
            for (int j = 1; j < n; j++) {
                dp[i][j] = Math.min(dp[i - 1][j], dp[i][j - 1]) + grid[i][j];
            }
        }
        return dp[m - 1][n - 1];
    }
}''';

List<SceneFrame> minPathSumScript(Map<String, dynamic> input) {
  final grid = intMatrix(input['grid']);
  if (grid.isEmpty || grid.first.isEmpty) throw ArgumentError('网格不能为空');
  final m = grid.length;
  final n = grid.first.length;
  if (m > 20 || n > 20) throw ArgumentError('网格不能超过 20 x 20');
  final collector = FrameCollector();
  final scene = DpScene(collector, m, n, minPathSumCode);

  scene.set(0, 0, grid[0][0]);
  scene.show('dp[0][0] = ${grid[0][0]}', line: 'dp[0][0] = grid[0][0]', highlight: {(0, 0)});

  for (var i = 1; i < m; i++) {
    scene.set(i, 0, (scene.table[i - 1][0] as int) + grid[i][0]);
  }
  for (var j = 1; j < n; j++) {
    scene.set(0, j, (scene.table[0][j - 1] as int) + grid[0][j]);
  }
  scene.show('第一行与第一列只能沿一个方向累加', line: 'dp[i][0] = dp[i - 1][0] + grid[i][0]');

  for (var i = 1; i < m; i++) {
    for (var j = 1; j < n; j++) {
      final up = scene.table[i - 1][j] as int;
      final left = scene.table[i][j - 1] as int;
      final value = (up < left ? up : left) + grid[i][j];
      scene.set(i, j, value);
      scene.show(
        'dp[$i][$j] = min($up, $left) + ${grid[i][j]} = $value',
        line: 'dp[i][j] = Math.min(dp[i - 1][j], dp[i][j - 1]) + grid[i][j]',
        highlight: {(i, j)},
      );
    }
  }

  scene.show('最小路径和 = ${scene.table[m - 1][n - 1]}', line: 'return dp[m - 1][n - 1]', highlight: {(m - 1, n - 1)});
  return collector.build();
}

const String longestPalindromeCode = '''class Solution {
    public String longestPalindrome(String s) {
        int n = s.length();
        boolean[][] dp = new boolean[n][n];
        int start = 0, maxLen = 1;
        for (int len = 1; len <= n; len++) {
            for (int i = 0; i + len - 1 < n; i++) {
                int j = i + len - 1;
                if (s.charAt(i) == s.charAt(j) && (len <= 2 || dp[i + 1][j - 1])) {
                    dp[i][j] = true;
                    if (len > maxLen) {
                        maxLen = len;
                        start = i;
                    }
                }
            }
        }
        return s.substring(start, start + maxLen);
    }
}''';

List<SceneFrame> longestPalindromeScript(Map<String, dynamic> input) {
  final text = strOf(input['s']);
  if (text.isEmpty) throw ArgumentError('字符串不能为空');
  checkSize(text.length, 40, 's');
  final n = text.length;
  final collector = FrameCollector();
  final scene = DpScene(collector, n, n, longestPalindromeCode);
  var start = 0;
  var maxLen = 1;

  scene.show('dp[i][j] 表示 s[i..j] 是否为回文串', line: 'boolean[][] dp');

  for (var len = 1; len <= n; len++) {
    for (var i = 0; i + len - 1 < n; i++) {
      final j = i + len - 1;
      final inside = len <= 2 || scene.table[i + 1][j - 1] == true;
      if (text[i] == text[j] && inside) {
        scene.table[i][j] = true;
        scene.computed.add((i, j));
        if (len > maxLen) {
          maxLen = len;
          start = i;
        }
        scene.show(
          's[$i..$j] = "${text.substring(i, j + 1)}" 是回文',
          line: 'dp[i][j] = true',
          highlight: {(i, j)},
        );
      } else {
        scene.table[i][j] = false;
        scene.computed.add((i, j));
      }
    }
  }

  scene.show(
    '最长回文子串 = "${text.substring(start, start + maxLen)}"',
    line: 'return s.substring(start, start + maxLen)',
    highlight: {(start, start + maxLen - 1)},
  );
  return collector.build();
}

const String lcsCode = '''class Solution {
    public int longestCommonSubsequence(String text1, String text2) {
        int m = text1.length(), n = text2.length();
        int[][] dp = new int[m + 1][n + 1];
        for (int i = 1; i <= m; i++) {
            for (int j = 1; j <= n; j++) {
                if (text1.charAt(i - 1) == text2.charAt(j - 1)) {
                    dp[i][j] = dp[i - 1][j - 1] + 1;
                } else {
                    dp[i][j] = Math.max(dp[i - 1][j], dp[i][j - 1]);
                }
            }
        }
        return dp[m][n];
    }
}''';

List<SceneFrame> lcsScript(Map<String, dynamic> input) {
  final text1 = strOf(input['text1']);
  final text2 = strOf(input['text2']);
  if (text1.isEmpty || text2.isEmpty) throw ArgumentError('两个字符串都不能为空');
  checkSize(text1.length, 40, 'text1');
  checkSize(text2.length, 40, 'text2');
  final collector = FrameCollector();
  final scene = DpScene(collector, text1.length + 1, text2.length + 1, lcsCode);

  scene.show('dp[i][j] 表示 text1 前 i 个与 text2 前 j 个的最长公共子序列', line: 'int[][] dp');
  for (var i = 0; i <= text1.length; i++) {
    scene.table[0 + i][0] = 0;
    scene.computed.add((i, 0));
  }
  for (var j = 0; j <= text2.length; j++) {
    scene.table[0][j] = 0;
    scene.computed.add((0, j));
  }

  for (var i = 1; i <= text1.length; i++) {
    for (var j = 1; j <= text2.length; j++) {
      final int value;
      if (text1[i - 1] == text2[j - 1]) {
        value = (scene.table[i - 1][j - 1] as int) + 1;
      } else {
        final up = scene.table[i - 1][j] as int;
        final left = scene.table[i][j - 1] as int;
        value = up > left ? up : left;
      }
      scene.set(i, j, value);
      scene.show(
        'dp[$i][$j] = $value',
        line: 'if (text1.charAt(i - 1) == text2.charAt(j - 1))',
        highlight: {(i, j)},
      );
    }
  }

  scene.show(
    '最长公共子序列长度 = ${scene.table[text1.length][text2.length]}',
    line: 'return dp[m][n]',
    highlight: {(text1.length, text2.length)},
  );
  return collector.build();
}

const String editDistanceCode = '''class Solution {
    public int minDistance(String word1, String word2) {
        int m = word1.length(), n = word2.length();
        int[][] dp = new int[m + 1][n + 1];
        for (int i = 0; i <= m; i++) dp[i][0] = i;
        for (int j = 0; j <= n; j++) dp[0][j] = j;
        for (int i = 1; i <= m; i++) {
            for (int j = 1; j <= n; j++) {
                if (word1.charAt(i - 1) == word2.charAt(j - 1)) {
                    dp[i][j] = dp[i - 1][j - 1];
                } else {
                    dp[i][j] = 1 + Math.min(dp[i - 1][j - 1],
                            Math.min(dp[i - 1][j], dp[i][j - 1]));
                }
            }
        }
        return dp[m][n];
    }
}''';

List<SceneFrame> editDistanceScript(Map<String, dynamic> input) {
  final word1 = strOf(input['word1']);
  final word2 = strOf(input['word2']);
  if (word1.isEmpty || word2.isEmpty) throw ArgumentError('两个单词都不能为空');
  checkSize(word1.length, 40, 'word1');
  checkSize(word2.length, 40, 'word2');
  final collector = FrameCollector();
  final scene = DpScene(collector, word1.length + 1, word2.length + 1, editDistanceCode);

  for (var i = 0; i <= word1.length; i++) {
    scene.set(i, 0, i);
  }
  for (var j = 0; j <= word2.length; j++) {
    scene.set(0, j, j);
  }
  scene.show('边界: 只能插入或删除', line: 'dp[0][j] = j');

  for (var i = 1; i <= word1.length; i++) {
    for (var j = 1; j <= word2.length; j++) {
      final int value;
      if (word1[i - 1] == word2[j - 1]) {
        value = scene.table[i - 1][j - 1] as int;
      } else {
        final replace = scene.table[i - 1][j - 1] as int;
        final delete = scene.table[i - 1][j] as int;
        final insert = scene.table[i][j - 1] as int;
        var smallest = replace;
        if (delete < smallest) smallest = delete;
        if (insert < smallest) smallest = insert;
        value = smallest + 1;
      }
      scene.set(i, j, value);
      scene.show(
        'dp[$i][$j] = $value (word1[${i - 1}] = ${word1[i - 1]}, word2[${j - 1}] = ${word2[j - 1]})',
        line: 'dp[i][j] = 1 + Math.min(dp[i - 1][j - 1],',
        highlight: {(i, j)},
      );
    }
  }

  scene.show(
    '最少编辑距离 = ${scene.table[word1.length][word2.length]}',
    line: 'return dp[m][n]',
    highlight: {(word1.length, word2.length)},
  );
  return collector.build();
}

// ===========================================================================
// 技巧 (5)
// ===========================================================================

const String singleNumberCode = '''class Solution {
    public int singleNumber(int[] nums) {
        int result = 0;
        for (int num : nums) {
            result ^= num;
        }
        return result;
    }
}''';

List<SceneFrame> singleNumberScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, singleNumberCode);
  var result = 0;

  scene.show('利用异或: a ^ a = 0, a ^ 0 = a', line: 'int result = 0');

  for (var i = 0; i < nums.length; i++) {
    result ^= nums[i];
    scene.show(
      '异或 ${nums[i]}, 当前结果 $result',
      line: 'result ^= num',
      pointers: {'i': i},
      highlight: {i},
    );
  }

  scene.show('只出现一次的数字 = $result', line: 'return result', sorted: {nums.indexOf(result)});
  return collector.build();
}

const String majorityElementCode = '''class Solution {
    public int majorityElement(int[] nums) {
        int candidate = nums[0];
        int count = 0;
        for (int num : nums) {
            if (count == 0) {
                candidate = num;
            }
            count += (num == candidate) ? 1 : -1;
        }
        return candidate;
    }
}''';

List<SceneFrame> majorityElementScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, majorityElementCode);
  var candidate = nums.first;
  var count = 0;

  scene.show('摩尔投票: 维护候选人和票数', line: 'int candidate = nums[0]');

  for (var i = 0; i < nums.length; i++) {
    if (count == 0) {
      candidate = nums[i];
    }
    count += nums[i] == candidate ? 1 : -1;
    scene.show(
      '处理 ${nums[i]}: 候选 $candidate, 票数 $count',
      line: 'count += (num == candidate) ? 1 : -1',
      pointers: {'i': i},
      highlight: {i},
    );
  }

  scene.show('出现次数超过一半的元素 = $candidate', line: 'return candidate', sorted: {nums.indexOf(candidate)});
  return collector.build();
}

const String sortColorsCode = '''class Solution {
    public void sortColors(int[] nums) {
        int low = 0, mid = 0, high = nums.length - 1;
        while (mid <= high) {
            if (nums[mid] == 0) {
                swap(nums, low++, mid++);
            } else if (nums[mid] == 1) {
                mid++;
            } else {
                swap(nums, mid, high--);
            }
        }
    }
}''';

List<SceneFrame> sortColorsScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, sortColorsCode);
  var low = 0;
  var mid = 0;
  var high = nums.length - 1;

  scene.show('三指针把 0 放左边, 2 放右边', line: 'int low = 0', pointers: {'low': low, 'mid': mid, 'high': high});

  while (mid <= high) {
    if (nums[mid] == 0) {
      final tmp = nums[low];
      nums[low] = nums[mid];
      nums[mid] = tmp;
      low++;
      mid++;
      scene.show('nums[mid] == 0, 与 low 交换', line: 'swap(nums, low++, mid++)', pointers: {'low': low, 'mid': mid, 'high': high}, highlight: {low - 1, mid - 1});
    } else if (nums[mid] == 1) {
      mid++;
      scene.show('nums[mid] == 1, 留在中间', line: 'mid++', pointers: {'low': low, 'mid': mid, 'high': high}, highlight: {mid - 1});
    } else {
      final tmp = nums[mid];
      nums[mid] = nums[high];
      nums[high] = tmp;
      high--;
      scene.show('nums[mid] == 2, 与 high 交换', line: 'swap(nums, mid, high--)', pointers: {'low': low, 'mid': mid, 'high': high}, highlight: {mid, high + 1});
    }
  }

  scene.show('颜色分类完成: $nums', line: 'while (mid <= high)');
  return collector.build();
}

const String nextPermutationCode = '''class Solution {
    public void nextPermutation(int[] nums) {
        int i = nums.length - 2;
        while (i >= 0 && nums[i] >= nums[i + 1]) i--;
        if (i >= 0) {
            int j = nums.length - 1;
            while (nums[j] <= nums[i]) j--;
            swap(nums, i, j);
        }
        reverse(nums, i + 1, nums.length - 1);
    }
}''';

List<SceneFrame> nextPermutationScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 40, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, nextPermutationCode);

  scene.show('从右向左找第一个升序对', line: 'int i = nums.length - 2');
  var i = nums.length - 2;
  while (i >= 0 && nums[i] >= nums[i + 1]) {
    scene.show(
      'nums[$i] >= nums[${i + 1}], 继续左移',
      line: 'while (i >= 0 && nums[i] >= nums[i + 1]) i--',
      highlight: {i, i + 1},
    );
    i--;
  }

  if (i >= 0) {
    var j = nums.length - 1;
    while (nums[j] <= nums[i]) {
      j--;
    }
    final tmp = nums[i];
    nums[i] = nums[j];
    nums[j] = tmp;
    scene.show(
      '找到 nums[$i] = ${nums[j]}, 与右侧第一个更大值 nums[$j] = ${nums[i]} 交换',
      line: 'swap(nums, i, j)',
      highlight: {i, j},
    );
  } else {
    scene.show('已经是最大排列, 直接反转整个数组', line: 'reverse(nums, i + 1, nums.length - 1)');
  }

  var left = i + 1;
  var right = nums.length - 1;
  while (left < right) {
    final tmp = nums[left];
    nums[left] = nums[right];
    nums[right] = tmp;
    left++;
    right--;
  }
  scene.show('反转后缀, 下一个排列: $nums', line: 'reverse(nums, i + 1, nums.length - 1)', highlight: {});
  return collector.build();
}

const String findDuplicateCode = '''class Solution {
    public int findDuplicate(int[] nums) {
        int slow = nums[0], fast = nums[0];
        do {
            slow = nums[slow];
            fast = nums[nums[fast]];
        } while (slow != fast);
        slow = nums[0];
        while (slow != fast) {
            slow = nums[slow];
            fast = nums[fast];
        }
        return slow;
    }
}''';

List<SceneFrame> findDuplicateScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, findDuplicateCode);

  var slow = nums[0];
  var fast = nums[0];
  scene.show('把下标 i 和 nums[i] 看成一条边, 转化为找环入口', line: 'int slow = nums[0], fast = nums[0]', pointers: {'slow': slow, 'fast': fast});

  do {
    slow = nums[slow];
    fast = nums[nums[fast]];
    scene.show(
      'slow = $slow, fast = $fast',
      line: 'fast = nums[nums[fast]]',
      pointers: {'slow': slow, 'fast': fast},
    );
  } while (slow != fast);

  scene.show('快慢指针相遇于 $slow, 让 slow 回到起点', line: 'slow = nums[0]', pointers: {'slow': slow, 'fast': fast});
  slow = nums[0];
  while (slow != fast) {
    slow = nums[slow];
    fast = nums[fast];
    scene.show(
      'slow = $slow, fast = $fast',
      line: 'slow = nums[slow]',
      pointers: {'slow': slow, 'fast': fast},
    );
  }

  scene.show('重复的数字 = $slow', line: 'return slow', sorted: {nums.indexOf(slow)});
  return collector.build();
}

// ===========================================================================
// 题目描述符
// ===========================================================================

List<ProblemEntry> batch7Problems() => [
      buildProblem(
        slug: 'climbing-stairs',
        number: 70,
        title: '爬楼梯',
        difficulty: ProblemDifficulty.easy,
        group: 'dp',
        pattern: 'dp-1d',
        code: climbStairsCode,
        presets: [
          preset('示例 1', {'n': 2}),
          preset('示例 2', {'n': 5}),
        ],
        schema: InputSchema(fields: [InputField.int('n', minValue: 1, maxValue: 60)]),
        script: climbStairsScript,
      ),
      buildProblem(
        slug: 'pascals-triangle',
        number: 118,
        title: '杨辉三角',
        difficulty: ProblemDifficulty.easy,
        group: 'dp',
        pattern: 'dp-1d',
        code: pascalsCode,
        presets: [
          preset('示例 1', {'numRows': 5}),
          preset('示例 2', {'numRows': 1}),
        ],
        schema: InputSchema(fields: [InputField.int('numRows', minValue: 1, maxValue: 30)]),
        script: pascalsScript,
      ),
      buildProblem(
        slug: 'house-robber',
        number: 198,
        title: '打家劫舍',
        difficulty: ProblemDifficulty.medium,
        group: 'dp',
        pattern: 'dp-1d',
        code: houseRobberCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3, 1],
          }),
          preset('示例 2', {
            'nums': [2, 7, 9, 3, 1],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: houseRobberScript,
      ),
      buildProblem(
        slug: 'perfect-squares',
        number: 279,
        title: '完全平方数',
        difficulty: ProblemDifficulty.medium,
        group: 'dp',
        pattern: 'dp-1d',
        code: perfectSquaresCode,
        presets: [
          preset('示例 1', {'n': 12}),
          preset('示例 2', {'n': 13}),
        ],
        schema: InputSchema(fields: [InputField.int('n', minValue: 1, maxValue: 100)]),
        script: perfectSquaresScript,
      ),
      buildProblem(
        slug: 'coin-change',
        number: 322,
        title: '零钱兑换',
        difficulty: ProblemDifficulty.medium,
        group: 'dp',
        pattern: 'dp-1d',
        code: coinChangeCode,
        presets: [
          preset('示例 1', {
            'coins': [1, 2, 5],
            'amount': 11,
          }),
          preset('示例 2', {
            'coins': [2],
            'amount': 3,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('coins', maxLength: 20),
          InputField.int('amount', minValue: 0, maxValue: 100),
        ]),
        script: coinChangeScript,
      ),
      buildProblem(
        slug: 'word-break',
        number: 139,
        title: '单词拆分',
        difficulty: ProblemDifficulty.medium,
        group: 'dp',
        pattern: 'dp-1d',
        code: wordBreakCode,
        presets: [
          preset('示例 1', {
            's': 'leetcode',
            'wordDict': 'leet code',
          }),
          preset('示例 2', {
            's': 'applepenapple',
            'wordDict': 'apple pen',
          }),
          preset('示例 3', {
            's': 'catsandog',
            'wordDict': 'cats dog sand and cat',
          }),
        ],
        schema: InputSchema(fields: [
          InputField.string('s', maxLength: 40),
          InputField.string('wordDict', maxLength: 200),
        ]),
        script: wordBreakScript,
      ),
      buildProblem(
        slug: 'longest-increasing-subsequence',
        number: 300,
        title: '最长递增子序列',
        difficulty: ProblemDifficulty.medium,
        group: 'dp',
        pattern: 'dp-1d',
        code: lisCode,
        presets: [
          preset('示例 1', {
            'nums': [10, 9, 2, 5, 3, 7, 101, 18],
          }),
          preset('示例 2', {
            'nums': [0, 1, 0, 3, 2, 3],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: lisScript,
      ),
      buildProblem(
        slug: 'maximum-product-subarray',
        number: 152,
        title: '乘积最大子数组',
        difficulty: ProblemDifficulty.medium,
        group: 'dp',
        pattern: 'dp-1d',
        code: maxProductCode,
        presets: [
          preset('示例 1', {
            'nums': [2, 3, -2, 4],
          }),
          preset('示例 2', {
            'nums': [-2, 0, -1],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: maxProductScript,
      ),
      buildProblem(
        slug: 'partition-equal-subset-sum',
        number: 416,
        title: '分割等和子集',
        difficulty: ProblemDifficulty.medium,
        group: 'dp',
        pattern: 'dp-1d',
        code: canPartitionCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 5, 11, 5],
          }),
          preset('示例 2', {
            'nums': [1, 2, 3, 5],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 60)]),
        script: canPartitionScript,
      ),
      buildProblem(
        slug: 'longest-valid-parentheses',
        number: 32,
        title: '最长有效括号',
        difficulty: ProblemDifficulty.hard,
        group: 'dp',
        pattern: 'dp-1d',
        code: longestValidParenthesesCode,
        presets: [
          preset('示例 1', {'s': '(()'}),
          preset('示例 2', {'s': ')()())'}),
        ],
        schema: InputSchema(fields: [InputField.string('s', maxLength: 60)]),
        script: longestValidParenthesesScript,
      ),
      buildProblem(
        slug: 'unique-paths',
        number: 62,
        title: '不同路径',
        difficulty: ProblemDifficulty.medium,
        group: 'dp-multidim',
        pattern: 'dp-2d',
        code: uniquePathsCode,
        presets: [
          preset('示例 1', {'m': 3, 'n': 7}),
          preset('示例 2', {'m': 3, 'n': 2}),
        ],
        schema: InputSchema(fields: [
          InputField.int('m', minValue: 1, maxValue: 20),
          InputField.int('n', minValue: 1, maxValue: 20),
        ]),
        script: uniquePathsScript,
      ),
      buildProblem(
        slug: 'minimum-path-sum',
        number: 64,
        title: '最小路径和',
        difficulty: ProblemDifficulty.medium,
        group: 'dp-multidim',
        pattern: 'dp-2d',
        code: minPathSumCode,
        presets: [
          preset('示例 1', {
            'grid': [
              [1, 3, 1],
              [1, 5, 1],
              [4, 2, 1],
            ],
          }),
          preset('示例 2', {
            'grid': [
              [1, 2, 3],
              [4, 5, 6],
            ],
          }),
        ],
        schema: InputSchema(fields: [InputField.matrix('grid', maxRows: 20, maxCols: 20)]),
        script: minPathSumScript,
      ),
      buildProblem(
        slug: 'longest-palindromic-substring',
        number: 5,
        title: '最长回文子串',
        difficulty: ProblemDifficulty.medium,
        group: 'dp-multidim',
        pattern: 'dp-2d',
        code: longestPalindromeCode,
        presets: [
          preset('示例 1', {'s': 'babad'}),
          preset('示例 2', {'s': 'cbbd'}),
        ],
        schema: InputSchema(fields: [InputField.string('s', maxLength: 40)]),
        script: longestPalindromeScript,
      ),
      buildProblem(
        slug: 'longest-common-subsequence',
        number: 1143,
        title: '最长公共子序列',
        difficulty: ProblemDifficulty.medium,
        group: 'dp-multidim',
        pattern: 'dp-2d',
        code: lcsCode,
        presets: [
          preset('示例 1', {'text1': 'abcde', 'text2': 'ace'}),
          preset('示例 2', {'text1': 'abc', 'text2': 'abc'}),
          preset('示例 3', {'text1': 'abc', 'text2': 'def'}),
        ],
        schema: InputSchema(fields: [
          InputField.string('text1', maxLength: 40),
          InputField.string('text2', maxLength: 40),
        ]),
        script: lcsScript,
      ),
      buildProblem(
        slug: 'edit-distance',
        number: 72,
        title: '编辑距离',
        difficulty: ProblemDifficulty.hard,
        group: 'dp-multidim',
        pattern: 'dp-2d',
        code: editDistanceCode,
        presets: [
          preset('示例 1', {'word1': 'horse', 'word2': 'ros'}),
          preset('示例 2', {'word1': 'intention', 'word2': 'execution'}),
        ],
        schema: InputSchema(fields: [
          InputField.string('word1', maxLength: 40),
          InputField.string('word2', maxLength: 40),
        ]),
        script: editDistanceScript,
      ),
      buildProblem(
        slug: 'single-number',
        number: 136,
        title: '只出现一次的数字',
        difficulty: ProblemDifficulty.easy,
        group: 'tricks',
        pattern: 'array-basic',
        code: singleNumberCode,
        presets: [
          preset('示例 1', {
            'nums': [2, 2, 1],
          }),
          preset('示例 2', {
            'nums': [4, 1, 2, 1, 2],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: singleNumberScript,
      ),
      buildProblem(
        slug: 'majority-element',
        number: 169,
        title: '多数元素',
        difficulty: ProblemDifficulty.easy,
        group: 'tricks',
        pattern: 'array-basic',
        code: majorityElementCode,
        presets: [
          preset('示例 1', {
            'nums': [3, 2, 3],
          }),
          preset('示例 2', {
            'nums': [2, 2, 1, 1, 1, 2, 2],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: majorityElementScript,
      ),
      buildProblem(
        slug: 'sort-colors',
        number: 75,
        title: '颜色分类',
        difficulty: ProblemDifficulty.medium,
        group: 'tricks',
        pattern: 'array-basic',
        code: sortColorsCode,
        presets: [
          preset('示例 1', {
            'nums': [2, 0, 2, 1, 1, 0],
          }),
          preset('示例 2', {
            'nums': [2, 0, 1],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: sortColorsScript,
      ),
      buildProblem(
        slug: 'next-permutation',
        number: 31,
        title: '下一个排列',
        difficulty: ProblemDifficulty.medium,
        group: 'tricks',
        pattern: 'array-basic',
        code: nextPermutationCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3],
          }),
          preset('示例 2', {
            'nums': [3, 2, 1],
          }),
          preset('示例 3', {
            'nums': [1, 1, 5],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 40)]),
        script: nextPermutationScript,
      ),
      buildProblem(
        slug: 'find-the-duplicate-number',
        number: 287,
        title: '寻找重复数',
        difficulty: ProblemDifficulty.medium,
        group: 'tricks',
        pattern: 'array-basic',
        code: findDuplicateCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 3, 4, 2, 2],
          }),
          preset('示例 2', {
            'nums': [3, 1, 3, 4, 2],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: findDuplicateScript,
      ),
    ];
