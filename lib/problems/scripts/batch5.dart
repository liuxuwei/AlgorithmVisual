import '../../catalog/problem_entry.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/scene_frame.dart';
import '../script_helpers.dart';

// ===========================================================================
// 图论 (4)
// ===========================================================================

const String numIslandsCode = '''class Solution {
    public int numIslands(char[][] grid) {
        int count = 0;
        for (int i = 0; i < grid.length; i++) {
            for (int j = 0; j < grid[0].length; j++) {
                if (grid[i][j] == '1') {
                    count++;
                    dfs(grid, i, j);
                }
            }
        }
        return count;
    }
    void dfs(char[][] grid, int i, int j) {
        if (i < 0 || j < 0 || i >= grid.length || j >= grid[0].length) return;
        if (grid[i][j] != '1') return;
        grid[i][j] = '0';
        dfs(grid, i + 1, j);
        dfs(grid, i - 1, j);
        dfs(grid, i, j + 1);
        dfs(grid, i, j - 1);
    }
}''';

List<SceneFrame> numIslandsScript(Map<String, dynamic> input) {
  final rows = gridOfChars(input['grid']);
  if (rows.isEmpty) throw ArgumentError('网格不能为空');
  checkSize(rows.length * rows.first.length, 400, 'grid');
  final collector = FrameCollector();
  final scene = GridScene(
    collector,
    [for (final row in rows) <dynamic>[...row]],
    numIslandsCode,
  );
  final visited = <(int, int)>{};
  var count = 0;

  scene.show('扫描网格, 每遇到一个未访问的 1 就发现一座岛屿', line: 'int count = 0');

  void dfs(int r, int c) {
    if (r < 0 || c < 0 || r >= scene.rows || c >= scene.cols) return;
    if ('${scene.grid[r][c]}' != '1' || visited.contains((r, c))) return;
    visited.add((r, c));
    scene.set(r, c, '0');
    scene.show(
      '淹没 ($r, $c), 已发现 $count 座岛屿',
      line: "grid[i][j] = '0'",
      visited: visited,
      highlight: {(r, c)},
    );
    dfs(r + 1, c);
    dfs(r - 1, c);
    dfs(r, c + 1);
    dfs(r, c - 1);
  }

  for (var r = 0; r < scene.rows; r++) {
    for (var c = 0; c < scene.cols; c++) {
      if ('${scene.grid[r][c]}' == '1' && !visited.contains((r, c))) {
        count++;
        scene.show(
          '在 ($r, $c) 发现新岛屿, 开始 DFS',
          line: "if (grid[i][j] == '1')",
          visited: visited,
          highlight: {(r, c)},
        );
        dfs(r, c);
      }
    }
  }

  scene.show('岛屿数量 = $count', line: 'return count', visited: visited);
  return collector.build();
}

const String orangesRottingCode = '''class Solution {
    public int orangesRotting(int[][] grid) {
        Queue<int[]> queue = new LinkedList<>();
        int fresh = 0;
        for (int i = 0; i < grid.length; i++)
            for (int j = 0; j < grid[0].length; j++) {
                if (grid[i][j] == 1) fresh++;
                if (grid[i][j] == 2) queue.offer(new int[]{i, j});
            }
        int minutes = 0;
        int[][] dirs = {{1, 0}, {-1, 0}, {0, 1}, {0, -1}};
        while (!queue.isEmpty() && fresh > 0) {
            int size = queue.size();
            for (int k = 0; k < size; k++) {
                int[] cur = queue.poll();
                for (int[] d : dirs) {
                    int nr = cur[0] + d[0], nc = cur[1] + d[1];
                    if (nr < 0 || nc < 0 || nr >= grid.length || nc >= grid[0].length) continue;
                    if (grid[nr][nc] != 1) continue;
                    grid[nr][nc] = 2;
                    fresh--;
                    queue.offer(new int[]{nr, nc});
                }
            }
            minutes++;
        }
        return fresh == 0 ? minutes : -1;
    }
}''';

List<SceneFrame> orangesRottingScript(Map<String, dynamic> input) {
  final rows = gridOfChars(input['grid']);
  if (rows.isEmpty) throw ArgumentError('网格不能为空');
  checkSize(rows.length * rows.first.length, 400, 'grid');
  final collector = FrameCollector();
  final scene = GridScene(
    collector,
    [for (final row in rows) <dynamic>[...row]],
    orangesRottingCode,
  );
  final rotten = <(int, int)>{};
  var fresh = 0;
  for (var r = 0; r < scene.rows; r++) {
    for (var c = 0; c < scene.cols; c++) {
      if ('${scene.grid[r][c]}' == '1') fresh++;
      if ('${scene.grid[r][c]}' == '2') rotten.add((r, c));
    }
  }

  scene.show(
    '初始: 腐烂橘子 ${rotten.length} 个, 新鲜橘子 $fresh 个',
    line: 'int fresh = 0',
    highlight: rotten,
  );

  var minutes = 0;
  var queue = [...rotten];
  while (queue.isNotEmpty && fresh > 0) {
    final next = <(int, int)>[];
    for (final cell in queue) {
      final neighbours = [
        (cell.$1 + 1, cell.$2),
        (cell.$1 - 1, cell.$2),
        (cell.$1, cell.$2 + 1),
        (cell.$1, cell.$2 - 1),
      ];
      for (final n in neighbours) {
        if (n.$1 < 0 || n.$2 < 0 || n.$1 >= scene.rows || n.$2 >= scene.cols) {
          continue;
        }
        if ('${scene.grid[n.$1][n.$2]}' != '1') continue;
        scene.set(n.$1, n.$2, '2');
        fresh--;
        next.add(n);
      }
    }
    if (next.isEmpty) break;
    minutes++;
    queue = next;
    scene.show(
      '第 $minutes 分钟: 新腐烂 ${next.length} 个, 剩余新鲜 $fresh 个',
      line: 'grid[nr][nc] = 2',
      visited: rotten,
      highlight: next.toSet(),
    );
    rotten.addAll(next);
  }

  scene.show(
    fresh == 0 ? '全部腐烂, 用时 $minutes 分钟' : '有橘子无法腐烂, 返回 -1',
    line: 'return fresh == 0 ? minutes : -1',
    visited: rotten,
  );
  return collector.build();
}

const String courseScheduleCode = '''class Solution {
    public boolean canFinish(int numCourses, int[][] prerequisites) {
        int[] indegree = new int[numCourses];
        List<List<Integer>> graph = new ArrayList<>();
        for (int i = 0; i < numCourses; i++) graph.add(new ArrayList<>());
        for (int[] p : prerequisites) {
            graph.get(p[1]).add(p[0]);
            indegree[p[0]]++;
        }
        Queue<Integer> queue = new LinkedList<>();
        for (int i = 0; i < numCourses; i++) {
            if (indegree[i] == 0) queue.offer(i);
        }
        int visited = 0;
        while (!queue.isEmpty()) {
            int cur = queue.poll();
            visited++;
            for (int next : graph.get(cur)) {
                if (--indegree[next] == 0) queue.offer(next);
            }
        }
        return visited == numCourses;
    }
}''';

List<SceneFrame> courseScheduleScript(Map<String, dynamic> input) {
  final numCourses = intOf(input['numCourses']);
  final prerequisites = intMatrix(input['prerequisites']);
  if (numCourses <= 0) throw ArgumentError('课程数必须大于 0');
  if (numCourses > 30) throw ArgumentError('课程数不能超过 30');
  final collector = FrameCollector();
  final scene = GridScene(
    collector,
    List.generate(numCourses, (_) => List<dynamic>.filled(numCourses, '·')),
    courseScheduleCode,
  );
  for (final edge in prerequisites) {
    if (edge.length < 2) continue;
    final course = edge[0];
    final pre = edge[1];
    if (course < 0 || pre < 0 || course >= numCourses || pre >= numCourses) {
      continue;
    }
    scene.set(course, pre, '1');
  }

  final indegree = List<int>.filled(numCourses, 0);
  for (final edge in prerequisites) {
    if (edge.length < 2) continue;
    final course = edge[0];
    if (course >= 0 && course < numCourses) indegree[course]++;
  }

  scene.show('邻接矩阵: 第 i 行标记课程 i 的先修课', line: 'int[] indegree');

  var queue = <int>[
    for (var i = 0; i < numCourses; i++)
      if (indegree[i] == 0) i,
  ];
  final visited = <(int, int)>{};
  var learned = 0;
  scene.show('入度为 0 的课程入队: $queue', line: 'if (indegree[i] == 0) queue.offer(i)');

  while (queue.isNotEmpty) {
    final next = <int>[];
    for (final course in queue) {
      learned++;
      for (var pre = 0; pre < numCourses; pre++) {
        visited.add((course, pre));
      }
      scene.show(
        '学习课程 $course, 已学 $learned 门',
        line: 'visited++',
        visited: visited,
        highlight: {
          for (var pre = 0; pre < numCourses; pre++)
            if (scene.grid[course][pre] == '1') (course, pre),
        },
      );
      for (final edge in prerequisites) {
        if (edge.length < 2) continue;
        if (edge[1] != course) continue;
        final dependent = edge[0];
        if (dependent < 0 || dependent >= numCourses) continue;
        indegree[dependent]--;
        if (indegree[dependent] == 0) next.add(dependent);
      }
    }
    queue = next;
    if (queue.isNotEmpty) {
      scene.show('新的入度为 0 的课程: $queue', line: 'if (--indegree[next] == 0) queue.offer(next)');
    }
  }

  scene.show(
    learned == numCourses ? '可以完成全部 $numCourses 门课程' : '存在环, 无法完成全部课程',
    line: 'return visited == numCourses',
    visited: visited,
  );
  return collector.build();
}

const String trieCode = '''class Trie {
    Trie[] children = new Trie[26];
    boolean isEnd;
    public void insert(String word) {
        Trie node = this;
        for (char ch : word.toCharArray()) {
            int index = ch - 'a';
            if (node.children[index] == null) {
                node.children[index] = new Trie();
            }
            node = node.children[index];
        }
        node.isEnd = true;
    }
    public boolean startsWith(String prefix) {
        Trie node = this;
        for (char ch : prefix.toCharArray()) {
            int index = ch - 'a';
            if (node.children[index] == null) return false;
            node = node.children[index];
        }
        return true;
    }
}''';

List<SceneFrame> trieScript(Map<String, dynamic> input) {
  final words = splitWords(strOf(input['words']));
  final prefix = strOf(input['prefix']);
  if (words.isEmpty) throw ArgumentError('至少需要一个单词');
  checkSize(words.length, 30, 'words');
  final maxLen = words.map((w) => w.length).reduce((a, b) => a > b ? a : b);
  final collector = FrameCollector();
  final scene = GridScene(
    collector,
    [for (final word in words) <dynamic>[...word.split(''), ...List.filled(maxLen - word.length, '')]],
    trieCode,
  );
  final inserted = <(int, int)>{};

  scene.show('依次把 ${words.length} 个单词插入字典树', line: 'public void insert(String word)');

  for (var i = 0; i < words.length; i++) {
    final word = words[i];
    for (var j = 0; j < word.length; j++) {
      inserted.add((i, j));
      scene.show(
        '插入 "$word": 处理字符 ${word[j]}',
        line: "int index = ch - 'a'",
        visited: inserted,
        highlight: {(i, j)},
      );
    }
    scene.show('"$word" 插入完成, 标记单词结尾', line: 'node.isEnd = true', visited: inserted);
  }

  scene.show('搜索前缀 "$prefix"', line: 'public boolean startsWith(String prefix)');
  final matched = <int>[];
  for (var i = 0; i < words.length; i++) {
    if (words[i].startsWith(prefix)) {
      matched.add(i);
      scene.show(
        '"${words[i]}" 包含前缀 "$prefix"',
        line: 'if (node.children[index] == null) return false',
        visited: inserted,
        highlight: {
          for (var j = 0; j < prefix.length; j++) (i, j),
        },
      );
    }
  }

  scene.show(
    matched.isEmpty ? '没有单词包含前缀 "$prefix"' : '共有 ${matched.length} 个单词包含该前缀',
    line: 'return true',
    visited: inserted,
  );
  return collector.build();
}

// ===========================================================================
// 回溯 (8)
// ===========================================================================

const String permutationsCode = '''class Solution {
    List<List<Integer>> ans = new ArrayList<>();
    public List<List<Integer>> permute(int[] nums) {
        dfs(nums, new ArrayList<>(), new boolean[nums.length]);
        return ans;
    }
    void dfs(int[] nums, List<Integer> path, boolean[] used) {
        if (path.size() == nums.length) {
            ans.add(new ArrayList<>(path));
            return;
        }
        for (int i = 0; i < nums.length; i++) {
            if (used[i]) continue;
            used[i] = true;
            path.add(nums[i]);
            dfs(nums, path, used);
            path.remove(path.size() - 1);
            used[i] = false;
        }
    }
}''';

List<SceneFrame> permutationsScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 8, 'nums');
  final collector = FrameCollector();
  final scene = StackScene(collector, permutationsCode);
  final used = <int>{};
  final result = <List<int>>[];

  scene.show('从空排列开始回溯', line: 'dfs(nums, new ArrayList<>(), new boolean[nums.length])');

  void dfs() {
    if (scene.items.length == nums.length) {
      result.add([for (final item in scene.items) item as int]);
      scene.show(
        '得到一个排列 ${result.last}',
        line: 'ans.add(new ArrayList<>(path))',
        highlight: {
          for (var i = 0; i < scene.items.length; i++) i,
        },
      );
      return;
    }
    for (var i = 0; i < nums.length; i++) {
      if (used.contains(i)) continue;
      used.add(i);
      scene.push(nums[i]);
      scene.show(
        '选择 nums[$i] = ${nums[i]}',
        line: 'path.add(nums[i])',
        highlight: {scene.items.length - 1},
      );
      dfs();
      scene.pop();
      used.remove(i);
      scene.show('撤销 ${nums[i]}', line: 'path.remove(path.size() - 1)');
    }
  }

  dfs();
  scene.show('共得到 ${result.length} 个排列: $result', line: 'return ans');
  return collector.build();
}

const String subsetsCode = '''class Solution {
    List<List<Integer>> ans = new ArrayList<>();
    public List<List<Integer>> subsets(int[] nums) {
        dfs(nums, 0, new ArrayList<>());
        return ans;
    }
    void dfs(int[] nums, int start, List<Integer> path) {
        ans.add(new ArrayList<>(path));
        for (int i = start; i < nums.length; i++) {
            path.add(nums[i]);
            dfs(nums, i + 1, path);
            path.remove(path.size() - 1);
        }
    }
}''';

List<SceneFrame> subsetsScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 10, 'nums');
  final collector = FrameCollector();
  final scene = StackScene(collector, subsetsCode);
  final result = <List<int>>[];

  scene.show('每个节点都是一个子集', line: 'ans.add(new ArrayList<>(path))');

  void dfs(int start) {
    result.add([for (final item in scene.items) item as int]);
    scene.show(
      '记录子集 ${result.last}',
      line: 'ans.add(new ArrayList<>(path))',
      highlight: {
        for (var i = 0; i < scene.items.length; i++) i,
      },
    );
    for (var i = start; i < nums.length; i++) {
      scene.push(nums[i]);
      scene.show('选择 nums[$i] = ${nums[i]}', line: 'path.add(nums[i])', highlight: {scene.items.length - 1});
      dfs(i + 1);
      scene.pop();
      scene.show('撤销 ${nums[i]}', line: 'path.remove(path.size() - 1)');
    }
  }

  dfs(0);
  scene.show('共 ${result.length} 个子集: $result', line: 'return ans');
  return collector.build();
}

const String letterCombinationsCode = '''class Solution {
    String[] map = {"", "", "abc", "def", "ghi", "jkl", "mno", "pqrs", "tuv", "wxyz"};
    List<String> ans = new ArrayList<>();
    public List<String> letterCombinations(String digits) {
        if (digits.isEmpty()) return ans;
        dfs(digits, 0, new StringBuilder());
        return ans;
    }
    void dfs(String digits, int index, StringBuilder path) {
        if (index == digits.length()) {
            ans.add(path.toString());
            return;
        }
        String letters = map[digits.charAt(index) - '0'];
        for (char ch : letters.toCharArray()) {
            path.append(ch);
            dfs(digits, index + 1, path);
            path.deleteCharAt(path.length() - 1);
        }
    }
}''';

List<SceneFrame> letterCombinationsScript(Map<String, dynamic> input) {
  final digits = strOf(input['digits']).replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) throw ArgumentError('请输入 2 到 9 的数字串');
  checkSize(digits.length, 6, 'digits');
  const mapping = {
    '2': 'abc',
    '3': 'def',
    '4': 'ghi',
    '5': 'jkl',
    '6': 'mno',
    '7': 'pqrs',
    '8': 'tuv',
    '9': 'wxyz',
  };
  final collector = FrameCollector();
  final scene = StackScene(collector, letterCombinationsCode);
  final result = <String>[];

  scene.show('数字 $digits 对应字母组合', line: 'String[] map');

  void dfs(int index) {
    if (index == digits.length) {
      final text = scene.items.join();
      result.add(text);
      scene.show(
        '得到一个组合 "$text"',
        line: 'ans.add(path.toString())',
        highlight: {
          for (var i = 0; i < scene.items.length; i++) i,
        },
      );
      return;
    }
    final letters = mapping[digits[index]] ?? '';
    for (final ch in letters.split('')) {
      scene.push(ch);
      scene.show(
        '数字 ${digits[index]} 选择字母 $ch',
        line: 'path.append(ch)',
        highlight: {scene.items.length - 1},
      );
      dfs(index + 1);
      scene.pop();
      scene.show('撤销字母 $ch', line: 'path.deleteCharAt(path.length() - 1)');
    }
  }

  dfs(0);
  scene.show('共 ${result.length} 种组合: $result', line: 'return ans');
  return collector.build();
}

const String combinationSumCode = '''class Solution {
    List<List<Integer>> ans = new ArrayList<>();
    public List<List<Integer>> combinationSum(int[] candidates, int target) {
        dfs(candidates, target, 0, new ArrayList<>());
        return ans;
    }
    void dfs(int[] candidates, int remain, int start, List<Integer> path) {
        if (remain == 0) {
            ans.add(new ArrayList<>(path));
            return;
        }
        if (remain < 0) return;
        for (int i = start; i < candidates.length; i++) {
            path.add(candidates[i]);
            dfs(candidates, remain - candidates[i], i, path);
            path.remove(path.size() - 1);
        }
    }
}''';

List<SceneFrame> combinationSumScript(Map<String, dynamic> input) {
  final candidates = intList(input['candidates']);
  final target = intOf(input['target']);
  if (candidates.isEmpty) throw ArgumentError('候选数组不能为空');
  checkSize(candidates.length, 12, 'candidates');
  final collector = FrameCollector();
  final scene = StackScene(collector, combinationSumCode);
  final result = <List<int>>[];

  scene.show('目标值 $target, 候选 $candidates', line: 'dfs(candidates, target, 0, new ArrayList<>())');

  void dfs(int remain, int start) {
    if (remain == 0) {
      result.add([for (final item in scene.items) item as int]);
      scene.show(
        '找到一个组合 ${result.last}, 和为 $target',
        line: 'ans.add(new ArrayList<>(path))',
        highlight: {
          for (var i = 0; i < scene.items.length; i++) i,
        },
      );
      return;
    }
    if (remain < 0) return;
    for (var i = start; i < candidates.length; i++) {
      scene.push(candidates[i]);
      scene.show(
        '选择 ${candidates[i]}, 剩余目标 ${remain - candidates[i]}',
        line: 'path.add(candidates[i])',
        highlight: {scene.items.length - 1},
      );
      dfs(remain - candidates[i], i);
      scene.pop();
      scene.show('撤销 ${candidates[i]}', line: 'path.remove(path.size() - 1)');
    }
  }

  dfs(target, 0);
  scene.show('共 ${result.length} 个组合: $result', line: 'return ans');
  return collector.build();
}

const String generateParenthesesCode = '''class Solution {
    List<String> ans = new ArrayList<>();
    public List<String> generateParenthesis(int n) {
        dfs(n, 0, 0, new StringBuilder());
        return ans;
    }
    void dfs(int n, int open, int close, StringBuilder path) {
        if (path.length() == 2 * n) {
            ans.add(path.toString());
            return;
        }
        if (open < n) {
            path.append('(');
            dfs(n, open + 1, close, path);
            path.deleteCharAt(path.length() - 1);
        }
        if (close < open) {
            path.append(')');
            dfs(n, open, close + 1, path);
            path.deleteCharAt(path.length() - 1);
        }
    }
}''';

List<SceneFrame> generateParenthesesScript(Map<String, dynamic> input) {
  final n = intOf(input['n']);
  if (n <= 0 || n > 8) throw ArgumentError('n 必须在 1 到 8 之间');
  final collector = FrameCollector();
  final scene = StackScene(collector, generateParenthesesCode);
  final result = <String>[];

  scene.show('生成 $n 对括号, 任意前缀中左括号不少于右括号', line: 'dfs(n, 0, 0, new StringBuilder())');

  void dfs(int open, int close) {
    if (scene.items.length == 2 * n) {
      final text = scene.items.join();
      result.add(text);
      scene.show(
        '得到一个合法组合 "$text"',
        line: 'ans.add(path.toString())',
        highlight: {
          for (var i = 0; i < scene.items.length; i++) i,
        },
      );
      return;
    }
    if (open < n) {
      scene.push('(');
      scene.show(
        '放左括号, 左 $open+1 / 右 $close',
        line: "path.append('(')",
        highlight: {scene.items.length - 1},
      );
      dfs(open + 1, close);
      scene.pop();
      scene.show('撤销左括号', line: "path.deleteCharAt(path.length() - 1)");
    }
    if (close < open) {
      scene.push(')');
      scene.show(
        '放右括号, 左 $open / 右 ${close + 1}',
        line: "path.append(')')",
        highlight: {scene.items.length - 1},
      );
      dfs(open, close + 1);
      scene.pop();
      scene.show('撤销右括号', line: "path.deleteCharAt(path.length() - 1)");
    }
  }

  dfs(0, 0);
  scene.show('共 ${result.length} 种组合: $result', line: 'return ans');
  return collector.build();
}

const String wordSearchCode = '''class Solution {
    public boolean exist(char[][] board, String word) {
        for (int i = 0; i < board.length; i++)
            for (int j = 0; j < board[0].length; j++)
                if (dfs(board, word, i, j, 0)) return true;
        return false;
    }
    boolean dfs(char[][] board, String word, int i, int j, int k) {
        if (i < 0 || j < 0 || i >= board.length || j >= board[0].length) return false;
        if (board[i][j] != word.charAt(k)) return false;
        if (k == word.length() - 1) return true;
        char tmp = board[i][j];
        board[i][j] = '#';
        boolean found = dfs(board, word, i + 1, j, k + 1)
                || dfs(board, word, i - 1, j, k + 1)
                || dfs(board, word, i, j + 1, k + 1)
                || dfs(board, word, i, j - 1, k + 1);
        board[i][j] = tmp;
        return found;
    }
}''';

List<SceneFrame> wordSearchScript(Map<String, dynamic> input) {
  final rows = gridOfChars(input['board']);
  final word = strOf(input['word']);
  if (rows.isEmpty || word.isEmpty) throw ArgumentError('棋盘与单词都不能为空');
  checkSize(rows.length * rows.first.length, 400, 'board');
  final collector = FrameCollector();
  final scene = GridScene(
    collector,
    [for (final row in rows) <dynamic>[...row]],
    wordSearchCode,
  );
  final path = <(int, int)>{};

  scene.show('在棋盘中搜索单词 "$word"', line: 'for (int i = 0; i < board.length; i++)');

  bool dfs(int r, int c, int k) {
    if (r < 0 || c < 0 || r >= scene.rows || c >= scene.cols) return false;
    if ('${scene.grid[r][c]}' != word[k]) return false;
    if (k == word.length - 1) {
      scene.show(
        '匹配到单词最后一个字符 "${word[k]}"',
        line: 'if (k == word.length() - 1) return true',
        visited: path,
        highlight: {(r, c)},
      );
      return true;
    }
    final original = scene.grid[r][c];
    scene.set(r, c, '#');
    path.add((r, c));
    scene.show(
      '匹配 "${word[k]}", 标记 ($r, $c) 已使用',
      line: "board[i][j] = '#'",
      visited: path,
      highlight: {(r, c)},
    );
    final found = dfs(r + 1, c, k + 1) ||
        dfs(r - 1, c, k + 1) ||
        dfs(r, c + 1, k + 1) ||
        dfs(r, c - 1, k + 1);
    scene.set(r, c, original);
    path.remove((r, c));
    scene.show(
      '回溯 ($r, $c)',
      line: 'board[i][j] = tmp',
      visited: path,
    );
    return found;
  }

  var found = false;
  for (var r = 0; r < scene.rows && !found; r++) {
    for (var c = 0; c < scene.cols && !found; c++) {
      found = dfs(r, c, 0);
    }
  }

  scene.show(found ? '单词 "$word" 存在于棋盘中' : '单词 "$word" 不存在', line: 'return false', visited: path);
  return collector.build();
}

const String palindromePartitionCode = '''class Solution {
    List<List<String>> ans = new ArrayList<>();
    public List<List<String>> partition(String s) {
        dfs(s, 0, new ArrayList<>());
        return ans;
    }
    void dfs(String s, int start, List<String> path) {
        if (start == s.length()) {
            ans.add(new ArrayList<>(path));
            return;
        }
        for (int end = start; end < s.length(); end++) {
            String part = s.substring(start, end + 1);
            if (!isPalindrome(part)) continue;
            path.add(part);
            dfs(s, end + 1, path);
            path.remove(path.size() - 1);
        }
    }
    boolean isPalindrome(String s) {
        int i = 0, j = s.length() - 1;
        while (i < j) if (s.charAt(i++) != s.charAt(j--)) return false;
        return true;
    }
}''';

List<SceneFrame> palindromePartitionScript(Map<String, dynamic> input) {
  final text = strOf(input['s']);
  if (text.isEmpty) throw ArgumentError('字符串不能为空');
  checkSize(text.length, 16, 's');
  final collector = FrameCollector();
  final scene = StackScene(collector, palindromePartitionCode);
  final result = <List<String>>[];

  scene.show('把 "$text" 切分为若干回文串', line: 'dfs(s, 0, new ArrayList<>())');

  bool isPalindrome(String value) {
    var i = 0;
    var j = value.length - 1;
    while (i < j) {
      if (value[i] != value[j]) return false;
      i++;
      j--;
    }
    return true;
  }

  void dfs(int start) {
    if (start == text.length) {
      result.add([for (final item in scene.items) '$item']);
      scene.show(
        '得到一种切分 ${result.last}',
        line: 'ans.add(new ArrayList<>(path))',
        highlight: {
          for (var i = 0; i < scene.items.length; i++) i,
        },
      );
      return;
    }
    for (var end = start; end < text.length; end++) {
      final part = text.substring(start, end + 1);
      if (!isPalindrome(part)) continue;
      scene.push(part);
      scene.show(
        '切出回文串 "$part"',
        line: 'path.add(part)',
        highlight: {scene.items.length - 1},
      );
      dfs(end + 1);
      scene.pop();
      scene.show('撤销 "$part"', line: 'path.remove(path.size() - 1)');
    }
  }

  dfs(0);
  scene.show('共 ${result.length} 种切分: $result', line: 'return ans');
  return collector.build();
}

const String nQueensCode = '''class Solution {
    List<List<String>> ans = new ArrayList<>();
    public List<List<String>> solveNQueens(int n) {
        char[][] board = new char[n][n];
        for (char[] row : board) Arrays.fill(row, '.');
        dfs(board, 0, new HashSet<>(), new HashSet<>(), new HashSet<>());
        return ans;
    }
    void dfs(char[][] board, int row, Set<Integer> cols, Set<Integer> diag1, Set<Integer> diag2) {
        int n = board.length;
        if (row == n) {
            List<String> snapshot = new ArrayList<>();
            for (char[] r : board) snapshot.add(new String(r));
            ans.add(snapshot);
            return;
        }
        for (int col = 0; col < n; col++) {
            if (cols.contains(col) || diag1.contains(row - col) || diag2.contains(row + col)) continue;
            board[row][col] = 'Q';
            cols.add(col); diag1.add(row - col); diag2.add(row + col);
            dfs(board, row + 1, cols, diag1, diag2);
            cols.remove(col); diag1.remove(row - col); diag2.remove(row + col);
            board[row][col] = '.';
        }
    }
}''';

List<SceneFrame> nQueensScript(Map<String, dynamic> input) {
  final n = intOf(input['n']);
  if (n <= 0 || n > 8) throw ArgumentError('n 必须在 1 到 8 之间');
  final collector = FrameCollector();
  final scene = GridScene(
    collector,
    List.generate(n, (_) => List<dynamic>.filled(n, '.')),
    nQueensCode,
  );
  final queens = <(int, int)>{};
  final result = <int>[];
  final cols = <int>{};
  final diag1 = <int>{};
  final diag2 = <int>{};

  scene.show('$n 皇后: 逐行放置并检查列与两条对角线', line: 'char[][] board = new char[n][n]');

  void dfs(int row) {
    if (row == n) {
      result.add(row);
      scene.show(
        '找到一个解, 共 ${result.length} 个',
        line: 'ans.add(snapshot)',
        visited: queens,
      );
      return;
    }
    for (var col = 0; col < n; col++) {
      if (cols.contains(col) || diag1.contains(row - col) || diag2.contains(row + col)) {
        continue;
      }
      scene.set(row, col, 'Q');
      queens.add((row, col));
      cols.add(col);
      diag1.add(row - col);
      diag2.add(row + col);
      scene.show(
        '第 $row 行第 $col 列放皇后',
        line: "board[row][col] = 'Q'",
        visited: queens,
        highlight: {(row, col)},
      );
      dfs(row + 1);
      scene.set(row, col, '.');
      queens.remove((row, col));
      cols.remove(col);
      diag1.remove(row - col);
      diag2.remove(row + col);
      scene.show(
        '撤销皇后 ($row, $col)',
        line: "board[row][col] = '.'",
        visited: queens,
      );
    }
  }

  dfs(0);
  scene.show('$n 皇后共有 ${result.length} 个解', line: 'return ans', visited: queens);
  return collector.build();
}

// ===========================================================================
// 题目描述符
// ===========================================================================

List<ProblemEntry> batch5Problems() => [
      buildProblem(
        slug: 'number-of-islands',
        number: 200,
        title: '岛屿数量',
        difficulty: ProblemDifficulty.medium,
        group: 'graph',
        pattern: 'matrix-grid',
        code: numIslandsCode,
        presets: [
          preset('示例 1', {
            'grid': ['11110', '11010', '11000', '00000'],
          }),
          preset('示例 2', {
            'grid': ['11000', '11000', '00100', '00011'],
          }),
        ],
        schema: InputSchema(fields: [InputField.string('grid', maxLength: 400)]),
        script: numIslandsScript,
      ),
      buildProblem(
        slug: 'rotting-oranges',
        number: 994,
        title: '腐烂的橘子',
        difficulty: ProblemDifficulty.medium,
        group: 'graph',
        pattern: 'matrix-grid',
        code: orangesRottingCode,
        presets: [
          preset('示例 1', {
            'grid': ['210', '110', '011'],
          }),
          preset('示例 2', {
            'grid': ['210', '011', '011'],
          }),
          preset('示例 3', {
            'grid': ['000'],
          }),
        ],
        schema: InputSchema(fields: [InputField.string('grid', maxLength: 400)]),
        script: orangesRottingScript,
      ),
      buildProblem(
        slug: 'course-schedule',
        number: 207,
        title: '课程表',
        difficulty: ProblemDifficulty.medium,
        group: 'graph',
        pattern: 'matrix-grid',
        code: courseScheduleCode,
        presets: [
          preset('示例 1', {
            'numCourses': 4,
            'prerequisites': [
              [1, 0],
              [2, 1],
              [3, 2],
            ],
          }),
          preset('示例 2', {
            'numCourses': 3,
            'prerequisites': [
              [1, 0],
              [0, 1],
            ],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.int('numCourses', minValue: 1, maxValue: 30),
          InputField.matrix('prerequisites', maxRows: 60, maxCols: 2),
        ]),
        script: courseScheduleScript,
        maxInputSize: 30,
      ),
      buildProblem(
        slug: 'implement-trie-prefix-tree',
        number: 208,
        title: '实现 Trie (前缀树)',
        difficulty: ProblemDifficulty.medium,
        group: 'graph',
        pattern: 'matrix-grid',
        code: trieCode,
        presets: [
          preset('示例 1', {
            'words': 'apple app apply',
            'prefix': 'app',
          }),
          preset('示例 2', {
            'words': 'banana band',
            'prefix': 'ban',
          }),
        ],
        schema: InputSchema(fields: [
          InputField.string('words', maxLength: 200),
          InputField.string('prefix', maxLength: 20),
        ]),
        script: trieScript,
      ),
      buildProblem(
        slug: 'permutations',
        number: 46,
        title: '全排列',
        difficulty: ProblemDifficulty.medium,
        group: 'backtracking',
        pattern: 'backtracking',
        code: permutationsCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3],
          }),
          preset('示例 2', {
            'nums': [0, 1],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 8)]),
        script: permutationsScript,
        maxInputSize: 8,
      ),
      buildProblem(
        slug: 'subsets',
        number: 78,
        title: '子集',
        difficulty: ProblemDifficulty.medium,
        group: 'backtracking',
        pattern: 'backtracking',
        code: subsetsCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3],
          }),
          preset('示例 2', {
            'nums': [0],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 10)]),
        script: subsetsScript,
        maxInputSize: 10,
      ),
      buildProblem(
        slug: 'letter-combinations-of-a-phone-number',
        number: 17,
        title: '电话号码的字母组合',
        difficulty: ProblemDifficulty.medium,
        group: 'backtracking',
        pattern: 'backtracking',
        code: letterCombinationsCode,
        presets: [
          preset('示例 1', {
            'digits': '23',
          }),
          preset('示例 2', {
            'digits': '9',
          }),
        ],
        schema: InputSchema(fields: [InputField.string('digits', maxLength: 6)]),
        script: letterCombinationsScript,
      ),
      buildProblem(
        slug: 'combination-sum',
        number: 39,
        title: '组合总和',
        difficulty: ProblemDifficulty.medium,
        group: 'backtracking',
        pattern: 'backtracking',
        code: combinationSumCode,
        presets: [
          preset('示例 1', {
            'candidates': [2, 3, 6, 7],
            'target': 7,
          }),
          preset('示例 2', {
            'candidates': [2, 3, 5],
            'target': 8,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('candidates', maxLength: 12),
          InputField.int('target', minValue: 1, maxValue: 100),
        ]),
        script: combinationSumScript,
      ),
      buildProblem(
        slug: 'generate-parentheses',
        number: 22,
        title: '括号生成',
        difficulty: ProblemDifficulty.medium,
        group: 'backtracking',
        pattern: 'backtracking',
        code: generateParenthesesCode,
        presets: [
          preset('示例 1', {
            'n': 3,
          }),
          preset('示例 2', {
            'n': 1,
          }),
        ],
        schema: InputSchema(fields: [InputField.int('n', minValue: 1, maxValue: 8)]),
        script: generateParenthesesScript,
      ),
      buildProblem(
        slug: 'word-search',
        number: 79,
        title: '单词搜索',
        difficulty: ProblemDifficulty.medium,
        group: 'backtracking',
        pattern: 'backtracking',
        code: wordSearchCode,
        presets: [
          preset('示例 1', {
            'board': ['ABCE', 'SFCS', 'ADEE'],
            'word': 'ABCCED',
          }),
          preset('示例 2', {
            'board': ['ABCE', 'SFCS', 'ADEE'],
            'word': 'SEE',
          }),
          preset('示例 3', {
            'board': ['ABCE', 'SFCS', 'ADEE'],
            'word': 'ABCB',
          }),
        ],
        schema: InputSchema(fields: [
          InputField.string('board', maxLength: 400),
          InputField.string('word', maxLength: 20),
        ]),
        script: wordSearchScript,
      ),
      buildProblem(
        slug: 'palindrome-partitioning',
        number: 131,
        title: '分割回文串',
        difficulty: ProblemDifficulty.medium,
        group: 'backtracking',
        pattern: 'backtracking',
        code: palindromePartitionCode,
        presets: [
          preset('示例 1', {
            's': 'aab',
          }),
          preset('示例 2', {
            's': 'a',
          }),
        ],
        schema: InputSchema(fields: [InputField.string('s', maxLength: 16)]),
        script: palindromePartitionScript,
      ),
      buildProblem(
        slug: 'n-queens',
        number: 51,
        title: 'N 皇后',
        difficulty: ProblemDifficulty.hard,
        group: 'backtracking',
        pattern: 'backtracking',
        code: nQueensCode,
        presets: [
          preset('示例 1', {
            'n': 4,
          }),
          preset('示例 2', {
            'n': 1,
          }),
        ],
        schema: InputSchema(fields: [InputField.int('n', minValue: 1, maxValue: 8)]),
        script: nQueensScript,
      ),
    ];
