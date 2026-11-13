import '../../catalog/problem_entry.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/scene_frame.dart';
import '../script_helpers.dart';

// ===========================================================================
// 栈 (5)
// ===========================================================================

const String validParenthesesCode = '''class Solution {
    public boolean isValid(String s) {
        Deque<Character> stack = new ArrayDeque<>();
        for (char ch : s.toCharArray()) {
            if (ch == '(' || ch == '[' || ch == '{') {
                stack.push(ch);
            } else {
                if (stack.isEmpty()) return false;
                char top = stack.pop();
                if (ch == ')' && top != '(') return false;
                if (ch == ']' && top != '[') return false;
                if (ch == '}' && top != '{') return false;
            }
        }
        return stack.isEmpty();
    }
}''';

List<SceneFrame> validParenthesesScript(Map<String, dynamic> input) {
  final text = strOf(input['s']);
  if (text.isEmpty) throw ArgumentError('字符串不能为空');
  checkSize(text.length, 60, 's');
  final collector = FrameCollector();
  final scene = StackScene(collector, validParenthesesCode);
  const pairs = {')': '(', ']': '[', '}': '{'};
  var valid = true;

  scene.show('遍历字符串 "$text", 左括号入栈', line: 'for (char ch : s.toCharArray())');

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (ch == '(' || ch == '[' || ch == '{') {
      scene.push(ch);
      scene.show(
        '遇到左括号 $ch, 入栈',
        line: 'stack.push(ch)',
        highlight: {scene.items.length - 1},
      );
    } else {
      if (scene.items.isEmpty) {
        valid = false;
        scene.show('遇到 $ch, 但栈为空, 无效', line: 'if (stack.isEmpty()) return false');
        break;
      }
      final top = '${scene.items.last}';
      scene.show(
        '遇到 $ch, 检查栈顶 $top',
        line: 'char top = stack.pop()',
        highlight: {scene.items.length - 1},
      );
      if (pairs[ch] != top) {
        valid = false;
        scene.show('$ch 与栈顶 $top 不匹配, 无效', line: 'return false');
        break;
      }
      scene.pop();
      scene.show(
        '匹配成功, $top 出栈',
        line: 'char top = stack.pop()',
      );
    }
  }

  if (valid && scene.items.isNotEmpty) {
    valid = false;
    scene.show('遍历结束但栈中还有 ${scene.items.length} 个左括号, 无效', line: 'return stack.isEmpty()');
  }
  if (valid) {
    scene.show('全部括号匹配, 字符串有效', line: 'return stack.isEmpty()');
  }
  return collector.build();
}

const String minStackCode = '''class MinStack {
    Deque<Integer> stack = new ArrayDeque<>();
    Deque<Integer> minStack = new ArrayDeque<>();
    public void push(int val) {
        stack.push(val);
        if (minStack.isEmpty() || val <= minStack.peek()) {
            minStack.push(val);
        }
    }
    public void pop() {
        int val = stack.pop();
        if (val == minStack.peek()) minStack.pop();
    }
    public int top() {
        return stack.peek();
    }
    public int getMin() {
        return minStack.peek();
    }
}''';

List<SceneFrame> minStackScript(Map<String, dynamic> input) {
  final opsText = strOf(input['ops']);
  final collector = FrameCollector();
  final scene = StackScene(collector, minStackCode);
  final minStack = <int>[];

  void showState(String caption, {String? line, int? highlight}) {
    scene.show(
      '$caption; 辅助最小栈 = $minStack',
      line: line,
      highlight: {?highlight},
    );
  }

  scene.show('最小栈: 用辅助栈保存每个时刻的最小值', line: 'Deque<Integer> stack');

  final matches = RegExp(r'(\w+)\(([^)]*)\)').allMatches(opsText);
  for (final match in matches) {
    final name = match.group(1)!;
    final args = match
        .group(2)!
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map(int.tryParse)
        .toList();
    if (name == 'push' && args.length == 1 && args[0] != null) {
      final value = args[0]!;
      scene.push(value);
      if (minStack.isEmpty || value <= minStack.last) minStack.add(value);
      showState(
        'push($value)',
        line: 'stack.push(val)',
        highlight: scene.items.length - 1,
      );
    } else if (name == 'pop') {
      if (scene.items.isEmpty) {
        showState('pop() 时栈为空', line: 'int val = stack.pop()');
        continue;
      }
      final value = scene.items.last as int;
      scene.pop();
      if (minStack.isNotEmpty && minStack.last == value) minStack.removeLast();
      showState('pop() 弹出 $value', line: 'if (val == minStack.peek()) minStack.pop()');
    } else if (name == 'top') {
      showState(
        scene.items.isEmpty ? 'top() 时栈为空' : 'top() = ${scene.items.last}',
        line: 'return stack.peek()',
        highlight: scene.items.isEmpty ? null : scene.items.length - 1,
      );
    } else if (name == 'getMin') {
      showState(
        minStack.isEmpty ? 'getMin() 时栈为空' : 'getMin() = ${minStack.last}',
        line: 'return minStack.peek()',
      );
    } else {
      showState('忽略无法解析的操作: ${match.group(0)}', line: 'public void push(int val)');
    }
  }

  scene.show('操作结束', line: 'return minStack.peek()');
  return collector.build();
}

const String decodeStringCode = '''class Solution {
    public String decodeString(String s) {
        Deque<Integer> numStack = new ArrayDeque<>();
        Deque<String> strStack = new ArrayDeque<>();
        StringBuilder cur = new StringBuilder();
        int num = 0;
        for (char ch : s.toCharArray()) {
            if (Character.isDigit(ch)) {
                num = num * 10 + (ch - '0');
            } else if (ch == '[') {
                numStack.push(num);
                strStack.push(cur.toString());
                num = 0;
                cur = new StringBuilder();
            } else if (ch == ']') {
                int repeat = numStack.pop();
                String prev = strStack.pop();
                StringBuilder decoded = new StringBuilder(prev);
                for (int i = 0; i < repeat; i++) decoded.append(cur);
                cur = decoded;
            } else {
                cur.append(ch);
            }
        }
        return cur.toString();
    }
}''';

List<SceneFrame> decodeStringScript(Map<String, dynamic> input) {
  final text = strOf(input['s']);
  if (text.isEmpty) throw ArgumentError('字符串不能为空');
  checkSize(text.length, 60, 's');
  final collector = FrameCollector();
  final scene = StackScene(collector, decodeStringCode);
  final numStack = <int>[];
  final strStack = <String>[];
  var current = '';
  var num = 0;

  scene.show('遍历字符串 "$text"', line: 'StringBuilder cur = new StringBuilder()');

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (RegExp(r'\d').hasMatch(ch)) {
      num = num * 10 + int.parse(ch);
      scene.show(
        '读入数字 $ch, 当前重复次数 $num',
        line: "num = num * 10 + (ch - '0')",
      );
    } else if (ch == '[') {
      numStack.add(num);
      strStack.add(current);
      scene.push(current);
      scene.show(
        '遇到 [ : 保存前缀 "$current" 与次数 $num',
        line: "strStack.push(cur.toString())",
        highlight: {scene.items.length - 1},
      );
      num = 0;
      current = '';
    } else if (ch == ']') {
      if (numStack.isEmpty || strStack.isEmpty) {
        throw ArgumentError('括号不匹配');
      }
      final repeat = numStack.removeLast();
      final prev = strStack.removeLast();
      current = prev + current * repeat;
      scene.pop();
      scene.show(
        '遇到 ] : "$prev" + "$prev" 之前的片段重复 $repeat 次 → "$current"',
        line: 'for (int i = 0; i < repeat; i++) decoded.append(cur)',
      );
    } else {
      current += ch;
      scene.show(
        '读入字符 $ch, 当前片段 "$current"',
        line: 'cur.append(ch)',
      );
    }
  }

  scene.show('解码结果 = "$current"', line: 'return cur.toString()');
  return collector.build();
}

const String dailyTemperaturesCode = '''class Solution {
    public int[] dailyTemperatures(int[] temperatures) {
        int n = temperatures.length;
        int[] answer = new int[n];
        Deque<Integer> stack = new ArrayDeque<>();
        for (int i = 0; i < n; i++) {
            while (!stack.isEmpty() && temperatures[stack.peek()] < temperatures[i]) {
                int j = stack.pop();
                answer[j] = i - j;
            }
            stack.push(i);
        }
        return answer;
    }
}''';

List<SceneFrame> dailyTemperaturesScript(Map<String, dynamic> input) {
  final temps = intList(input['temperatures']);
  if (temps.isEmpty) throw ArgumentError('温度数组不能为空');
  checkSize(temps.length, 80, 'temperatures');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, temps, dailyTemperaturesCode);
  final stack = <int>[];
  final answer = List<int>.filled(temps.length, 0);

  scene.show('单调递减栈保存还没找到更高温度的下标', line: 'Deque<Integer> stack');

  for (var i = 0; i < temps.length; i++) {
    while (stack.isNotEmpty && temps[stack.last] < temps[i]) {
      final j = stack.removeLast();
      answer[j] = i - j;
      scene.show(
        '第 $i 天温度 ${temps[i]} 高于第 $j 天, answer[$j] = ${answer[j]}',
        line: 'answer[j] = i - j',
        pointers: {'i': i},
        highlight: {j, i},
        rangeStart: j,
        rangeEnd: i,
        rangeLabel: '等待天数',
      );
    }
    stack.add(i);
    scene.show(
      '下标 $i 入栈, 栈 = $stack',
      line: 'stack.push(i)',
      pointers: {'i': i},
      highlight: stack.toSet(),
    );
  }

  scene.show('每日温度答案 = $answer', line: 'return answer');
  return collector.build();
}

const String largestRectangleCode = '''class Solution {
    public int largestRectangleArea(int[] heights) {
        int n = heights.length;
        int best = 0;
        Deque<Integer> stack = new ArrayDeque<>();
        for (int i = 0; i <= n; i++) {
            int h = (i == n) ? 0 : heights[i];
            while (!stack.isEmpty() && heights[stack.peek()] > h) {
                int height = heights[stack.pop()];
                int left = stack.isEmpty() ? 0 : stack.peek() + 1;
                int width = i - left;
                best = Math.max(best, height * width);
            }
            if (i < n) stack.push(i);
        }
        return best;
    }
}''';

List<SceneFrame> largestRectangleScript(Map<String, dynamic> input) {
  final heights = intList(input['heights']);
  if (heights.isEmpty) throw ArgumentError('柱高数组不能为空');
  checkSize(heights.length, 80, 'heights');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, heights, largestRectangleCode);
  final stack = <int>[];
  var best = 0;

  scene.show('单调递增栈: 遇到更矮的柱子就结算', line: 'int best = 0');

  for (var i = 0; i <= heights.length; i++) {
    final h = i == heights.length ? 0 : heights[i];
    while (stack.isNotEmpty && heights[stack.last] > h) {
      final j = stack.removeLast();
      final height = heights[j];
      final left = stack.isEmpty ? 0 : stack.last + 1;
      final width = i - left;
      final area = height * width;
      if (area > best) best = area;
      scene.show(
        '弹出下标 $j, 高 $height, 宽 $width, 面积 $area, 最大 $best',
        line: 'best = Math.max(best, height * width)',
        pointers: i < heights.length ? {'i': i} : const {},
        highlight: {j},
        rangeStart: width > 0 ? left : null,
        rangeEnd: width > 0 ? i - 1 : null,
        rangeLabel: '矩形',
      );
    }
    if (i < heights.length) {
      stack.add(i);
      scene.show(
        '下标 $i 入栈, 栈 = $stack',
        line: 'if (i < n) stack.push(i)',
        pointers: {'i': i},
        highlight: stack.toSet(),
      );
    }
  }

  scene.show('柱状图中最大的矩形面积 = $best', line: 'return best');
  return collector.build();
}

// ===========================================================================
// 堆 (3)
// ===========================================================================

const String kthLargestCode = '''class Solution {
    public int findKthLargest(int[] nums, int k) {
        PriorityQueue<Integer> heap = new PriorityQueue<>();
        for (int num : nums) {
            heap.offer(num);
            if (heap.size() > k) heap.poll();
        }
        return heap.peek();
    }
}''';

List<SceneFrame> kthLargestScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final k = intOf(input['k']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  if (k <= 0 || k > nums.length) throw ArgumentError('k 必须在 1 到 ${nums.length} 之间');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = StackScene(collector, kthLargestCode);
  final heap = <int>[];

  scene.show('维护一个大小为 $k 的小顶堆', line: 'PriorityQueue<Integer> heap');

  for (final value in nums) {
    heap.add(value);
    heap.sort();
    if (heap.length > k) {
      final removed = heap.removeAt(0);
      scene.show('加入 $value 后超过 $k 个, 弹出堆顶 $removed', line: 'if (heap.size() > k) heap.poll()');
    }
    scene.items
      ..clear()
      ..addAll(heap);
    scene.show(
      '处理 $value, 当前堆 = $heap',
      line: 'heap.offer(num)',
      highlight: {0},
    );
  }

  scene.show('第 $k 大的元素 = ${heap.first}', line: 'return heap.peek()', highlight: {0});
  return collector.build();
}

const String topKFrequentCode = '''class Solution {
    public int[] topKFrequent(int[] nums, int k) {
        Map<Integer, Integer> count = new HashMap<>();
        for (int num : nums) count.put(num, count.getOrDefault(num, 0) + 1);
        PriorityQueue<Integer> heap = new PriorityQueue<>((a, b) -> count.get(a) - count.get(b));
        for (int num : count.keySet()) {
            heap.offer(num);
            if (heap.size() > k) heap.poll();
        }
        int[] ans = new int[k];
        for (int i = 0; i < k; i++) ans[i] = heap.poll();
        return ans;
    }
}''';

List<SceneFrame> topKFrequentScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  final k = intOf(input['k']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  if (k <= 0 || k > nums.length) throw ArgumentError('k 必须在 1 到 ${nums.length} 之间');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = HashScene(collector, topKFrequentCode);
  final counts = <int, int>{};

  scene.show('统计每个元素出现的次数', line: 'Map<Integer, Integer> count');

  for (final value in nums) {
    counts[value] = (counts[value] ?? 0) + 1;
    final existing = scene.items.where((item) => item.key == value);
    if (existing.isEmpty) {
      scene.add(value, counts[value], bucket: 0);
    } else {
      existing.first.value = counts[value];
    }
    scene.show(
      '元素 $value 出现 ${counts[value]} 次',
      line: 'count.put(num, count.getOrDefault(num, 0) + 1)',
      highlightKeys: {value},
    );
  }

  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = sorted.take(k).map((entry) => entry.key).toList();
  scene.show(
    '出现频率最高的 $k 个元素: $top',
    line: 'return ans',
    highlightKeys: top.toSet(),
  );
  return collector.build();
}

const String medianFinderCode = '''class MedianFinder {
    PriorityQueue<Integer> left = new PriorityQueue<>(Collections.reverseOrder());
    PriorityQueue<Integer> right = new PriorityQueue<>();
    public void addNum(int num) {
        left.offer(num);
        right.offer(left.poll());
        if (right.size() > left.size()) left.offer(right.poll());
    }
    public double findMedian() {
        if (left.size() == right.size()) return (left.peek() + right.peek()) / 2.0;
        return left.peek();
    }
}''';

List<SceneFrame> medianFinderScript(Map<String, dynamic> input) {
  final opsText = strOf(input['ops']);
  final collector = FrameCollector();
  final scene = HashScene(collector, medianFinderCode);
  final left = <int>[];
  final right = <int>[];

  scene.add('大顶堆 left', <int>[], bucket: 0);
  scene.add('小顶堆 right', <int>[], bucket: 1);

  void showState(String caption) {
    left.sort();
    right.sort();
    scene.items[0].value = <int>[...left];
    scene.items[1].value = <int>[...right];
    scene.show(caption, line: 'left.offer(num)');
  }

  showState('初始化两个堆, 大顶堆放较小的一半, 小顶堆放较大的一半');

  final matches = RegExp(r'(\w+)\(([^)]*)\)').allMatches(opsText);
  for (final match in matches) {
    final name = match.group(1)!;
    final args = match
        .group(2)!
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .map(int.tryParse)
        .toList();
    if (name == 'addNum' && args.length == 1 && args[0] != null) {
      final value = args[0]!;
      left.add(value);
      left.sort();
      right.add(left.removeLast());
      right.sort();
      if (right.length > left.length) {
        left.add(right.removeAt(0));
        left.sort();
      }
      showState('addNum($value) 后: left = $left, right = $right');
    } else if (name == 'findMedian') {
      final double median;
      if (left.length == right.length && left.isNotEmpty) {
        median = (left.last + right.first) / 2.0;
      } else {
        median = left.isEmpty ? 0 : left.last.toDouble();
      }
      scene.items[0].value = <int>[...left];
      scene.items[1].value = <int>[...right];
      scene.show(
        'findMedian() = $median',
        line: 'if (left.size() == right.size())',
      );
    } else {
      showState('忽略无法解析的操作: ${match.group(0)}');
    }
  }

  scene.show('操作结束', line: 'return left.peek()');
  return collector.build();
}

// ===========================================================================
// 贪心 (4)
// ===========================================================================

const String stockCode = '''class Solution {
    public int maxProfit(int[] prices) {
        int minPrice = Integer.MAX_VALUE;
        int best = 0;
        for (int price : prices) {
            if (price < minPrice) {
                minPrice = price;
            } else {
                best = Math.max(best, price - minPrice);
            }
        }
        return best;
    }
}''';

List<SceneFrame> stockScript(Map<String, dynamic> input) {
  final prices = intList(input['prices']);
  if (prices.isEmpty) throw ArgumentError('价格数组不能为空');
  checkSize(prices.length, 80, 'prices');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, prices, stockCode);
  var minPrice = prices.first;
  var minIndex = 0;
  var best = 0;

  scene.show('维护历史最低价, 计算今天卖出的收益', line: 'int minPrice = Integer.MAX_VALUE');

  for (var i = 0; i < prices.length; i++) {
    if (prices[i] < minPrice) {
      minPrice = prices[i];
      minIndex = i;
      scene.show(
        '第 $i 天价格 ${prices[i]} 刷新最低价',
        line: 'minPrice = price',
        pointers: {'i': i, 'min': minIndex},
        highlight: {i},
      );
    } else {
      final profit = prices[i] - minPrice;
      if (profit > best) best = profit;
      scene.show(
        '第 $i 天卖出, 收益 $profit, 最大收益 $best',
        line: 'best = Math.max(best, price - minPrice)',
        pointers: {'i': i, 'min': minIndex},
        highlight: {i, minIndex},
        rangeStart: minIndex,
        rangeEnd: i,
        rangeLabel: '买卖区间',
      );
    }
  }

  scene.show('最大收益 = $best', line: 'return best', sorted: {minIndex});
  return collector.build();
}

const String jumpGameCode = '''class Solution {
    public boolean canJump(int[] nums) {
        int reach = 0;
        for (int i = 0; i < nums.length; i++) {
            if (i > reach) return false;
            reach = Math.max(reach, i + nums[i]);
        }
        return true;
    }
}''';

List<SceneFrame> jumpGameScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, jumpGameCode);
  var reach = 0;
  var canReach = true;

  scene.show('维护当前能达到的最远下标', line: 'int reach = 0');

  for (var i = 0; i < nums.length; i++) {
    if (i > reach) {
      canReach = false;
      scene.show('下标 $i 已经超过最远可达 $reach, 无法到达终点', line: 'if (i > reach) return false', pointers: {'i': i});
      break;
    }
    final nextReach = i + nums[i];
    if (nextReach > reach) reach = nextReach;
    scene.show(
      '在下标 $i 可跳到 ${nums[i]}, 最远可达 $reach',
      line: 'reach = Math.max(reach, i + nums[i])',
      pointers: {'i': i},
      highlight: {i},
      rangeStart: i,
      rangeEnd: reach < nums.length ? reach : nums.length - 1,
      rangeLabel: '可达范围',
    );
  }

  scene.show(canReach ? '可以到达最后一个下标' : '无法到达最后一个下标', line: 'return true');
  return collector.build();
}

const String jumpGameIiCode = '''class Solution {
    public int jump(int[] nums) {
        int jumps = 0;
        int end = 0;
        int farthest = 0;
        for (int i = 0; i < nums.length - 1; i++) {
            farthest = Math.max(farthest, i + nums[i]);
            if (i == end) {
                jumps++;
                end = farthest;
            }
        }
        return jumps;
    }
}''';

List<SceneFrame> jumpGameIiScript(Map<String, dynamic> input) {
  final nums = intList(input['nums']);
  if (nums.isEmpty) throw ArgumentError('数组不能为空');
  checkSize(nums.length, 80, 'nums');
  final collector = FrameCollector();
  final scene = ArrayScene(collector, nums, jumpGameIiCode);
  var jumps = 0;
  var end = 0;
  var farthest = 0;

  scene.show('按当前跳跃范围扫描, 范围用尽时增加一次跳跃', line: 'int jumps = 0');

  for (var i = 0; i < nums.length - 1; i++) {
    final candidate = i + nums[i];
    if (candidate > farthest) farthest = candidate;
    scene.show(
      '下标 $i: 更新最远可达 $farthest, 当前边界 $end',
      line: 'farthest = Math.max(farthest, i + nums[i])',
      pointers: {'i': i},
      highlight: {i},
      rangeStart: end,
      rangeEnd: farthest < nums.length ? farthest : nums.length - 1,
      rangeLabel: '下一跳范围',
    );
    if (i == end) {
      jumps++;
      end = farthest;
      scene.show(
        '到达边界, 跳跃次数 $jumps, 新边界 $end',
        line: 'jumps++',
        pointers: {'i': i},
        highlight: {i},
      );
    }
  }

  scene.show('最少跳跃次数 = $jumps', line: 'return jumps');
  return collector.build();
}

const String partitionLabelsCode = '''class Solution {
    public List<Integer> partitionLabels(String s) {
        int[] last = new int[26];
        for (int i = 0; i < s.length(); i++) last[s.charAt(i) - 'a'] = i;
        List<Integer> ans = new ArrayList<>();
        int start = 0, end = 0;
        for (int i = 0; i < s.length(); i++) {
            end = Math.max(end, last[s.charAt(i) - 'a']);
            if (i == end) {
                ans.add(end - start + 1);
                start = end + 1;
            }
        }
        return ans;
    }
}''';

List<SceneFrame> partitionLabelsScript(Map<String, dynamic> input) {
  final text = strOf(input['s']);
  if (text.isEmpty) throw ArgumentError('字符串不能为空');
  checkSize(text.length, 60, 's');
  final chars = text.split('');
  final collector = FrameCollector();
  final scene = TextRowScene(collector, chars, partitionLabelsCode);
  final last = <String, int>{};
  for (var i = 0; i < chars.length; i++) {
    last[chars[i]] = i;
  }
  final visited = <int>{};
  final parts = <int>[];
  var start = 0;
  var end = 0;

  scene.show('先记录每个字符最后出现的位置', line: 'int[] last = new int[26]');

  for (var i = 0; i < chars.length; i++) {
    final lastIndex = last[chars[i]]!;
    if (lastIndex > end) end = lastIndex;
    scene.show(
      '字符 ${chars[i]} 最后出现在 $lastIndex, 当前片段边界 $end',
      line: "end = Math.max(end, last[s.charAt(i) - 'a']);",
      pointers: {'i': i},
      highlight: {i},
      rangeStart: start,
      rangeEnd: end,
      rangeLabel: '当前片段',
    );
    if (i == end) {
      parts.add(end - start + 1);
      visited.addAll([for (var j = start; j <= end; j++) j]);
      scene.show(
        '片段 [$start, $end] 结束, 长度 ${parts.last}, 划分 $parts',
        line: 'ans.add(end - start + 1)',
        visited: visited,
        rangeStart: start,
        rangeEnd: end,
        rangeLabel: '片段',
      );
      start = end + 1;
    }
  }

  scene.show('划分结果长度 = $parts', line: 'return ans', visited: visited);
  return collector.build();
}

// ===========================================================================
// 题目描述符
// ===========================================================================

List<ProblemEntry> batch6Problems() => [
      buildProblem(
        slug: 'valid-parentheses',
        number: 20,
        title: '有效的括号',
        difficulty: ProblemDifficulty.easy,
        group: 'stack',
        pattern: 'stack',
        code: validParenthesesCode,
        presets: [
          preset('示例 1', {'s': '()'}),
          preset('示例 2', {'s': '()[]{}'}),
          preset('示例 3', {'s': '(]'}),
        ],
        schema: InputSchema(fields: [InputField.string('s', maxLength: 60)]),
        script: validParenthesesScript,
      ),
      buildProblem(
        slug: 'min-stack',
        number: 155,
        title: '最小栈',
        difficulty: ProblemDifficulty.medium,
        group: 'stack',
        pattern: 'stack',
        code: minStackCode,
        presets: [
          preset('示例 1', {
            'ops': 'push(-2) push(0) push(-3) getMin() pop() top() getMin()',
          }),
          preset('示例 2', {
            'ops': 'push(5) push(3) getMin() push(1) getMin() pop() getMin()',
          }),
        ],
        schema: InputSchema(fields: [InputField.string('ops', maxLength: 300)]),
        script: minStackScript,
      ),
      buildProblem(
        slug: 'decode-string',
        number: 394,
        title: '字符串解码',
        difficulty: ProblemDifficulty.medium,
        group: 'stack',
        pattern: 'stack',
        code: decodeStringCode,
        presets: [
          preset('示例 1', {'s': '3[a]2[bc]'}),
          preset('示例 2', {'s': '3[a2[c]]'}),
          preset('示例 3', {'s': '2[abc]3[cd]ef'}),
        ],
        schema: InputSchema(fields: [InputField.string('s', maxLength: 60)]),
        script: decodeStringScript,
      ),
      buildProblem(
        slug: 'daily-temperatures',
        number: 739,
        title: '每日温度',
        difficulty: ProblemDifficulty.medium,
        group: 'stack',
        pattern: 'stack',
        code: dailyTemperaturesCode,
        presets: [
          preset('示例 1', {
            'temperatures': [73, 74, 75, 71, 69, 72, 76, 73],
          }),
          preset('示例 2', {
            'temperatures': [30, 40, 50, 60],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('temperatures', maxLength: 80)]),
        script: dailyTemperaturesScript,
      ),
      buildProblem(
        slug: 'largest-rectangle-in-histogram',
        number: 84,
        title: '柱状图中最大的矩形',
        difficulty: ProblemDifficulty.hard,
        group: 'stack',
        pattern: 'stack',
        code: largestRectangleCode,
        presets: [
          preset('示例 1', {
            'heights': [2, 1, 5, 6, 2, 3],
          }),
          preset('示例 2', {
            'heights': [2, 4],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('heights', maxLength: 80)]),
        script: largestRectangleScript,
      ),
      buildProblem(
        slug: 'kth-largest-element-in-an-array',
        number: 215,
        title: '数组中的第 K 个最大元素',
        difficulty: ProblemDifficulty.medium,
        group: 'heap',
        pattern: 'heap',
        code: kthLargestCode,
        presets: [
          preset('示例 1', {
            'nums': [3, 2, 1, 5, 6, 4],
            'k': 2,
          }),
          preset('示例 2', {
            'nums': [3, 2, 3, 1, 2, 4, 5, 5, 6],
            'k': 4,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('k', minValue: 1, maxValue: 80),
        ]),
        script: kthLargestScript,
      ),
      buildProblem(
        slug: 'top-k-frequent-elements',
        number: 347,
        title: '前 K 个高频元素',
        difficulty: ProblemDifficulty.medium,
        group: 'heap',
        pattern: 'heap',
        code: topKFrequentCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 1, 1, 2, 2, 3],
            'k': 2,
          }),
          preset('示例 2', {
            'nums': [1],
            'k': 1,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 80),
          InputField.int('k', minValue: 1, maxValue: 80),
        ]),
        script: topKFrequentScript,
      ),
      buildProblem(
        slug: 'find-median-from-data-stream',
        number: 295,
        title: '数据流的中位数',
        difficulty: ProblemDifficulty.hard,
        group: 'heap',
        pattern: 'heap',
        code: medianFinderCode,
        presets: [
          preset('示例 1', {
            'ops': 'addNum(1) addNum(2) findMedian() addNum(3) findMedian()',
          }),
          preset('示例 2', {
            'ops': 'addNum(6) addNum(10) addNum(2) findMedian() addNum(6) findMedian()',
          }),
        ],
        schema: InputSchema(fields: [InputField.string('ops', maxLength: 300)]),
        script: medianFinderScript,
      ),
      buildProblem(
        slug: 'best-time-to-buy-and-sell-stock',
        number: 121,
        title: '买卖股票的最佳时机',
        difficulty: ProblemDifficulty.easy,
        group: 'greedy',
        pattern: 'array-basic',
        code: stockCode,
        presets: [
          preset('示例 1', {
            'prices': [7, 1, 5, 3, 6, 4],
          }),
          preset('示例 2', {
            'prices': [7, 6, 4, 3, 1],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('prices', maxLength: 80)]),
        script: stockScript,
      ),
      buildProblem(
        slug: 'jump-game',
        number: 55,
        title: '跳跃游戏',
        difficulty: ProblemDifficulty.medium,
        group: 'greedy',
        pattern: 'array-basic',
        code: jumpGameCode,
        presets: [
          preset('示例 1', {
            'nums': [2, 3, 1, 1, 4],
          }),
          preset('示例 2', {
            'nums': [3, 2, 1, 0, 4],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: jumpGameScript,
      ),
      buildProblem(
        slug: 'jump-game-ii',
        number: 45,
        title: '跳跃游戏 II',
        difficulty: ProblemDifficulty.medium,
        group: 'greedy',
        pattern: 'array-basic',
        code: jumpGameIiCode,
        presets: [
          preset('示例 1', {
            'nums': [2, 3, 1, 1, 4],
          }),
          preset('示例 2', {
            'nums': [2, 3, 0, 1, 4],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 80)]),
        script: jumpGameIiScript,
      ),
      buildProblem(
        slug: 'partition-labels',
        number: 763,
        title: '划分字母区间',
        difficulty: ProblemDifficulty.medium,
        group: 'greedy',
        pattern: 'array-basic',
        code: partitionLabelsCode,
        presets: [
          preset('示例 1', {'s': 'ababcbacadefegdehijhklij'}),
          preset('示例 2', {'s': 'eccbbbbdec'}),
        ],
        schema: InputSchema(fields: [InputField.string('s', maxLength: 60)]),
        script: partitionLabelsScript,
      ),
    ];
