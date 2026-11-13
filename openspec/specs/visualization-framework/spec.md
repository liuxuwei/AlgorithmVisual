# visualization-framework Specification

## Purpose

提供通用的算法可视化引擎 —— 用快照帧模型 (SceneFrame / Element / Action) 捕获算法执行的每一步，通过 PlaybackController 提供帧序列播放控制，让任意算法都能通过标准接口接入可视化，而无需关心具体渲染技术。

## Requirements

### Requirement: SceneFrame 快照模型

系统 SHALL 用 SceneFrame 捕获算法执行的每一个可视化状态。每个 SceneFrame MUST 包含唯一 frameId、当前帧的 caption 文字说明、完整的 List<Element>、以及 List<Action>（当前帧相对于上一帧的差异描述）。SceneFrame SHALL 支持可选的 currentLine（当前执行代码行号）和 activeLines（同时高亮的代码行列表）字段。

#### Scenario: SceneFrame 完整字段

- **GIVEN** 一个冒泡排序可视化场景
- **WHEN** 算法执行到第 3 帧
- **THEN** SceneFrame.frameId == 3，caption 描述当前交换的内容，elements 包含所有 ArrayBar 的完整状态，actions 标记了哪两个元素被交换，currentLine 指向对应的 swap 代码行

#### Scenario: 无代码行号的场景

- **GIVEN** 一个还没有标记代码行号的算法
- **WHEN** 生成 SceneFrame
- **THEN** currentLine 和 activeLines 均为 null，不影响可视化渲染

### Requirement: Element 类型覆盖

系统 SHALL 支持四种可渲染 Element 类型：ArrayBar（数组元素，用于排序等）、TreeNode（树节点，用于 DFS/BFS 等）、GraphNode（图节点 + 边）、DpCell（动态规划表格格子）。每种 Element MUST 有唯一 id 和 position 坐标。

#### Scenario: ArrayBar 渲染

- **WHEN** SceneFrame 中包含 List<ArrayBar>
- **THEN** 渲染层能正确绘制每个矩形条，高度映射元素值，宽度均匀分布

#### Scenario: 元素唯一标识

- **GIVEN** 同一帧中有多个 Element
- **WHEN** 渲染层需要高亮某个特定元素
- **THEN** 通过 Element.id 能唯一定位，不与其他元素混淆

### Requirement: Action 描述帧间差异

系统 SHALL 支持 Highlight（高亮）、Swap（交换位置）、Insert（新元素入场）、Remove（元素退场）、Mark（标记访问）五种 Action 类型。每种 Action MUST 有 targetId 指向受影响的 Element。

#### Scenario: Swap 动作

- **WHEN** 冒泡排序交换 arr[1] 和 arr[2]
- **THEN** SceneFrame.actions 包含 Swap Action，targetId 为两个 ArrayBar 的 id，渲染层据此在视觉上交换它们的位置或添加过渡动画

#### Scenario: Mark 动作标记 DFS 已访问节点

- **WHEN** DFS 遍历访问了节点 B
- **THEN** SceneFrame.actions 包含 Mark Action，targetId 为 TreeNode B 的 id，Mark 内容标记为 "visited"，渲染层将节点颜色变深

### Requirement: PlaybackController 播放控制

系统 SHALL 提供 PlaybackController 管理帧序列播放，支持 play（自动按 speed 推进）、pause（暂停在当前帧）、step forward（前进一帧）、step backward（后退一帧）、seek（跳到指定帧号）、loop（播放到末尾后从头开始）。PlaybackController MUST 监听当前帧的变化并通知监听者。

#### Scenario: 正常播放

- **GIVEN** 一个包含 42 帧的 SceneFrame 列表
- **WHEN** 用户点击播放按钮
- **THEN** 当前帧从 index 0 开始，按 speed 间隔依次推进，渲染层每帧更新

#### Scenario: 暂停后继续

- **GIVEN** 正在播放，当前帧停在 index 15
- **WHEN** 用户点击暂停
- **THEN** 当前帧固定在 index 15，不再推进
- **WHEN** 用户再次点击播放
- **THEN** 从 index 15 继续推进

#### Scenario: Seek 跳帧

- **GIVEN** 当前帧在 index 5
- **WHEN** 用户拖动进度条到 index 30
- **THEN** 立即跳转到 index 30 的 SceneFrame，无需重放中间帧

#### Scenario: Loop 循环

- **GIVEN** 循环模式开启，当前帧即将到达最后一帧 (index 41)
- **WHEN** 最后一帧播放完毕
- **THEN** 自动回到 index 0 重新开始

#### Scenario: 播放速度控制

- **GIVEN** speed 设为 2.0x
- **WHEN** 播放过程中
- **THEN** 帧间隔是默认速度的一半

#### Scenario: Step backward 不越界

- **GIVEN** 当前帧在 index 0
- **WHEN** 用户点击 step backward
- **THEN** 不做任何操作，保持在 index 0

### Requirement: 帧一次性生成

算法可视化器 SHALL 同步返回完整的 List<SceneFrame>，PlaybackController 在初始化时接收完整帧序列。系统 SHALL NOT 用流式或懒加载方式按需生成帧。

#### Scenario: 初始化时所有帧就绪

- **GIVEN** 算法已执行完毕
- **WHEN** PlaybackController 创建
- **THEN** 所有 SceneFrame 已在内存中，seek 到任意帧都是 O(1)

### Requirement: Widget 组合式渲染管线

渲染层 SHALL 优先使用 Flutter Widget 组合消费 SceneFrame 数据。ArrayBar 和 DpCell 使用 Widget 直接渲染；TreeNode 和 GraphNode 的连线使用 CustomPaint 绘制，节点本身仍为 Widget。SceneRenderer SHALL 根据 Element 类型自动分发到对应渲染器。

#### Scenario: ArrayBar 无需 CustomPaint

- **WHEN** SceneFrame 包含 List<ArrayBar>
- **THEN** SceneRenderer 用 Row 包裹 Container 渲染每个 ArrayBar，每个 Container 的高度映射到元素值，不使用 CustomPainter

#### Scenario: 混合渲染节点和连线

- **WHEN** SceneFrame 包含 TreeNode 及其边
- **THEN** TreeNode 用 Widget（Container + CircleBorder）渲染，连线用 CustomPaint 画贝塞尔曲线，两者叠加在 Stack 中
