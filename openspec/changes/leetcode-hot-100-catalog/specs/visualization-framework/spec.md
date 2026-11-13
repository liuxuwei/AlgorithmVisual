# Spec Delta

## MODIFIED Requirements

### Requirement: Element 类型覆盖

系统 SHALL 支持以下可渲染 Element 类型：ArrayBar（数组元素）、TreeNode（树节点）、GraphNode（图节点 + 边）、DpCell（动态规划表格格子）、LinkedListNode（链表节点，含前后指针关系）、MatrixCell（矩阵/网格格子，含行列与状态）、StackFrame（栈/队列条目）、HashEntry（哈希桶键值对）、PointerMarker（指针/游标标注，指向某个元素）。每种 Element MUST 有唯一 id 和 position 坐标。

#### Scenario: ArrayBar 渲染

- **WHEN** SceneFrame 中包含 List<ArrayBar>
- **THEN** 渲染层能正确绘制每个矩形条，高度映射元素值，宽度均匀分布

#### Scenario: 元素唯一标识

- **GIVEN** 同一帧中有多个 Element
- **WHEN** 渲染层需要高亮某个特定元素
- **THEN** 通过 Element.id 能唯一定位，不与其他元素混淆

#### Scenario: 链表节点渲染

- **WHEN** SceneFrame 中包含 List<LinkedListNode> 且相邻节点有 next 关系
- **THEN** 渲染层按顺序绘制节点并以箭头连接，节点内展示当前值

#### Scenario: 矩阵格子渲染

- **WHEN** SceneFrame 中包含 List<MatrixCell>
- **THEN** 渲染层按 row/col 排布为二维网格，格子内展示值，并按状态着色

#### Scenario: 指针标注指向元素

- **GIVEN** 某一帧包含 PointerMarker，其 targetId 指向数组中的某个 ArrayBar
- **WHEN** 渲染该帧
- **THEN** 渲染层在该元素附近显示指针标签，标签内容由 PointerMarker 提供

### Requirement: Action 描述帧间差异

系统 SHALL 支持 Highlight（高亮）、Swap（交换位置）、Insert（新元素入场）、Remove（元素退场）、Mark（标记访问）、Pointer（指针移动到目标元素）、Range（区间/窗口标注）七种 Action 类型。每种 Action MUST 有 targetId 指向受影响的 Element，Pointer 与 Range MUST 携带用于展示的标签文本。

#### Scenario: Swap 动作

- **WHEN** 冒泡排序交换 arr[1] 和 arr[2]
- **THEN** SceneFrame.actions 包含 Swap Action，targetId 为两个 ArrayBar 的 id，渲染层据此在视觉上交换它们的位置或添加过渡动画

#### Scenario: Mark 动作标记 DFS 已访问节点

- **WHEN** DFS 遍历访问了节点 B
- **THEN** SceneFrame.actions 包含 Mark Action，targetId 为 TreeNode B 的 id，Mark 内容标记为 "visited"，渲染层将节点颜色变深

#### Scenario: Pointer 动作标注双指针

- **WHEN** 双指针算法将左指针移动到下标 3
- **THEN** SceneFrame.actions 包含 Pointer Action，标签为 "left"，渲染层在对应元素处显示该指针

#### Scenario: Range 动作标注滑动窗口

- **WHEN** 滑动窗口区间由 [1,3] 扩展为 [1,4]
- **THEN** SceneFrame.actions 包含 Range Action，携带区间标签，渲染层高亮该区间覆盖的元素

### Requirement: Widget 组合式渲染管线

渲染层 SHALL 优先使用 Flutter Widget 组合消费 SceneFrame 数据。ArrayBar、DpCell、MatrixCell、StackFrame、HashEntry 使用 Widget 直接渲染；TreeNode、GraphNode、LinkedListNode 的连线使用 CustomPaint 绘制，节点本身仍为 Widget。SceneRenderer SHALL 根据 Element 类型自动分发到对应渲染器。

#### Scenario: ArrayBar 无需 CustomPaint

- **WHEN** SceneFrame 包含 List<ArrayBar>
- **THEN** SceneRenderer 用 Row 包裹 Container 渲染每个 ArrayBar，每个 Container 的高度映射到元素值，不使用 CustomPainter

#### Scenario: 混合渲染节点和连线

- **WHEN** SceneFrame 包含 TreeNode 及其边
- **THEN** TreeNode 用 Widget（Container + CircleBorder）渲染，连线用 CustomPaint 画贝塞尔曲线，两者叠加在 Stack 中

#### Scenario: 链表节点与箭头分层渲染

- **WHEN** SceneFrame 包含 LinkedListNode
- **THEN** 节点用 Widget 渲染，节点之间的箭头与空指针标记用 CustomPaint 绘制，并随节点位置变化更新

## ADDED Requirements

### Requirement: 帧行号与题目本地代码同源

系统 SHALL 保证每道题的 SceneFrame.currentLine 指向该题本地维护的题解代码行号。题解代码 MUST 与步骤脚本同源维护，MUST NOT 依赖网络获取的题解文本。

#### Scenario: 行号与本地代码对齐

- **GIVEN** 某题本地题解代码中交换逻辑位于第 12 行
- **WHEN** 该题某帧执行交换操作并设置 currentLine=12
- **THEN** 代码区域高亮第 12 行，且该行内容确为交换逻辑

#### Scenario: 网络题解变更不影响高亮

- **GIVEN** 题目题面已从网络刷新
- **WHEN** 用户查看该题可视化
- **THEN** 使用本地题解代码，行号高亮保持正确
