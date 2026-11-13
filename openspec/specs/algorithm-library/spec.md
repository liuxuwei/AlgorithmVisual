# algorithm-library Specification

## Purpose

定义算法可视化器的统一接口和发现机制。每种算法实现 AlgorithmVisualizer 接口，声明自身元数据、输入约束和输入描述，通过 Registry 按 category 分组暴露给 UI 层。框架据此自动校验输入规模、生成输入表单、调用 visualize 方法产出 SceneFrame 序列。

## Requirements

### Requirement: AlgorithmVisualizer 统一接口

每种算法可视化器 SHALL 实现 AlgorithmVisualizer 接口，提供 name（算法中文名）、category（分类）、description（简要说明）、maxInputSize（输入规模上限）、inputSchema（输入字段描述），以及 visualize(Map<String, dynamic> input) 返回 List<SceneFrame>。接口实现 MUST 不依赖 Flutter SDK，仅引用 scene 数据模型。

#### Scenario: 冒泡排序实现接口

- **GIVEN** BubbleSortVisualizer 实现 AlgorithmVisualizer
- **THEN** 它声明 name="冒泡排序"、category="sorting"、maxInputSize=50、inputSchema 包含一个数组类型的输入字段

#### Scenario: 接口不依赖 Flutter

- **WHEN** 为 BubbleSortVisualizer 写纯 Dart 单测
- **THEN** 不需要引入 Flutter 的 flutter_test 依赖，visualize 方法可以直接在 Dart VM 中运行

### Requirement: maxInputSize 输入上限校验

每种算法 SHALL 声明 maxInputSize。系统 MUST 在调用 visualize 前校验输入规模，超过上限时拒绝执行并返回错误提示。

#### Scenario: 超过 maxInputSize 拒绝执行

- **GIVEN** BubbleSortVisualizer 的 maxInputSize 为 50
- **WHEN** 用户输入长度为 51 的数组
- **THEN** visualize 方法抛出 ArgumentError 或返回空列表，UI 层显示输入超限提示

#### Scenario: 不同算法声明不同上限

- **WHEN** 分别查询 BubbleSortVisualizer 和 DfsTraversalVisualizer 的 maxInputSize
- **THEN** 冒泡排序（O(n²)）声明较小上限（50），DFS 遍历树节点可声明较大上限（30）

### Requirement: InputSchema 输入描述

每种算法 SHALL 通过 InputSchema 描述 visualize 所需的输入字段。InputSchema MUST 列出所有必要字段的类型和约束（如数组最大长度、整数值范围），供 UI 层自动生成输入表单和校验。

#### Scenario: UI 根据 InputSchema 生成输入表单

- **GIVEN** BubbleSortVisualizer 的 InputSchema 描述一个数组字段 arr
- **WHEN** UI 层渲染输入界面
- **THEN** 渲染一个文本输入框，提示用户用逗号分隔输入数字，校验总数不超过 maxInputSize

#### Scenario: 背包问题多字段输入

- **GIVEN** Knapsack01Visualizer 需要 weights、values、capacity 三个字段
- **WHEN** UI 层根据 InputSchema 渲染
- **THEN** 依次展示三个输入控件，每个有自己的校验规则

### Requirement: AlgorithmRegistry 按 category 分组

系统 SHALL 提供 AlgorithmRegistry 管理所有 AlgorithmVisualizer 实例。Registry MUST 支持按 category 查询算法列表、查询单个算法、列出所有 category。category 分组 MUST 覆盖至少 sorting、tree、graph、dp 四种。

#### Scenario: 按分类列出算法

- **WHEN** UI 层请求 category="sorting" 的所有算法
- **THEN** Registry 返回 BubbleSortVisualizer 和 QuickSortVisualizer 等注册在 sorting 分类下的实例列表

#### Scenario: 查询所有分类

- **WHEN** UI 层请求所有 category
- **THEN** 返回 ["sorting", "tree", "graph", "dp"]（仅包含已注册算法所属的 category）

#### Scenario: 新增算法注册

- **GIVEN** 新写了一个 MergeSortVisualizer
- **WHEN** 在 Registry 中注册它
- **THEN** category="sorting" 的查询结果自动包含 MergeSortVisualizer

### Requirement: 算法实现层与渲染层隔离

AlgorithmVisualizer 实现 SHALL 只 import scene 数据模型，MUST NOT import Flutter Widget、PlaybackController 或任何渲染层代码。算法实现的 visualize 方法仅负责：接收输入 → 维护内部算法状态 → 将每一步状态打包成 SceneFrame。

#### Scenario: 算法层代码不含 Flutter import

- **WHEN** 检查 algorithms/ 目录下的 dart 文件
- **THEN** 没有任何 import 'package:flutter/...' 或 import 'package:flutter_test/...' 语句

#### Scenario: 帧生成只依赖数据模型

- **WHEN** visualize 方法被调用
- **THEN** 返回的 SceneFrame 完全由 Element 和 Action 数据结构组成，不包含任何 Widget 或渲染相关对象
