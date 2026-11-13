import '../../catalog/problem_entry.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/scene_frame.dart';
import '../script_helpers.dart';

// ===========================================================================
// 哈希 (3)
// ===========================================================================

const String twoSumCode = '''class Solution {
    public int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> seen = new HashMap<>();
        for (int i = 0; i < nums.length; i++) {
            int need = target - nums[i];
            if (seen.containsKey(need)) {
                return new int[]{seen.get(need), i};
            }
            seen.put(nums[i], i);
        }
        return new int[]{};
    }
}''';

List<SceneFrame> twoSumScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final target = intOf(input['target']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, twoSumCode);
  final seen = <int, int>{};

  scene.show('初始化哈希表 seen = {}', line: 'Map<Integer');
  for (var i = 0; i < nums.length; i++) {
    final need = target - nums[i];
    scene.show(
      'i = $i, nums[$i] = ${nums[i]}, 需要 $need',
      line: 'int need',
      pointers: {'i': i},
      highlight: {i},
    );
    if (seen.containsKey(need)) {
      final j = seen[need]!;
      scene.show(
        '命中 seen[$need] = $j, 返回 [$j, $i]',
        line: 'containsKey',
        pointers: {'答案': i},
        highlight: {j, i},
        sorted: {j, i},
      );
      return collector.build();
    }
    seen[nums[i]] = i;
    scene.show(
      'seen[${nums[i]}] = $i (当前 seen = $seen)',
      line: 'seen.put',
      pointers: {'i': i},
    );
  }
  scene.show('没有找到答案', line: 'return new int[]{}');
  return collector.build();
}

const String groupAnagramsCode = '''class Solution {
    public List<List<String>> groupAnagrams(String[] strs) {
        Map<String, List<String>> map = new HashMap<>();
        for (String s : strs) {
            char[] chars = s.toCharArray();
            Arrays.sort(chars);
            String key = new String(chars);
            map.computeIfAbsent(key, k -> new ArrayList<>()).add(s);
        }
        return new ArrayList<>(map.values());
    }
}''';

List<SceneFrame> groupAnagramsScript(Map<String, dynamic> input) {
  final words = splitWords(strOf(input['strs']));
  checkSize(words.length, 60, 'strs');
  final collector = FrameCollector();
  final scene = HashScene(collector, groupAnagramsCode);
  final bucketOf = <String, int>{};
  final groups = <String, List<String>>{};

  scene.show('初始化哈希表, 共 ${words.length} 个单词', line: 'Map<String');
  for (var i = 0; i < words.length; i++) {
    final word = words[i];
    final chars = word.split('')..sort();
    final key = chars.join();
    final bucket = bucketOf.putIfAbsent(key, () => bucketOf.length);
    groups.putIfAbsent(key, () => []).add(word);
    final existing = scene.items.where((item) => item.key == key);
    if (existing.isEmpty) {
      scene.add(key, List<String>.from(groups[key]!), bucket: bucket);
    } else {
      existing.first.value = List<String>.from(groups[key]!);
    }
    scene.show(
      '单词 "$word" → 排序后 "$key", 放入桶 $bucket',
      line: 'computeIfAbsent',
      highlightKeys: {key},
    );
  }
  scene.show(
    '分组完成, 共 ${groups.length} 组',
    line: 'return new ArrayList',
    highlightKeys: groups.keys.toSet(),
  );
  return collector.build();
}

const String longestConsecutiveCode = '''class Solution {
    public int longestConsecutive(int[] nums) {
        Set<Integer> set = new HashSet<>();
        for (int n : nums) set.add(n);
        int best = 0;
        for (int n : set) {
            if (!set.contains(n - 1)) {
                int cur = n;
                int len = 1;
                while (set.contains(cur + 1)) { cur++; len++; }
                best = Math.max(best, len);
            }
        }
        return best;
    }
}''';

List<SceneFrame> longestConsecutiveScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, longestConsecutiveCode);
  final values = nums.toSet();
  var best = 0;

  scene.show('把全部数字放入哈希集合', line: 'for (int n : nums)');
  final unique = values.toList()..sort();
  for (final start in unique) {
    if (values.contains(start - 1)) continue;
    final run = <int>[start];
    var current = start;
    while (values.contains(current + 1)) {
      current++;
      run.add(current);
    }
    final runIndices = <int>{
      for (final value in run)
        for (var i = 0; i < nums.length; i++)
          if (nums[i] == value) i,
    };
    best = run.length > best ? run.length : best;
    scene.show(
      '起点 $start, 连续序列 $run, 长度 ${run.length}, best = $best',
      line: 'while (set.contains',
      highlight: runIndices,
      pointers: {'start': nums.indexOf(start)},
    );
  }
  scene.show('最长连续序列长度 = $best', line: 'return best');
  return collector.build();
}

// ===========================================================================
// 双指针 (4)
// ===========================================================================

const String moveZeroesCode = '''class Solution {
    public void moveZeroes(int[] nums) {
        int slow = 0;
        for (int fast = 0; fast < nums.length; fast++) {
            if (nums[fast] != 0) {
                int tmp = nums[slow];
                nums[slow] = nums[fast];
                nums[fast] = tmp;
                slow++;
            }
        }
    }
}''';

List<SceneFrame> moveZeroesScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, moveZeroesCode);
  var slow = 0;

  scene.show('初始化 slow = 0', line: 'int slow');
  for (var fast = 0; fast < nums.length; fast++) {
    scene.show(
      'fast = $fast, nums[$fast] = ${nums[fast]}',
      line: 'for (int fast',
      pointers: {'slow': slow, 'fast': fast},
    );
    if (nums[fast] != 0) {
      final tmp = nums[slow];
      nums[slow] = nums[fast];
      nums[fast] = tmp;
      scene.show(
        '非零元素交换到 slow = $slow',
        line: 'int tmp',
        pointers: {'slow': slow, 'fast': fast},
        highlight: {slow, fast},
      );
      slow++;
      scene.show('slow 后移到 $slow', line: 'slow++', pointers: {'slow': slow});
    }
  }
  scene.show('移动完成, 所有零都在末尾', line: 'for (int fast');
  return collector.build();
}

const String maxWaterCode = '''class Solution {
    public int maxArea(int[] height) {
        int left = 0, right = height.length - 1;
        int best = 0;
        while (left < right) {
            int area = Math.min(height[left], height[right]) * (right - left);
            best = Math.max(best, area);
            if (height[left] < height[right]) {
                left++;
            } else {
                right--;
            }
        }
        return best;
    }
}''';

List<SceneFrame> maxWaterScript(Map<String, dynamic> input) {
  final height = intList(input['height']);
  checkSize(height.length, 80, 'height');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, height, maxWaterCode);
  var left = 0;
  var right = height.length - 1;
  var best = 0;

  scene.show('左右指针分别指向两端', line: 'int left', pointers: {'left': left, 'right': right});
  while (left < right) {
    final area = (height[left] < height[right] ? height[left] : height[right]) * (right - left);
    best = area > best ? area : best;
    scene.show(
      '区间 [$left, $right], 面积 = $area, best = $best',
      line: 'int area',
      pointers: {'left': left, 'right': right},
      highlight: {left, right},
      rangeStart: left,
      rangeEnd: right,
      rangeLabel: '容器',
    );
    if (height[left] < height[right]) {
      left++;
      scene.show('左边更矮, left 右移到 $left', line: 'left++', pointers: {'left': left, 'right': right});
    } else {
      right--;
      scene.show('右边更矮, right 左移到 $right', line: 'right--', pointers: {'left': left, 'right': right});
    }
  }
  scene.show('最大面积 = $best', line: 'return best');
  return collector.build();
}

const String threeSumCode = '''class Solution {
    public List<List<Integer>> threeSum(int[] nums) {
        Arrays.sort(nums);
        List<List<Integer>> ans = new ArrayList<>();
        for (int i = 0; i < nums.length - 2; i++) {
            if (i > 0 && nums[i] == nums[i - 1]) continue;
            int left = i + 1, right = nums.length - 1;
            while (left < right) {
                int sum = nums[i] + nums[left] + nums[right];
                if (sum == 0) {
                    ans.add(Arrays.asList(nums[i], nums[left], nums[right]));
                    while (left < right && nums[left] == nums[left + 1]) left++;
                    left++; right--;
                } else if (sum < 0) {
                    left++;
                } else {
                    right--;
                }
            }
        }
        return ans;
    }
}''';

List<SceneFrame> threeSumScript(Map<String, dynamic> input) {
  final nums = intList(input['nums'])..sort();
  checkSize(nums.length, 40, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, threeSumCode);
  final answers = <String>[];

  scene.show('先排序 nums = $nums', line: 'Arrays.sort');
  for (var i = 0; i + 2 < nums.length; i++) {
    if (i > 0 && nums[i] == nums[i - 1]) {
      scene.show('跳过重复的 i = $i', line: 'continue', pointers: {'i': i});
      continue;
    }
    var left = i + 1;
    var right = nums.length - 1;
    scene.show(
      '固定 nums[$i] = ${nums[i]}, 双指针从两端收缩',
      line: 'int left',
      pointers: {'i': i, 'left': left, 'right': right},
      highlight: {i},
    );
    while (left < right) {
      final sum = nums[i] + nums[left] + nums[right];
      if (sum == 0) {
        answers.add('[${nums[i]}, ${nums[left]}, ${nums[right]}]');
        scene.show(
          '找到三元组 ${answers.last}, 共 ${answers.length} 组',
          line: 'ans.add',
          pointers: {'i': i, 'left': left, 'right': right},
          highlight: {i, left, right},
          sorted: {i, left, right},
        );
        while (left < right && nums[left] == nums[left + 1]) {
          left++;
        }
        left++;
        right--;
      } else if (sum < 0) {
        left++;
        scene.show('和 $sum < 0, left 右移', line: 'sum < 0', pointers: {'i': i, 'left': left, 'right': right});
      } else {
        right--;
        scene.show('和 $sum > 0, right 左移', line: 'right--', pointers: {'i': i, 'left': left, 'right': right});
      }
    }
  }
  scene.show('全部三元组: $answers', line: 'return ans');
  return collector.build();
}

const String trapRainCode = '''class Solution {
    public int trap(int[] height) {
        int left = 0, right = height.length - 1;
        int leftMax = 0, rightMax = 0, water = 0;
        while (left < right) {
            if (height[left] < height[right]) {
                leftMax = Math.max(leftMax, height[left]);
                water += leftMax - height[left];
                left++;
            } else {
                rightMax = Math.max(rightMax, height[right]);
                water += rightMax - height[right];
                right--;
            }
        }
        return water;
    }
}''';

List<SceneFrame> trapRainScript(Map<String, dynamic> input) {
  final height = intList(input['height']);
  checkSize(height.length, 80, 'height');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, height, trapRainCode);
  var left = 0;
  var right = height.length - 1;
  var leftMax = 0;
  var rightMax = 0;
  var water = 0;

  scene.show('初始化双指针与两侧最大值', line: 'int leftMax', pointers: {'left': left, 'right': right});
  while (left < right) {
    if (height[left] < height[right]) {
      leftMax = height[left] > leftMax ? height[left] : leftMax;
      water += leftMax - height[left];
      scene.show(
        'left = $left, leftMax = $leftMax, 接水 $water',
        line: 'leftMax = Math.max',
        pointers: {'left': left, 'right': right},
        highlight: {left},
      );
      left++;
    } else {
      rightMax = height[right] > rightMax ? height[right] : rightMax;
      water += rightMax - height[right];
      scene.show(
        'right = $right, rightMax = $rightMax, 接水 $water',
        line: 'rightMax = Math.max',
        pointers: {'left': left, 'right': right},
        highlight: {right},
      );
      right--;
    }
  }
  scene.show('共能接住 $water 单位雨水', line: 'return water');
  return collector.build();
}

// ===========================================================================
// 滑动窗口 (2)
// ===========================================================================

const String longestSubstringCode = '''class Solution {
    public int lengthOfLongestSubstring(String s) {
        Map<Character, Integer> last = new HashMap<>();
        int left = 0, best = 0;
        for (int right = 0; right < s.length(); right++) {
            char c = s.charAt(right);
            if (last.containsKey(c) && last.get(c) >= left) {
                left = last.get(c) + 1;
            }
            last.put(c, right);
            best = Math.max(best, right - left + 1);
        }
        return best;
    }
}''';

List<SceneFrame> longestSubstringScript(Map<String, dynamic> input) {
  final chars = strOf(input['s']).split('');
  checkSize(chars.length, 60, 's');
  final collector = FrameCollector();
  final scene = TextRowScene(collector, chars, longestSubstringCode);
  final last = <String, int>{};
  var left = 0;
  var best = 0;

  scene.show('初始化窗口 left = 0', line: 'int left');
  for (var right = 0; right < chars.length; right++) {
    final c = chars[right];
    scene.show(
      'right = $right, 字符 "$c"',
      line: 'char c',
      pointers: {'left': left, 'right': right},
      highlight: {right},
    );
    if (last.containsKey(c) && last[c]! >= left) {
      left = last[c]! + 1;
      scene.show('字符重复, left 跳到 $left', line: 'left = last.get', pointers: {'left': left, 'right': right});
    }
    last[c] = right;
    final length = right - left + 1;
    best = length > best ? length : best;
    scene.show(
      '窗口 [$left, $right] 长度 $length, 最长 $best',
      line: 'best = Math.max',
      rangeStart: left,
      rangeEnd: right,
      rangeLabel: '窗口',
      pointers: {'left': left, 'right': right},
    );
  }
  scene.show('最长无重复子串长度 = $best', line: 'return best');
  return collector.build();
}

const String findAnagramsCode = '''class Solution {
    public List<Integer> findAnagrams(String s, String p) {
        List<Integer> ans = new ArrayList<>();
        if (s.length() < p.length()) return ans;
        int[] need = new int[26], win = new int[26];
        for (char c : p.toCharArray()) need[c - 'a']++;
        for (int i = 0; i < s.length(); i++) {
            win[s.charAt(i) - 'a']++;
            if (i >= p.length()) win[s.charAt(i - p.length()) - 'a']--;
            if (Arrays.equals(need, win)) ans.add(i - p.length() + 1);
        }
        return ans;
    }
}''';

List<SceneFrame> findAnagramsScript(Map<String, dynamic> input) {
  final s = strOf(input['s']).split('');
  final p = strOf(input['p']);
  checkSize(s.length, 60, 's');
  final collector = FrameCollector();
  final scene = TextRowScene(collector, s, findAnagramsCode);
  final need = List<int>.filled(26, 0);
  final win = List<int>.filled(26, 0);
  for (final c in p.split('')) {
    need[c.codeUnitAt(0) - 97]++;
  }
  final answers = <int>[];

  scene.show('统计 p = "$p" 的字符需求', line: 'for (char c');
  for (var i = 0; i < s.length; i++) {
    win[s[i].codeUnitAt(0) - 97]++;
    if (i >= p.length) {
      win[s[i - p.length].codeUnitAt(0) - 97]--;
    }
    final start = i - p.length + 1;
    final match = start >= 0 && _listEquals(need, win);
    if (match) answers.add(start);
    scene.show(
      '窗口 [$start, $i] ${match ? "匹配, 记录起点 $start" : "未匹配"}',
      line: 'if (Arrays.equals',
      rangeStart: start < 0 ? 0 : start,
      rangeEnd: i,
      rangeLabel: '窗口',
      pointers: {'i': i},
      visited: match ? {for (var k = start; k <= i; k++) k} : const {},
    );
  }
  scene.show('所有异位词起点 = $answers', line: 'return ans');
  return collector.build();
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// ===========================================================================
// 子串 (3)
// ===========================================================================

const String subarraySumCode = '''class Solution {
    public int subarraySum(int[] nums, int k) {
        Map<Integer, Integer> prefix = new HashMap<>();
        prefix.put(0, 1);
        int sum = 0, count = 0;
        for (int i = 0; i < nums.length; i++) {
            sum += nums[i];
            int need = sum - k;
            if (prefix.containsKey(need)) {
                count += prefix.get(need);
            }
            prefix.put(sum, prefix.getOrDefault(sum, 0) + 1);
        }
        return count;
    }
}''';

List<SceneFrame> subarraySumScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final k = intOf(input['k']);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, subarraySumCode);
  final prefix = <int, List<int>>{0: [-1]};
  var sum = 0;
  var count = 0;

  scene.show('前缀和哈希表 prefix = {0: 1}', line: 'prefix.put(0');
  for (var i = 0; i < nums.length; i++) {
    sum += nums[i];
    final need = sum - k;
    scene.show(
      'i = $i, 前缀和 sum = $sum, 需要历史前缀 $need',
      line: 'int need',
      pointers: {'i': i},
      highlight: {i},
    );
    if (prefix.containsKey(need)) {
      final starts = prefix[need]!;
      count += starts.length;
      final start = starts.last;
      scene.show(
        '命中 ${starts.length} 个子数组, 最近起点 ${start + 1}, count = $count',
        line: 'prefix.containsKey',
        rangeStart: start + 1 < 0 ? 0 : start + 1,
        rangeEnd: i,
        rangeLabel: '和为 $k',
        highlight: {i},
      );
    }
    prefix.putIfAbsent(sum, () => []).add(i);
    scene.show('记录前缀和 $sum 出现在 $i', line: 'prefix.put(sum');
  }
  scene.show('和为 $k 的子数组共有 $count 个', line: 'return count');
  return collector.build();
}

const String slidingWindowMaxCode = '''class Solution {
    public int[] maxSlidingWindow(int[] nums, int k) {
        Deque<Integer> deque = new ArrayDeque<>();
        int[] ans = new int[nums.length - k + 1];
        for (int i = 0; i < nums.length; i++) {
            while (!deque.isEmpty() && deque.peekFirst() <= i - k) {
                deque.pollFirst();
            }
            while (!deque.isEmpty() && nums[deque.peekLast()] < nums[i]) {
                deque.pollLast();
            }
            deque.offerLast(i);
            if (i >= k - 1) {
                ans[i - k + 1] = nums[deque.peekFirst()];
            }
        }
        return ans;
    }
}''';

List<SceneFrame> slidingWindowMaxScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final k = intOf(input['k'], 3);
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, slidingWindowMaxCode);
  final deque = <int>[];
  final answers = <int>[];

  scene.show('初始化单调递减队列', line: 'Deque<Integer>');
  for (var i = 0; i < nums.length; i++) {
    while (deque.isNotEmpty && deque.first <= i - k) {
      deque.removeAt(0);
    }
    while (deque.isNotEmpty && nums[deque.last] < nums[i]) {
      deque.removeLast();
    }
    deque.add(i);
    final start = i - k + 1;
    final ready = start >= 0;
    if (ready) answers.add(nums[deque.first]);
    scene.show(
      'i = $i, 队列下标 $deque${ready ? ", 窗口最大值 ${nums[deque.first]}" : ""}',
      line: 'deque.offerLast',
      pointers: {'i': i},
      highlight: {for (final index in deque) index},
      rangeStart: start < 0 ? 0 : start,
      rangeEnd: i,
      rangeLabel: '窗口 k=$k',
    );
  }
  scene.show('每个窗口的最大值 = $answers', line: 'return ans');
  return collector.build();
}

const String minWindowCode = '''class Solution {
    public String minWindow(String s, String t) {
        Map<Character, Integer> need = new HashMap<>();
        for (char c : t.toCharArray()) need.merge(c, 1, Integer::sum);
        int left = 0, matched = 0, start = 0, minLen = Integer.MAX_VALUE;
        for (int right = 0; right < s.length(); right++) {
            char c = s.charAt(right);
            if (need.containsKey(c)) {
                need.put(c, need.get(c) - 1);
                if (need.get(c) == 0) matched++;
            }
            while (matched == need.size()) {
                if (right - left + 1 < minLen) {
                    minLen = right - left + 1;
                    start = left;
                }
                char leftChar = s.charAt(left);
                if (need.containsKey(leftChar)) {
                    if (need.get(leftChar) == 0) matched--;
                    need.put(leftChar, need.get(leftChar) + 1);
                }
                left++;
            }
        }
        return minLen == Integer.MAX_VALUE ? "" : s.substring(start, start + minLen);
    }
}''';

List<SceneFrame> minWindowScript(Map<String, dynamic> input) {
  final s = strOf(input['s']).split('');
  final t = strOf(input['t']);
  checkSize(s.length, 60, 's');
  final collector = FrameCollector();
  final scene = TextRowScene(collector, s, minWindowCode);
  final need = <String, int>{};
  for (final c in t.split('')) {
    need[c] = (need[c] ?? 0) + 1;
  }
  var left = 0;
  var matched = 0;
  var start = 0;
  var minLen = 1 << 30;
  final required = need.length;

  scene.show('统计 t = "$t" 的字符需求', line: 'for (char c');
  for (var right = 0; right < s.length; right++) {
    final c = s[right];
    if (need.containsKey(c)) {
      need[c] = need[c]! - 1;
      if (need[c] == 0) matched++;
    }
    scene.show(
      'right = $right, 字符 "$c", 已满足 $matched/$required',
      line: 'need.put(c',
      pointers: {'left': left, 'right': right},
      highlight: {right},
    );
    while (matched == required) {
      if (right - left + 1 < minLen) {
        minLen = right - left + 1;
        start = left;
      }
      scene.show(
        '窗口 [$left, $right] 覆盖 t, 当前最短 $minLen',
        line: 'minLen = right',
        rangeStart: left,
        rangeEnd: right,
        rangeLabel: '覆盖窗口',
        pointers: {'left': left, 'right': right},
      );
      final leftChar = s[left];
      if (need.containsKey(leftChar)) {
        if (need[leftChar] == 0) matched--;
        need[leftChar] = need[leftChar]! + 1;
      }
      left++;
      scene.show('左边界右移到 $left', line: 'left++', pointers: {'left': left, 'right': right});
    }
  }
  final answer = minLen == 1 << 30 ? '' : s.sublist(start, start + minLen).join();
  scene.show('最小覆盖子串 = "$answer"', line: 'return minLen');
  return collector.build();
}

// ===========================================================================
// 题目注册
// ===========================================================================

List<ProblemEntry> batch1Problems() => [
      buildProblem(
        slug: 'two-sum',
        number: 1,
        title: '两数之和',
        difficulty: ProblemDifficulty.easy,
        group: 'hash-table',
        pattern: 'hash-table',
        code: twoSumCode,
        presets: [
          preset('示例 1', {'nums': [2, 7, 11, 15], 'target': 9}),
          preset('示例 2', {'nums': [3, 2, 4], 'target': 6}),
          preset('示例 3', {'nums': [3, 3], 'target': 6}),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('target', minValue: -10000, maxValue: 10000),
        ]),
        script: twoSumScript,
        maxInputSize: 80,
      ),
      buildProblem(
        slug: 'group-anagrams',
        number: 49,
        title: '字母异位词分组',
        difficulty: ProblemDifficulty.medium,
        group: 'hash-table',
        pattern: 'hash-table',
        code: groupAnagramsCode,
        presets: [
          preset('示例 1', {'strs': 'eat,tea,tan,ate,nat,bat'}),
          preset('示例 2', {'strs': 'a'}),
        ],
        schema: InputSchema(fields: [
          InputField.string('strs', maxLength: 200, label: '字符串数组 (逗号分隔)'),
        ]),
        script: groupAnagramsScript,
        maxInputSize: 60,
      ),
      buildProblem(
        slug: 'longest-consecutive-sequence',
        number: 128,
        title: '最长连续序列',
        difficulty: ProblemDifficulty.medium,
        group: 'hash-table',
        pattern: 'hash-table',
        code: longestConsecutiveCode,
        presets: [
          preset('示例 1', {'nums': [100, 4, 200, 1, 3, 2]}),
          preset('示例 2', {'nums': [0, 3, 7, 2, 5, 8, 4, 6, 0, 1]}),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
        ]),
        script: longestConsecutiveScript,
        maxInputSize: 80,
      ),
      buildProblem(
        slug: 'move-zeroes',
        number: 283,
        title: '移动零',
        difficulty: ProblemDifficulty.easy,
        group: 'two-pointers',
        pattern: 'array-two-pointer',
        code: moveZeroesCode,
        presets: [
          preset('示例 1', {'nums': [0, 1, 0, 3, 12]}),
          preset('示例 2', {'nums': [0]}),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
        ]),
        script: moveZeroesScript,
        maxInputSize: 80,
      ),
      buildProblem(
        slug: 'container-with-most-water',
        number: 11,
        title: '盛最多水的容器',
        difficulty: ProblemDifficulty.medium,
        group: 'two-pointers',
        pattern: 'array-two-pointer',
        code: maxWaterCode,
        presets: [
          preset('示例 1', {'height': [1, 8, 6, 2, 5, 4, 8, 3, 7]}),
          preset('示例 2', {'height': [1, 1]}),
        ],
        schema: InputSchema(fields: [
          InputField.array('height', maxLength: 80),
        ]),
        script: maxWaterScript,
        maxInputSize: 80,
      ),
      buildProblem(
        slug: '3sum',
        number: 15,
        title: '三数之和',
        difficulty: ProblemDifficulty.medium,
        group: 'two-pointers',
        pattern: 'array-two-pointer',
        code: threeSumCode,
        presets: [
          preset('示例 1', {'nums': [-1, 0, 1, 2, -1, -4]}),
          preset('示例 2', {'nums': [0, 1, 1]}),
          preset('示例 3', {'nums': [0, 0, 0]}),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 40),
        ]),
        script: threeSumScript,
        maxInputSize: 40,
      ),
      buildProblem(
        slug: 'trapping-rain-water',
        number: 42,
        title: '接雨水',
        difficulty: ProblemDifficulty.hard,
        group: 'two-pointers',
        pattern: 'array-two-pointer',
        code: trapRainCode,
        presets: [
          preset('示例 1', {'height': [0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1]}),
          preset('示例 2', {'height': [4, 2, 0, 3, 2, 5]}),
        ],
        schema: InputSchema(fields: [
          InputField.array('height', maxLength: 80),
        ]),
        script: trapRainScript,
        maxInputSize: 80,
      ),
      buildProblem(
        slug: 'longest-substring-without-repeating-characters',
        number: 3,
        title: '无重复字符的最长子串',
        difficulty: ProblemDifficulty.medium,
        group: 'sliding-window',
        pattern: 'array-sliding-window',
        code: longestSubstringCode,
        presets: [
          preset('示例 1', {'s': 'abcabcbb'}),
          preset('示例 2', {'s': 'bbbbb'}),
          preset('示例 3', {'s': 'pwwkew'}),
        ],
        schema: InputSchema(fields: [
          InputField.string('s', maxLength: 60, label: '字符串 s'),
        ]),
        script: longestSubstringScript,
        maxInputSize: 60,
      ),
      buildProblem(
        slug: 'find-all-anagrams-in-a-string',
        number: 438,
        title: '找到字符串中所有字母异位词',
        difficulty: ProblemDifficulty.medium,
        group: 'sliding-window',
        pattern: 'array-sliding-window',
        code: findAnagramsCode,
        presets: [
          preset('示例 1', {'s': 'cbaebabacd', 'p': 'abc'}),
          preset('示例 2', {'s': 'abab', 'p': 'ab'}),
        ],
        schema: InputSchema(fields: [
          InputField.string('s', maxLength: 60, label: '字符串 s'),
          InputField.string('p', maxLength: 20, label: '字符串 p'),
        ]),
        script: findAnagramsScript,
        maxInputSize: 60,
      ),
      buildProblem(
        slug: 'subarray-sum-equals-k',
        number: 560,
        title: '和为 K 的子数组',
        difficulty: ProblemDifficulty.medium,
        group: 'substring',
        pattern: 'array-prefix-sum',
        code: subarraySumCode,
        presets: [
          preset('示例 1', {'nums': [1, 1, 1], 'k': 2}),
          preset('示例 2', {'nums': [1, 2, 3], 'k': 3}),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('k', minValue: -10000, maxValue: 10000),
        ]),
        script: subarraySumScript,
        maxInputSize: 80,
      ),
      buildProblem(
        slug: 'sliding-window-maximum',
        number: 239,
        title: '滑动窗口最大值',
        difficulty: ProblemDifficulty.hard,
        group: 'substring',
        pattern: 'array-prefix-sum',
        code: slidingWindowMaxCode,
        presets: [
          preset('示例 1', {'nums': [1, 3, -1, -3, 5, 3, 6, 7], 'k': 3}),
          preset('示例 2', {'nums': [1], 'k': 1}),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('k', minValue: 1, maxValue: 80),
        ]),
        script: slidingWindowMaxScript,
        maxInputSize: 80,
      ),
      buildProblem(
        slug: 'minimum-window-substring',
        number: 76,
        title: '最小覆盖子串',
        difficulty: ProblemDifficulty.hard,
        group: 'substring',
        pattern: 'array-prefix-sum',
        code: minWindowCode,
        presets: [
          preset('示例 1', {'s': 'ADOBECODEBANC', 't': 'ABC'}),
          preset('示例 2', {'s': 'a', 't': 'a'}),
          preset('示例 3', {'s': 'a', 't': 'aa'}),
        ],
        schema: InputSchema(fields: [
          InputField.string('s', maxLength: 60, label: '字符串 s'),
          InputField.string('t', maxLength: 30, label: '字符串 t'),
        ]),
        script: minWindowScript,
        maxInputSize: 60,
      ),
    ];
