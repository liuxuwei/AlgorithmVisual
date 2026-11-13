# Proposal

## Why

刷题者学算法时常面临"看懂代码但没感觉"的鸿沟。LeetCode 高频算法（排序、图论、动态规划等）的执行过程是抽象的，学习者需要把一行行代码和数据结构的实际变化对应起来才能建立直觉。目前没有一款移动端 App 能用同一套框架覆盖多种算法的可视化，导致每种算法的演示都是定制实现、维护成本高、扩展性差。

本 change 要构建一套**通用可视化框架 + 算法库**，用 Flutter 开发移动端 App。框架先行，后续添加新算法只需实现一个标准接口（输入 → SceneFrame 序列），无需改动渲染层或播放逻辑。

## What Changes

- 新建 Flutter 项目骨架（iOS + Android 双端）
- 定义 SceneFrame / Element / Action 数据模型（核心抽象）
- 实现 PlaybackController 播放控制器（play/pause/step/speed/seek/loop）
- 实现 Widget 组合式渲染层（ArrayBar、TreeView、GraphView、DpGrid 四种 Element 渲染）
- 定义 AlgorithmVisualizer 接口和 InputSchema 输入描述
- 实现首批算法可视化：冒泡排序、快速排序（验证 ArrayBar 管线）
- 实现 Flutter UI：首页分类列表、算法详情页、可视化播放页（代码区与可视化区上下分屏 + 逐行同步高亮）
- 预置典型输入用例 + 自定义输入表单（InputSchema 驱动自动校验）

## Capabilities

### New Capabilities

- `visualization-framework`: 核心可视化引擎 —— SceneFrame/Element/Action 数据模型快照、PlaybackController 帧序列播放控制、Widget 组合式渲染管线
- `algorithm-library`: 算法可视化器注册与发现 —— AlgorithmVisualizer 统一接口、按 category 分组的 Registry、每种算法声明 maxInputSize 和 InputSchema
- `flutter-ui`: 移动端 UI —— 算法分类首页、题目列表、可视化播放页（代码与可视化双区同步）、预置/自定义输入选择

### Modified Capabilities

（无，这是全新项目）

## Impact

- **新建项目**: Flutter SDK 3.x 项目，pubspec.yaml 配置依赖
- **数据模型**: 核心 Dart 类（纯数据，可脱离 Flutter 单独测试）
- **UI 组件**: Flutter Widget 树，不引入外部状态管理库（MVP 阶段用 StatefulWidget + ValueNotifier）
- **无后端**: MVP 阶段所有数据（算法描述、用例）本地 JSON 管理
- **无破坏性变更**: 全新项目，不存在现有用户
