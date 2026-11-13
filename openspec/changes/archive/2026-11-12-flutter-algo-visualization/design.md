# Design

## Context

全新 Flutter 项目，无现有代码或 OpenSpec 规范。项目结构已在 `openspec/config.yaml` 中初始化为 spec-driven schema。所有设计决策均以 Proposal 中列出的三个 Capability 为边界。

## Goals / Non-Goals

**Goals:**
- 建立算法执行过程的通用快照模型 (SceneFrame / Element / Action)，让任意算法都能映射为可视化帧序列
- 实现支持 play/pause/step/speed/seek/loop 的帧播放控制器
- 用 Widget 组合式渲染管线消费帧数据，简单场景无需 CustomPaint
- 定义 AlgorithmVisualizer 统一接口，让新增算法变成"实现接口 + 注册"
- UI 层同时展示代码（逐行高亮）和可视化区，形成学习闭环
- 每个算法声明输入上限 (maxInputSize) 和输入描述 (InputSchema)，框架据此自动校验

**Non-Goals:**
- 不做完整的 LeetCode 题库同步（仅预置精选用例，未来可加）
- 不做用户账号 / 云同步 / 进度追踪
- 不做 Web 或桌面端（MVP 仅 iOS + Android）
- 不做通用代码解释器（SceneFrame 里的 currentLine 由算法实现者手动标记）
- 不做自动生成动画的 AI 能力

## Decisions

### 1. 帧模型：快照 (Snapshot) 而非增量 (Delta)

**选择**: 每帧包含完整的 `List<Element>` 副本 + `List<Action>` 差异描述。渲染层拿到一帧即可独立绘制，回放 / seek / loop 都是 O(1) 索引。

**理由**: LeetCode 算法可视化的帧数量可控（冒泡排序 n=50 约 1225 帧，内存 < 1MB），快照模型带来的渲染层简洁性远大于内存开销。

**备选方案**: Delta 增量模型（每帧只存变化部分），省内存但渲染层需状态累积，seek/loop 需重放，复杂度显著升高。

### 2. 渲染管线：Widget 组合优先，CustomPaint 做复杂场景

**选择**:
- ArrayBar、DpCell 表格 → 标准 Flutter Widget（Container + 约束布局），天然支持 hitTest 和手势
- TreeNode / GraphNode 连线 → CustomPaint（Widget 难以高效画贝塞尔曲线）
- SceneRenderer 统一接收 SceneFrame，根据 Element 类型分发到对应 Widget 或 CustomPainter

**备选方案**: 全 CustomPaint，性能好但交互（点击高亮某个节点）需要手动 hitTest，开发成本高。

### 3. 帧生成时机：一次性全部生成

**选择**: `AlgorithmVisualizer.visualize(input)` 同步返回完整 `List<SceneFrame>`。PlaybackController 用 `currentIndex` + `frames` 管理播放。

**理由**: maxInputSize 已经限制了输入规模（最多几百帧，生成毫秒级），一次性生成让所有播放操作（seek 到任意帧、loop、step back）都是 O(1)。

**备选方案**: 边播放边生成（Generator / Stream），理论上首帧更快，但 seek/loop 需要从头重放增量，复杂度高。

### 4. 算法接口统一为 AlgorithmVisualizer

```
AlgorithmVisualizer {
  name: String           // "冒泡排序"
  category: String       // "sorting"
  description: String    // 简要说明
  inputSchema: InputSchema   // 告诉 UI 需要什么输入字段
  maxInputSize: int      // 输入上限, 框架强制校验
  visualize(Map<String, dynamic> input): List<SceneFrame>
}
```

**理由**: 动态类型输入（不同算法类型不同）在 Dart 中无法用泛型优雅表达（List<int> vs TreeNode vs Map）。用 `Map<String, dynamic>` + InputSchema 描述输入结构，UI 层自动渲染输入表单和校验。

**备选方案**: 每种算法一个独立 Widget + 独立输入页面，灵活但重复代码多，扩展性差。

### 5. UI 布局：上下分屏，代码逐行同步高亮

**选择**: 可视化区域在上（占屏 ~50%），代码区域在下，播放控制器在底部。SceneFrame 携带 `currentLine` (int?) 和 `activeLines` (List<int>?) 字段，代码 Widget 据此同步高亮。

**理由**: 刷题者同时看到算法执行过程和对应代码，理解成本最低。Tab 切换方案虽然实现简单，但切换会打断学习流。

**备选方案**: Tab 切换（移动端简单但不能同时看）、左右分屏（Pad 友好但手机空间不够）。

### 6. 架构分层隔离

```
algorithms/  ──import──▶  core/scene/     (数据模型)
                                 │
                                 ▼
                          core/playback/  (播放控制)
                                 │
                                 ▼
                          core/visualization/ (渲染)
                                 │
                                 ▼
                              ui/         (Flutter Widget)
```

**关键约束**:
- algorithms/ 层**不得** import Flutter SDK —— 纯 Dart，可脱离 Flutter 运行单测
- algorithms/ 层只 import core/scene/ 里的数据模型，不 import 任何渲染或播放代码
- 渲染层不感知算法名称，只消费 Element + Action

### 7. 状态管理：MVP 用 ValueNotifier + StatefulWidget

**选择**: 不引入 Riverpod / Bloc 等状态管理库。PlaybackController 继承 ValueNotifier，状态变化通过 ValueListenableBuilder 响应式更新 UI。

**理由**: MVP 阶段组件数少（首页 / 列表页 / 播放页），跨页面状态需求低。引入状态管理库增加学习成本和复杂度。当页面数 > 10 或出现复杂共享状态时再考虑升级。

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| SceneFrame 全量快照在超大数据量下内存暴涨 | maxInputSize 每种算法自行声明 + 框架校验，杜绝超限输入 |
| AlgorithmVisualizer.visualize() 在主线程执行可能卡顿 | MVP 先接受（数据量小），加超时保护；真卡了再迁移到后台 Isolate |
| CustomPaint 与 Widget 混用导致坐标系不一致 | SceneRenderer 统一计算布局后一次性传给渲染组件，内部自行管理坐标 |
| 每种算法手动标记 currentLine 容易漏标 | 在 AlgorithmVisualizer 基类提供 helper 方法 `frame(line, caption, elements, actions)` 强制每次生成帧时传入行号 |
| ArrayBar Widget rebuild 频率过高（每一帧都重建 ArrayBar 列表） | 给 ArrayBar widget 加 const 构造 + key，利用 Flutter widget diff 机制减少实际重绘 |

## Open Questions

- None — 所有影响 specs、design、tasks 的决策已在此处确认。

推迟决策（不影响当前 scope）:
- 是否支持导出帧序列为 GIF / MP4
- 是否支持暗色主题
- 哪些算法做第二批（DFS/BFS/01背包 vs 更多排序）
