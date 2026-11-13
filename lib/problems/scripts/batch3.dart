import '../../catalog/problem_entry.dart';
import '../../core/scene/input_schema.dart';
import '../../core/scene/scene_frame.dart';
import '../script_helpers.dart';

// ===========================================================================
// 链表 (14)
// ===========================================================================

const String intersectionCode = '''public class Solution {
    public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
        ListNode p1 = headA, p2 = headB;
        while (p1 != p2) {
            p1 = (p1 == null) ? headB : p1.next;
            p2 = (p2 == null) ? headA : p2.next;
        }
        return p1;
    }
}''';

List<SceneFrame> intersectionScript(Map<String, dynamic> input) {
  final a = intList(input['listA']);
  final b = intList(input['listB']);
  final skipA = intOf(input['skipA']);
  final skipB = intOf(input['skipB']);
  if (a.isEmpty || b.isEmpty) {
    throw ArgumentError('两个链表都不能为空');
  }
  checkSize(a.length, 60, 'listA');
  checkSize(b.length, 60, 'listB');
  final collector = FrameCollector();
  final aNodes = chain(a, prefix: 'a');
  final intersects =
      skipA >= 0 && skipA < a.length && skipB >= 0 && skipB < b.length;
  final bNodes = intersects
      ? chain(b.sublist(0, skipB), prefix: 'b')
      : chain(b, prefix: 'b');
  if (intersects && bNodes.isNotEmpty) {
    bNodes.last.nextId = 'a$skipA';
  }
  final scene = ListScene(collector, [...aNodes, ...bNodes], intersectionCode);

  String? p1 = 'a0';
  String? p2 = 'b0';
  String label(String? id) => id == null ? 'null' : '${scene.valueOf(id)}';

  scene.show(
    'p1 指向 A 头 ${label(p1)}, p2 指向 B 头 ${label(p2)}',
    line: 'ListNode p1',
    pointers: livePointers({'p1': p1, 'p2': p2}),
    highlight: {'a0', 'b0'},
  );

  var guard = 0;
  while (p1 != p2) {
    if (p1 == null && p2 == null) break;
    final next1 = p1 == null ? 'b0' : scene.nextOf(p1);
    final next2 = p2 == null ? 'a0' : scene.nextOf(p2);
    p1 = next1;
    p2 = next2;
    guard++;
    scene.show(
      'p1 = ${label(p1)}, p2 = ${label(p2)}',
      line: 'p1 = (p1 == null)',
      pointers: livePointers({'p1': p1, 'p2': p2}),
      highlight: {if (p1 != null && p1 == p2) p1},
    );
    if (guard > (a.length + b.length) * 2 + 4) break;
  }

  if (p1 != null && p1 == p2) {
    scene.show(
      '在节点 ${label(p1)} 相交',
      line: 'return p1',
      highlight: {p1},
      visited: {p1},
    );
  } else {
    scene.show('两个链表不相交, 返回 null', line: 'return p1');
  }
  return collector.build();
}

const String reverseListCode = '''class Solution {
    public ListNode reverseList(ListNode head) {
        ListNode prev = null;
        ListNode cur = head;
        while (cur != null) {
            ListNode next = cur.next;
            cur.next = prev;
            prev = cur;
            cur = next;
        }
        return prev;
    }
}''';

List<SceneFrame> reverseListScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  checkSize(values.length, 60, 'nums');
  final collector = FrameCollector();
  final scene = ListScene(collector, chain(values), reverseListCode);
  String? prev;
  String? cur = 'n0';

  scene.show('prev = null, cur 指向头节点', line: 'ListNode prev', pointers: {'cur': cur});

  while (cur != null) {
    final next = scene.nextOf(cur);
    scene.setNext(cur, prev);
    scene.show(
      'cur = ${scene.valueOf(cur)}, 让它的 next 指向 ${prev == null ? 'null' : scene.valueOf(prev)}',
      line: 'cur.next = prev',
      pointers: livePointers({'prev': prev, 'cur': cur, 'next': next}),
      highlight: {cur},
    );
    prev = cur;
    cur = next;
  }

  scene.show(
    '反转完成, 新头节点是 ${prev == null ? 'null' : scene.valueOf(prev)}',
    line: 'return prev',
    visited: {?prev},
  );
  return collector.build();
}

const String palindromeCode = '''class Solution {
    public boolean isPalindrome(ListNode head) {
        ListNode slow = head, fast = head;
        while (fast.next != null && fast.next.next != null) {
            slow = slow.next;
            fast = fast.next.next;
        }
        ListNode second = reverse(slow.next);
        ListNode p1 = head, p2 = second;
        while (p2 != null) {
            if (p1.val != p2.val) return false;
            p1 = p1.next;
            p2 = p2.next;
        }
        return true;
    }
    ListNode reverse(ListNode head) {
        ListNode prev = null, cur = head;
        while (cur != null) {
            ListNode next = cur.next;
            cur.next = prev;
            prev = cur;
            cur = next;
        }
        return prev;
    }
}''';

List<SceneFrame> palindromeScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  checkSize(values.length, 60, 'nums');
  final collector = FrameCollector();
  final scene = ListScene(collector, chain(values), palindromeCode);

  var slow = 'n0';
  var fast = 'n0';
  scene.show('slow / fast 同时从头出发', line: 'ListNode slow');
  while (scene.nextOf(fast) != null && scene.nextOf(scene.nextOf(fast)!) != null) {
    slow = scene.nextOf(slow)!;
    fast = scene.nextOf(scene.nextOf(fast)!)!;
    scene.show(
      'slow 到 ${scene.valueOf(slow)}, fast 到 ${scene.valueOf(fast)}',
      line: 'slow = slow.next',
      pointers: {'slow': slow, 'fast': fast},
    );
  }
  scene.show(
    '中点 ${scene.valueOf(slow)}, 反转后半段',
    line: 'ListNode second',
    highlight: {slow},
  );

  String? reverse(String? head) {
    String? prev;
    var cur = head;
    while (cur != null) {
      final next = scene.nextOf(cur);
      scene.setNext(cur, prev);
      scene.show(
        '反转: ${scene.valueOf(cur)} 的 next 指向 ${prev == null ? 'null' : scene.valueOf(prev)}',
        line: 'cur.next = prev',
        pointers: livePointers({'prev': prev, 'cur': cur}),
        highlight: {cur},
      );
      prev = cur;
      cur = next;
    }
    return prev;
  }

  final second = reverse(scene.nextOf(slow));
  String? p1 = 'n0';
  String? p2 = second;
  scene.show(
    'p1 从头, p2 从反转后的后半段头 ${p2 == null ? 'null' : scene.valueOf(p2)} 出发',
    line: 'ListNode p1',
    pointers: livePointers({'p1': p1, 'p2': p2}),
  );

  while (p2 != null) {
    scene.show(
      '比较 ${scene.valueOf(p1!)} 与 ${scene.valueOf(p2)}',
      line: 'if (p1.val != p2.val)',
      pointers: livePointers({'p1': p1, 'p2': p2}),
      highlight: {p1, p2},
    );
    if (scene.valueOf(p1) != scene.valueOf(p2)) {
      scene.show('发现不相等, 不是回文链表', line: 'return false');
      return collector.build();
    }
    p1 = scene.nextOf(p1);
    p2 = scene.nextOf(p2);
  }

  scene.show('全部对称, 是回文链表', line: 'return true');
  return collector.build();
}

const String hasCycleCode = '''public class Solution {
    public boolean hasCycle(ListNode head) {
        ListNode slow = head, fast = head;
        while (fast != null && fast.next != null) {
            slow = slow.next;
            fast = fast.next.next;
            if (slow == fast) return true;
        }
        return false;
    }
}''';

List<SceneFrame> hasCycleScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  final pos = intOf(input['pos'], -1);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  checkSize(values.length, 60, 'nums');
  final collector = FrameCollector();
  final nodes = chain(values);
  if (pos >= 0 && pos < nodes.length) {
    nodes.last.nextId = 'n$pos';
  }
  final scene = ListScene(collector, nodes, hasCycleCode);

  String? slow = 'n0';
  String? fast = 'n0';
  scene.show(
    pos >= 0 ? '存在环: 尾节点指回下标 $pos 的节点' : '链表无环',
    line: 'ListNode slow',
    pointers: {'slow': slow, 'fast': fast},
  );

  while (fast != null && scene.nextOf(fast) != null) {
    slow = scene.nextOf(slow);
    fast = scene.nextOf(scene.nextOf(fast)!);
    scene.show(
      'slow 到 ${slow == null ? 'null' : scene.valueOf(slow)}, fast 到 ${fast == null ? 'null' : scene.valueOf(fast)}',
      line: 'fast = fast.next.next',
      pointers: livePointers({'slow': slow, 'fast': fast}),
      highlight: {if (slow != null && slow == fast) slow},
    );
    if (slow != null && slow == fast) {
      scene.show('slow 与 fast 相遇, 存在环', line: 'return true', highlight: {slow});
      return collector.build();
    }
  }

  scene.show('fast 走到链表末尾, 没有环', line: 'return false');
  return collector.build();
}

const String cycleEntryCode = '''public class Solution {
    public ListNode detectCycle(ListNode head) {
        ListNode slow = head, fast = head;
        while (fast != null && fast.next != null) {
            slow = slow.next;
            fast = fast.next.next;
            if (slow == fast) {
                ListNode p = head;
                while (p != slow) {
                    p = p.next;
                    slow = slow.next;
                }
                return p;
            }
        }
        return null;
    }
}''';

List<SceneFrame> cycleEntryScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  final pos = intOf(input['pos'], -1);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  checkSize(values.length, 60, 'nums');
  final collector = FrameCollector();
  final nodes = chain(values);
  if (pos >= 0 && pos < nodes.length) {
    nodes.last.nextId = 'n$pos';
  }
  final scene = ListScene(collector, nodes, cycleEntryCode);

  String? slow = 'n0';
  String? fast = 'n0';
  scene.show(
    pos >= 0 ? '存在环: 尾节点指回下标 $pos 的节点' : '链表无环',
    line: 'ListNode slow',
    pointers: {'slow': slow, 'fast': fast},
  );

  while (fast != null && scene.nextOf(fast) != null) {
    slow = scene.nextOf(slow);
    fast = scene.nextOf(scene.nextOf(fast)!);
    scene.show(
      'slow 到 ${slow == null ? 'null' : scene.valueOf(slow)}, fast 到 ${fast == null ? 'null' : scene.valueOf(fast)}',
      line: 'fast = fast.next.next',
      pointers: livePointers({'slow': slow, 'fast': fast}),
      highlight: {if (slow != null && slow == fast) slow},
    );
    if (slow != null && slow == fast) break;
  }

  if (slow == null || fast == null || slow != fast) {
    scene.show('没有环, 返回 null', line: 'return null');
    return collector.build();
  }

  String? p = 'n0';
  scene.show(
    '相遇于 ${scene.valueOf(slow)}, 让 p 从头出发, slow 留在相遇点',
    line: 'ListNode p = head',
    pointers: livePointers({'p': p, 'slow': slow}),
    highlight: {slow},
  );
  while (p != slow) {
    p = scene.nextOf(p);
    slow = scene.nextOf(slow);
    scene.show(
      'p 到 ${p == null ? 'null' : scene.valueOf(p)}, slow 到 ${slow == null ? 'null' : scene.valueOf(slow)}',
      line: 'p = p.next',
      pointers: livePointers({'p': p, 'slow': slow}),
    );
  }

  scene.show('p 与 slow 在环入口 ${scene.valueOf(p!)} 相遇', line: 'return p', visited: {p});
  return collector.build();
}

const String mergeTwoListsCode = '''class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        ListNode dummy = new ListNode(0);
        ListNode tail = dummy;
        while (l1 != null && l2 != null) {
            if (l1.val <= l2.val) {
                tail.next = l1;
                l1 = l1.next;
            } else {
                tail.next = l2;
                l2 = l2.next;
            }
            tail = tail.next;
        }
        tail.next = (l1 != null) ? l1 : l2;
        return dummy.next;
    }
}''';

List<SceneFrame> mergeTwoListsScript(Map<String, dynamic> input) {
  final l1 = intList(input['l1']);
  final l2 = intList(input['l2']);
  checkSize(l1.length, 60, 'l1');
  checkSize(l2.length, 60, 'l2');
  final collector = FrameCollector();
  final aNodes = chain(l1, prefix: 'a');
  final bNodes = chain(l2, prefix: 'b');
  final scene = ListScene(collector, [...aNodes, ...bNodes], mergeTwoListsCode);

  String? a = aNodes.isEmpty ? null : 'a0';
  String? b = bNodes.isEmpty ? null : 'b0';
  String? head;
  String? tail;

  scene.show(
    '两条升序链表: l1 = $l1, l2 = $l2',
    line: 'ListNode dummy',
    pointers: livePointers({'l1': a, 'l2': b}),
  );

  while (a != null && b != null) {
    final va = scene.valueOf(a);
    final vb = scene.valueOf(b);
    final pick = va <= vb ? a : b;
    scene.show(
      '比较 $va 与 $vb, 取较小的 $pick',
      line: 'if (l1.val <= l2.val)',
      pointers: livePointers({'l1': a, 'l2': b}),
      highlight: {pick},
    );
    if (tail == null) {
      head = pick;
    } else {
      scene.setNext(tail, pick);
    }
    tail = pick;
    if (pick == a) {
      a = scene.nextOf(a);
    } else {
      b = scene.nextOf(b);
    }
  }

  final rest = a ?? b;
  if (rest != null) {
    if (tail == null) {
      head = rest;
    } else {
      scene.setNext(tail, rest);
    }
    scene.show('把剩余链表直接接到尾部', line: 'tail.next = (l1 != null) ? l1 : l2');
  } else if (tail != null) {
    scene.setNext(tail, null);
  }

  if (head == null) {
    scene.show('两条链表都为空', line: 'return dummy.next');
  } else {
    scene.show('合并完成, 新头节点 ${scene.valueOf(head)}', line: 'return dummy.next', visited: {head});
  }
  return collector.build();
}

const String addTwoNumbersCode = '''class Solution {
    public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
        ListNode dummy = new ListNode(0);
        ListNode tail = dummy;
        int carry = 0;
        while (l1 != null || l2 != null || carry > 0) {
            int a = (l1 != null) ? l1.val : 0;
            int b = (l2 != null) ? l2.val : 0;
            int sum = a + b + carry;
            carry = sum / 10;
            tail.next = new ListNode(sum % 10);
            tail = tail.next;
            if (l1 != null) l1 = l1.next;
            if (l2 != null) l2 = l2.next;
        }
        return dummy.next;
    }
}''';

List<SceneFrame> addTwoNumbersScript(Map<String, dynamic> input) {
  final l1 = intList(input['l1']);
  final l2 = intList(input['l2']);
  checkSize(l1.length, 60, 'l1');
  checkSize(l2.length, 60, 'l2');
  final collector = FrameCollector();
  final nodes = [...chain(l1, prefix: 'a'), ...chain(l2, prefix: 'b')];
  final scene = ListScene(collector, nodes, addTwoNumbersCode);

  String? a = l1.isEmpty ? null : 'a0';
  String? b = l2.isEmpty ? null : 'b0';
  String? resultHead;
  String? tail;
  var carry = 0;
  var index = 0;

  scene.show(
    '两个链表按低位在前存储: l1 = $l1, l2 = $l2',
    line: 'ListNode dummy',
    pointers: livePointers({'l1': a, 'l2': b}),
  );

  while (a != null || b != null || carry > 0) {
    final va = a == null ? 0 : scene.valueOf(a);
    final vb = b == null ? 0 : scene.valueOf(b);
    final sum = va + vb + carry;
    final digit = sum % 10;
    final nextCarry = sum ~/ 10;
    final node = ListNodeSpec('r$index', digit);
    nodes.add(node);
    if (resultHead == null) {
      resultHead = node.id;
    } else {
      scene.setNext(tail!, node.id);
    }
    tail = node.id;
    carry = nextCarry;
    scene.show(
      '$va + $vb + 进位 = $sum, 本位 $digit, 新进位 $carry',
      line: 'tail.next = new ListNode',
      pointers: livePointers({'l1': a, 'l2': b}),
      highlight: {node.id},
    );
    a = scene.nextOf(a);
    b = scene.nextOf(b);
    index++;
  }

  scene.show(
    '相加完成, 结果头节点 ${resultHead == null ? 'null' : scene.valueOf(resultHead)}',
    line: 'return dummy.next',
    visited: {?resultHead},
  );
  return collector.build();
}

const String removeNthCode = '''class Solution {
    public ListNode removeNthFromEnd(ListNode head, int n) {
        ListNode fast = head;
        for (int i = 0; i < n; i++) fast = fast.next;
        if (fast == null) return head.next;
        ListNode slow = head;
        while (fast.next != null) {
            fast = fast.next;
            slow = slow.next;
        }
        slow.next = slow.next.next;
        return head;
    }
}''';

List<SceneFrame> removeNthScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  final n = intOf(input['n']);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  if (n <= 0 || n > values.length) {
    throw ArgumentError('n 必须在 1 到 ${values.length} 之间');
  }
  checkSize(values.length, 60, 'nums');
  final collector = FrameCollector();
  final scene = ListScene(collector, chain(values), removeNthCode);

  String? fast = 'n0';
  scene.show('fast 从头节点出发, 先前进 $n 步', line: 'ListNode fast', pointers: {'fast': fast});
  for (var i = 0; i < n; i++) {
    fast = scene.nextOf(fast);
    scene.show(
      'fast 前进第 ${i + 1} 步, 指向 ${fast == null ? 'null' : scene.valueOf(fast)}',
      line: 'for (int i = 0; i < n; i++)',
      pointers: livePointers({'fast': fast}),
    );
  }

  if (fast == null) {
    scene.show('倒数第 $n 个正好是头节点, 删除头节点', line: 'if (fast == null)', highlight: {'n0'});
    scene.byId('n0').visible = false;
    scene.show('删除后新的头节点是 ${values.length > 1 ? values[1] : 'null'}', line: 'return head.next');
    return collector.build();
  }

  var slow = 'n0';
  scene.show('slow 从头出发, fast 与 slow 保持 $n 步距离', line: 'ListNode slow', pointers: {'fast': fast, 'slow': slow});
  while (scene.nextOf(fast) != null) {
    fast = scene.nextOf(fast);
    slow = scene.nextOf(slow)!;
    scene.show(
      'fast 到 ${fast == null ? 'null' : scene.valueOf(fast)}, slow 到 ${scene.valueOf(slow)}',
      line: 'while (fast.next != null)',
      pointers: livePointers({'fast': fast, 'slow': slow}),
    );
  }

  final target = scene.nextOf(slow)!;
  scene.show(
    'slow 停在待删节点前, 删除 ${scene.valueOf(target)}',
    line: 'slow.next = slow.next.next',
    pointers: {'slow': slow},
    highlight: {target},
  );
  scene.setNext(slow, scene.nextOf(target));
  scene.byId(target).visible = false;
  scene.show('删除完成', line: 'return head');
  return collector.build();
}

const String swapPairsCode = '''class Solution {
    public ListNode swapPairs(ListNode head) {
        if (head == null || head.next == null) return head;
        ListNode dummy = new ListNode(0);
        dummy.next = head;
        ListNode prev = dummy;
        while (prev.next != null && prev.next.next != null) {
            ListNode first = prev.next;
            ListNode second = first.next;
            first.next = second.next;
            second.next = first;
            prev.next = second;
            prev = first;
        }
        return dummy.next;
    }
}''';

List<SceneFrame> swapPairsScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  checkSize(values.length, 60, 'nums');
  final collector = FrameCollector();
  final scene = ListScene(collector, chain(values), swapPairsCode);

  String? prevTail;
  String? cur = 'n0';
  scene.show('从第一对节点开始交换', line: 'ListNode prev = dummy', pointers: {'cur': cur});

  while (cur != null && scene.nextOf(cur) != null) {
    final second = scene.nextOf(cur)!;
    final nextPair = scene.nextOf(second);
    scene.show(
      '准备交换 ${scene.valueOf(cur)} 与 ${scene.valueOf(second)}',
      line: 'ListNode first = prev.next',
      pointers: livePointers({'first': cur, 'second': second, 'prev': prevTail}),
      highlight: {cur, second},
    );
    scene.setNext(second, cur);
    scene.setNext(cur, nextPair);
    if (prevTail != null) {
      scene.setNext(prevTail, second);
    }
    scene.show(
      '交换完成: ${scene.valueOf(second)} → ${scene.valueOf(cur)}',
      line: 'prev.next = second',
      pointers: livePointers({'prev': prevTail, 'second': second}),
      highlight: {second, cur},
    );
    prevTail = cur;
    cur = nextPair;
  }

  if (cur != null) {
    scene.show('剩余单个节点 ${scene.valueOf(cur)} 保持原位', line: 'return dummy.next', pointers: {'cur': cur});
  } else {
    scene.show('两两交换完成', line: 'return dummy.next');
  }
  return collector.build();
}

const String reverseKGroupCode = '''class Solution {
    public ListNode reverseKGroup(ListNode head, int k) {
        ListNode dummy = new ListNode(0);
        dummy.next = head;
        ListNode prevTail = dummy;
        ListNode cur = head;
        while (cur != null) {
            ListNode probe = cur;
            int count = 1;
            while (probe != null && count < k) {
                probe = probe.next;
                count++;
            }
            if (probe == null) break;
            ListNode nextGroup = probe.next;
            ListNode prev = nextGroup;
            ListNode node = cur;
            for (int i = 0; i < k; i++) {
                ListNode next = node.next;
                node.next = prev;
                prev = node;
                node = next;
            }
            prevTail.next = prev;
            prevTail = cur;
            cur = nextGroup;
        }
        return dummy.next;
    }
}''';

List<SceneFrame> reverseKGroupScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  final k = intOf(input['k']);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  if (k < 1) throw ArgumentError('k 必须大于等于 1');
  checkSize(values.length, 60, 'nums');
  final collector = FrameCollector();
  final scene = ListScene(collector, chain(values), reverseKGroupCode);

  String? prevTail;
  String? cur = 'n0';
  scene.show('每 $k 个节点为一组翻转', line: 'ListNode prevTail = dummy', pointers: {'cur': cur});

  while (cur != null) {
    String? probe = cur;
    var count = 1;
    while (probe != null && count < k) {
      probe = scene.nextOf(probe);
      count++;
    }
    if (probe == null) {
      scene.show('剩余不足 $k 个节点, 保持原顺序', line: 'if (probe == null) break');
      break;
    }

    final nextGroup = scene.nextOf(probe);
    scene.show(
      '本组 $k 个节点: 从 ${scene.valueOf(cur)} 到 ${scene.valueOf(probe)}',
      line: 'ListNode nextGroup = probe.next',
      pointers: livePointers({'cur': cur, 'probe': probe, 'nextGroup': nextGroup}),
      highlight: {cur, probe},
    );

    String? prev = nextGroup;
    String? node = cur;
    for (var i = 0; i < k; i++) {
      final current = node!;
      final next = scene.nextOf(current);
      scene.setNext(current, prev);
      scene.show(
        '反转节点 ${scene.valueOf(current)}, next 指向 ${prev == null ? 'null' : scene.valueOf(prev)}',
        line: 'node.next = prev',
        pointers: livePointers({'prev': prev, 'node': current, 'next': next}),
        highlight: {current},
      );
      prev = current;
      node = next;
    }

    if (prevTail != null) {
      scene.setNext(prevTail, prev);
    }
    scene.show(
      '本组翻转完成, 新组头是 ${prev == null ? 'null' : scene.valueOf(prev)}',
      line: 'prevTail.next = prev',
      highlight: {?prev},
    );
    prevTail = cur;
    cur = nextGroup;
  }

  scene.show('K 个一组翻转完成', line: 'return dummy.next');
  return collector.build();
}

const String copyRandomListCode = '''class Solution {
    public Node copyRandomList(Node head) {
        if (head == null) return null;
        Map<Node, Node> map = new HashMap<>();
        for (Node cur = head; cur != null; cur = cur.next) {
            map.put(cur, new Node(cur.val));
        }
        for (Node cur = head; cur != null; cur = cur.next) {
            map.get(cur).next = map.get(cur.next);
            map.get(cur).random = map.get(cur.random);
        }
        return map.get(head);
    }
}''';

List<SceneFrame> copyRandomListScript(Map<String, dynamic> input) {
  final values = intList(input['values']);
  final randoms = intList(input['random']);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  checkSize(values.length, 60, 'values');
  final collector = FrameCollector();
  final originals = chain(values, prefix: 'o');
  for (var i = 0; i < originals.length; i++) {
    final random = i < randoms.length ? randoms[i] : -1;
    originals[i].randomId =
        random >= 0 && random < values.length ? 'o$random' : null;
  }
  final nodes = <ListNodeSpec>[...originals];
  final scene = ListScene(collector, nodes, copyRandomListCode);
  final copies = <String, String>{};

  scene.show('原链表, random 指针映射为 ${_randomText(values, randoms)}', line: 'if (head == null)');

  for (var i = 0; i < originals.length; i++) {
    final copy = ListNodeSpec('c$i', originals[i].value);
    nodes.add(copy);
    copies[originals[i].id] = copy.id;
    scene.show(
      '复制节点 ${originals[i].value} → 新节点 ${copy.id}',
      line: 'map.put(cur, new Node(cur.val))',
      highlight: {copy.id},
      visited: {copy.id},
    );
  }

  for (var i = 0; i < originals.length; i++) {
    final origin = originals[i];
    final copy = scene.byId(copies[origin.id]!);
    final originNext = origin.nextId;
    final originRandom = origin.randomId;
    copy.nextId = originNext == null ? null : copies[originNext];
    copy.randomId = originRandom == null ? null : copies[originRandom];
    scene.show(
      '新节点 ${copy.value}: next → ${originNext == null ? 'null' : scene.valueOf(copies[originNext]!)}'
      ', random → ${originRandom == null ? 'null' : scene.valueOf(copies[originRandom]!)}',
      line: 'map.get(cur).next = map.get(cur.next)',
      highlight: {copy.id},
    );
  }

  scene.show(
    '深拷贝完成, 新链表头节点 ${scene.valueOf(copies['o0']!)}',
    line: 'return map.get(head)',
    visited: {copies['o0']!},
  );
  return collector.build();
}

String _randomText(List<int> values, List<int> randoms) {
  final parts = <String>[];
  for (var i = 0; i < values.length; i++) {
    final random = i < randoms.length ? randoms[i] : -1;
    if (random >= 0 && random < values.length) {
      parts.add('${values[i]}→${values[random]}');
    }
  }
  return parts.isEmpty ? '全部为 null' : parts.join(', ');
}

const String sortListCode = '''class Solution {
    public ListNode sortList(ListNode head) {
        if (head == null || head.next == null) return head;
        ListNode slow = head, fast = head.next;
        while (fast != null && fast.next != null) {
            slow = slow.next;
            fast = fast.next.next;
        }
        ListNode mid = slow.next;
        slow.next = null;
        ListNode left = sortList(head);
        ListNode right = sortList(mid);
        return merge(left, right);
    }
    ListNode merge(ListNode a, ListNode b) {
        ListNode dummy = new ListNode(0);
        ListNode tail = dummy;
        while (a != null && b != null) {
            if (a.val <= b.val) {
                tail.next = a;
                a = a.next;
            } else {
                tail.next = b;
                b = b.next;
            }
            tail = tail.next;
        }
        tail.next = (a != null) ? a : b;
        return dummy.next;
    }
}''';

List<SceneFrame> sortListScript(Map<String, dynamic> input) {
  final values = intList(input['nums']);
  if (values.isEmpty) throw ArgumentError('链表不能为空');
  checkSize(values.length, 40, 'nums');
  final collector = FrameCollector();
  final scene = ListScene(collector, chain(values), sortListCode);

  scene.show('归并排序: 先递归拆分链表', line: 'if (head == null');

  String? merge(String? a, String? b) {
    String? head;
    String? tail;
    while (a != null && b != null) {
      final va = scene.valueOf(a);
      final vb = scene.valueOf(b);
      final pick = va <= vb ? a : b;
      scene.show(
        '合并: 比较 $va 与 $vb, 取 $pick',
        line: 'if (a.val <= b.val)',
        pointers: livePointers({'a': a, 'b': b}),
        highlight: {pick},
      );
      if (tail == null) {
        head = pick;
      } else {
        scene.setNext(tail, pick);
      }
      tail = pick;
      if (pick == a) {
        a = scene.nextOf(a);
      } else {
        b = scene.nextOf(b);
      }
    }
    final rest = a ?? b;
    if (rest != null) {
      if (tail == null) {
        head = rest;
      } else {
        scene.setNext(tail, rest);
      }
    } else if (tail != null) {
      scene.setNext(tail, null);
    }
    return head;
  }

  String? sort(String? head) {
    if (head == null || scene.nextOf(head) == null) return head;
    var slow = head;
    var fast = scene.nextOf(head);
    while (fast != null && scene.nextOf(fast) != null) {
      slow = scene.nextOf(slow)!;
      fast = scene.nextOf(scene.nextOf(fast)!);
    }
    final mid = scene.nextOf(slow);
    scene.setNext(slow, null);
    scene.show(
      '拆分: 左半以 ${scene.valueOf(head)} 开头, 右半以 ${mid == null ? 'null' : scene.valueOf(mid)} 开头',
      line: 'slow.next = null',
      highlight: {slow},
    );
    final left = sort(head);
    final right = sort(mid);
    final merged = merge(left, right);
    scene.show(
      '合并结果头节点 ${merged == null ? 'null' : scene.valueOf(merged)}',
      line: 'return merge(left, right)',
      visited: {?merged},
    );
    return merged;
  }

  final sorted = sort('n0');
  scene.show(
    '排序完成, 头节点 ${sorted == null ? 'null' : scene.valueOf(sorted)}',
    line: 'return merge(left, right)',
    visited: {?sorted},
  );
  return collector.build();
}

const String mergeKListsCode = '''class Solution {
    public ListNode mergeKLists(ListNode[] lists) {
        ListNode ans = null;
        for (ListNode list : lists) {
            ans = mergeTwoLists(ans, list);
        }
        return ans;
    }
    ListNode mergeTwoLists(ListNode a, ListNode b) {
        ListNode dummy = new ListNode(0);
        ListNode tail = dummy;
        while (a != null && b != null) {
            if (a.val <= b.val) {
                tail.next = a;
                a = a.next;
            } else {
                tail.next = b;
                b = b.next;
            }
            tail = tail.next;
        }
        tail.next = (a != null) ? a : b;
        return dummy.next;
    }
}''';

List<SceneFrame> mergeKListsScript(Map<String, dynamic> input) {
  final lists = intMatrix(input['lists']);
  if (lists.isEmpty) throw ArgumentError('至少需要一条链表');
  checkSize(lists.length, 20, 'lists');
  final collector = FrameCollector();
  final nodes = <ListNodeSpec>[];
  for (var i = 0; i < lists.length; i++) {
    nodes.addAll(chain(lists[i], prefix: 'l${i}_'));
  }
  final scene = ListScene(collector, nodes, mergeKListsCode);

  scene.show(
    '共 ${lists.length} 条升序链表: $lists',
    line: 'ListNode ans = null',
  );

  String? merged;
  String? mergeTwo(String? a, String? b, int round) {
    String? head;
    String? tail;
    while (a != null && b != null) {
      final va = scene.valueOf(a);
      final vb = scene.valueOf(b);
      final pick = va <= vb ? a : b;
      scene.show(
        '第 ${round + 1} 轮合并: 比较 $va 与 $vb, 取 $pick',
        line: 'if (a.val <= b.val)',
        pointers: livePointers({'a': a, 'b': b}),
        highlight: {pick},
      );
      if (tail == null) {
        head = pick;
      } else {
        scene.setNext(tail, pick);
      }
      tail = pick;
      if (pick == a) {
        a = scene.nextOf(a);
      } else {
        b = scene.nextOf(b);
      }
    }
    final rest = a ?? b;
    if (rest != null) {
      if (tail == null) {
        head = rest;
      } else {
        scene.setNext(tail, rest);
      }
    } else if (tail != null) {
      scene.setNext(tail, null);
    }
    return head;
  }

  for (var i = 0; i < lists.length; i++) {
    final head = lists[i].isEmpty ? null : 'l${i}_0';
    if (head == null) {
      scene.show('第 ${i + 1} 条链表为空, 跳过', line: 'for (ListNode list : lists)');
      continue;
    }
    merged = mergeTwo(merged, head, i);
    scene.show(
      '合并前 ${i + 1} 条链表后, 头节点为 ${merged == null ? 'null' : scene.valueOf(merged)}',
      line: 'ans = mergeTwoLists(ans, list)',
      visited: {?merged},
    );
  }

  scene.show(
    merged == null ? '全部链表为空' : 'K 条链表合并完成, 头节点 ${scene.valueOf(merged)}',
    line: 'return ans',
  );
  return collector.build();
}

const String lruCacheCode = '''class LRUCache {
    Map<Integer, Node> map;
    Node head, tail;
    int capacity;
    public LRUCache(int capacity) {
        this.capacity = capacity;
        map = new HashMap<>();
    }
    public int get(int key) {
        if (!map.containsKey(key)) return -1;
        Node node = map.get(key);
        moveToHead(node);
        return node.value;
    }
    public void put(int key, int value) {
        if (map.containsKey(key)) {
            Node node = map.get(key);
            node.value = value;
            moveToHead(node);
        } else {
            if (map.size() == capacity) {
                map.remove(tail.key);
                removeTail();
            }
            Node node = new Node(key, value);
            map.put(key, node);
            addToHead(node);
        }
    }
}''';

List<SceneFrame> lruCacheScript(Map<String, dynamic> input) {
  final capacity = intOf(input['capacity']);
  final opsText = strOf(input['ops']);
  if (capacity <= 0) throw ArgumentError('capacity 必须大于 0');
  final collector = FrameCollector();
  final nodes = <ListNodeSpec>[];
  final scene = ListScene(collector, nodes, lruCacheCode);
  final values = <int, int>{};
  final order = <int>[];
  final nodeOf = <int, ListNodeSpec>{};
  var seq = 0;

  void sync(String caption, {String? line, Set<String> highlight = const {}}) {
    for (final node in nodes) {
      node.visible = false;
    }
    for (var i = 0; i < order.length; i++) {
      final node = nodeOf[order[i]]!;
      node.visible = true;
      node.prevId = i > 0 ? nodeOf[order[i - 1]]!.id : null;
      node.nextId = i + 1 < order.length ? nodeOf[order[i + 1]]!.id : null;
    }
    scene.show(
      caption,
      line: line,
      pointers: livePointers({
        'head': order.isEmpty ? null : nodeOf[order.first]!.id,
        'tail': order.isEmpty ? null : nodeOf[order.last]!.id,
      }),
      highlight: highlight,
    );
  }

  scene.show('LRU 容量 = $capacity, 初始为空', line: 'this.capacity = capacity');

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
    if (name == 'get' && args.length == 1 && args[0] != null) {
      final key = args[0]!;
      if (!values.containsKey(key)) {
        sync('get($key) 未命中, 返回 -1', line: 'if (!map.containsKey(key)) return -1');
        continue;
      }
      order
        ..remove(key)
        ..insert(0, key);
      sync(
        'get($key) = ${values[key]}, 移到链表头部',
        line: 'moveToHead(node)',
        highlight: {nodeOf[key]!.id},
      );
    } else if (name == 'put' && args.length == 2 && args[0] != null && args[1] != null) {
      final key = args[0]!;
      final value = args[1]!;
      if (values.containsKey(key)) {
        values[key] = value;
        order
          ..remove(key)
          ..insert(0, key);
        sync(
          'put($key, $value): 已存在, 更新并移到头部',
          line: 'moveToHead(node)',
          highlight: {nodeOf[key]!.id},
        );
      } else {
        if (order.length >= capacity) {
          final evicted = order.removeLast();
          values.remove(evicted);
          sync(
            '缓存已满, 淘汰最久未使用的 key = $evicted',
            line: 'map.remove(tail.key)',
          );
        }
        values[key] = value;
        order.insert(0, key);
        if (!nodeOf.containsKey(key)) {
          final node = ListNodeSpec('k${seq++}', key);
          nodeOf[key] = node;
          nodes.add(node);
        }
        sync(
          'put($key, $value): 新建节点插入头部',
          line: 'addToHead(node)',
          highlight: {nodeOf[key]!.id},
        );
      }
    } else {
      sync('忽略无法解析的操作: ${match.group(0)}', line: 'public void put');
    }
  }

  scene.show(
    '操作结束, 缓存内容 ${values.entries.map((e) => '${e.key}:${e.value}').join(', ')}',
    line: 'public void put',
  );
  return collector.build();
}

// ===========================================================================
// 题目描述符
// ===========================================================================

List<ProblemEntry> batch3Problems() => [
      buildProblem(
        slug: 'intersection-of-two-linked-lists',
        number: 160,
        title: '相交链表',
        difficulty: ProblemDifficulty.easy,
        group: 'linked-list',
        pattern: 'linked-list',
        code: intersectionCode,
        presets: [
          preset('示例 1', {
            'listA': [4, 1, 8, 4, 5],
            'listB': [5, 6, 1, 8, 4, 5],
            'skipA': 2,
            'skipB': 3,
          }),
          preset('示例 2', {
            'listA': [1, 9, 1, 2, 4],
            'listB': [3, 2, 4],
            'skipA': 3,
            'skipB': 1,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('listA', maxLength: 60),
          InputField.array('listB', maxLength: 60),
          InputField.int('skipA', minValue: 0, maxValue: 59),
          InputField.int('skipB', minValue: 0, maxValue: 59),
        ]),
        script: intersectionScript,
      ),
      buildProblem(
        slug: 'reverse-linked-list',
        number: 206,
        title: '反转链表',
        difficulty: ProblemDifficulty.easy,
        group: 'linked-list',
        pattern: 'linked-list',
        code: reverseListCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3, 4, 5],
          }),
          preset('示例 2', {
            'nums': [1, 2],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 60)]),
        script: reverseListScript,
      ),
      buildProblem(
        slug: 'palindrome-linked-list',
        number: 234,
        title: '回文链表',
        difficulty: ProblemDifficulty.easy,
        group: 'linked-list',
        pattern: 'linked-list',
        code: palindromeCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 2, 1],
          }),
          preset('示例 2', {
            'nums': [1, 2],
          }),
          preset('示例 3', {
            'nums': [1, 2, 3, 2, 1],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 60)]),
        script: palindromeScript,
      ),
      buildProblem(
        slug: 'linked-list-cycle',
        number: 141,
        title: '环形链表',
        difficulty: ProblemDifficulty.easy,
        group: 'linked-list',
        pattern: 'linked-list',
        code: hasCycleCode,
        presets: [
          preset('示例 1', {
            'nums': [3, 2, 0, -4],
            'pos': 1,
          }),
          preset('示例 2', {
            'nums': [1, 2],
            'pos': 0,
          }),
          preset('示例 3', {
            'nums': [1],
            'pos': -1,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 60),
          InputField.int('pos', minValue: -1, maxValue: 59),
        ]),
        script: hasCycleScript,
      ),
      buildProblem(
        slug: 'linked-list-cycle-ii',
        number: 142,
        title: '环形链表 II',
        difficulty: ProblemDifficulty.medium,
        group: 'linked-list',
        pattern: 'linked-list',
        code: cycleEntryCode,
        presets: [
          preset('示例 1', {
            'nums': [3, 2, 0, -4],
            'pos': 1,
          }),
          preset('示例 2', {
            'nums': [1, 2],
            'pos': 0,
          }),
          preset('示例 3', {
            'nums': [1],
            'pos': -1,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 60),
          InputField.int('pos', minValue: -1, maxValue: 59),
        ]),
        script: cycleEntryScript,
      ),
      buildProblem(
        slug: 'merge-two-sorted-lists',
        number: 21,
        title: '合并两个有序链表',
        difficulty: ProblemDifficulty.easy,
        group: 'linked-list',
        pattern: 'linked-list',
        code: mergeTwoListsCode,
        presets: [
          preset('示例 1', {
            'l1': [1, 2, 4],
            'l2': [1, 3, 4],
          }),
          preset('示例 2', {
            'l1': [],
            'l2': [0],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('l1', maxLength: 60),
          InputField.array('l2', maxLength: 60),
        ]),
        script: mergeTwoListsScript,
      ),
      buildProblem(
        slug: 'add-two-numbers',
        number: 2,
        title: '两数相加',
        difficulty: ProblemDifficulty.medium,
        group: 'linked-list',
        pattern: 'linked-list',
        code: addTwoNumbersCode,
        presets: [
          preset('示例 1', {
            'l1': [2, 4, 3],
            'l2': [5, 6, 4],
          }),
          preset('示例 2', {
            'l1': [0],
            'l2': [0],
          }),
          preset('示例 3', {
            'l1': [9, 9, 9, 9],
            'l2': [9, 9],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('l1', maxLength: 60),
          InputField.array('l2', maxLength: 60),
        ]),
        script: addTwoNumbersScript,
      ),
      buildProblem(
        slug: 'remove-nth-node-from-end-of-list',
        number: 19,
        title: '删除链表的倒数第 N 个结点',
        difficulty: ProblemDifficulty.medium,
        group: 'linked-list',
        pattern: 'linked-list',
        code: removeNthCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3, 4, 5],
            'n': 2,
          }),
          preset('示例 2', {
            'nums': [1],
            'n': 1,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 60),
          InputField.int('n', minValue: 1, maxValue: 60),
        ]),
        script: removeNthScript,
      ),
      buildProblem(
        slug: 'swap-nodes-in-pairs',
        number: 24,
        title: '两两交换链表中的节点',
        difficulty: ProblemDifficulty.medium,
        group: 'linked-list',
        pattern: 'linked-list',
        code: swapPairsCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3, 4],
          }),
          preset('示例 2', {
            'nums': [1],
          }),
          preset('示例 3', {
            'nums': [1, 2, 3],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 60)]),
        script: swapPairsScript,
      ),
      buildProblem(
        slug: 'reverse-nodes-in-k-group',
        number: 25,
        title: 'K 个一组翻转链表',
        difficulty: ProblemDifficulty.hard,
        group: 'linked-list',
        pattern: 'linked-list',
        code: reverseKGroupCode,
        presets: [
          preset('示例 1', {
            'nums': [1, 2, 3, 4, 5],
            'k': 2,
          }),
          preset('示例 2', {
            'nums': [1, 2, 3, 4, 5],
            'k': 3,
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('nums', maxLength: 60),
          InputField.int('k', minValue: 1, maxValue: 20),
        ]),
        script: reverseKGroupScript,
      ),
      buildProblem(
        slug: 'copy-list-with-random-pointer',
        number: 138,
        title: '随机链表的复制',
        difficulty: ProblemDifficulty.medium,
        group: 'linked-list',
        pattern: 'linked-list',
        code: copyRandomListCode,
        presets: [
          preset('示例 1', {
            'values': [7, 13, 11, 10, 1],
            'random': [-1, 0, 4, 2, 0],
          }),
          preset('示例 2', {
            'values': [1, 2],
            'random': [1, 1],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.array('values', maxLength: 60),
          InputField.array('random', maxLength: 60),
        ]),
        script: copyRandomListScript,
      ),
      buildProblem(
        slug: 'sort-list',
        number: 148,
        title: '排序链表',
        difficulty: ProblemDifficulty.medium,
        group: 'linked-list',
        pattern: 'linked-list',
        code: sortListCode,
        presets: [
          preset('示例 1', {
            'nums': [4, 2, 1, 3],
          }),
          preset('示例 2', {
            'nums': [-1, 5, 3, 4, 0],
          }),
        ],
        schema: InputSchema(fields: [InputField.array('nums', maxLength: 40)]),
        script: sortListScript,
        maxInputSize: 40,
      ),
      buildProblem(
        slug: 'merge-k-sorted-lists',
        number: 23,
        title: '合并 K 个升序链表',
        difficulty: ProblemDifficulty.hard,
        group: 'linked-list',
        pattern: 'linked-list',
        code: mergeKListsCode,
        presets: [
          preset('示例 1', {
            'lists': [
              [1, 4, 5],
              [1, 3, 4],
              [2, 6],
            ],
          }),
          preset('示例 2', {
            'lists': [<int>[]],
          }),
        ],
        schema: InputSchema(fields: [
          InputField.matrix('lists', maxRows: 20, maxCols: 40),
        ]),
        script: mergeKListsScript,
        maxInputSize: 20,
      ),
      buildProblem(
        slug: 'lru-cache',
        number: 146,
        title: 'LRU 缓存',
        difficulty: ProblemDifficulty.medium,
        group: 'linked-list',
        pattern: 'linked-list',
        code: lruCacheCode,
        presets: [
          preset('示例 1', {
            'capacity': 2,
            'ops': 'put(1,1) put(2,2) get(1) put(3,3) get(2) put(4,4) get(1) get(3) get(4)',
          }),
          preset('示例 2', {
            'capacity': 1,
            'ops': 'put(1,1) get(1) put(2,2) get(1) get(2)',
          }),
        ],
        schema: InputSchema(fields: [
          InputField.int('capacity', minValue: 1, maxValue: 20),
          InputField.string('ops', maxLength: 300),
        ]),
        script: lruCacheScript,
        maxFrames: 3000,
      ),
    ];
