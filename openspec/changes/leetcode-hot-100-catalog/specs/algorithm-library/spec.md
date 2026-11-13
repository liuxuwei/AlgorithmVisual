# Spec Delta

## MODIFIED Requirements

### Requirement: AlgorithmVisualizer 统一接口

每种算法可视化器 SHALL 实现 AlgorithmVisualizer 接口，提供稳定 id（与题目 titleSlug 关联）、name（算法中文名）、category（分类）、description（简要说明）、maxInputSize（输入规模上限）、inputSchema（输入字段描述），以及 visualize(Map<String, dynamic> input) 返回 List<SceneFrame>。接口实现 MUST 不依赖 Flutter SDK，仅引用 scene 数据模型。

#### Scenario: 冒泡排序实现接口

- **GIVEN** BubbleSortVisualizer 实现 AlgorithmVisualizer
- **THEN** 它声明稳定 id、name="冒泡排序"、category="sorting"、maxInputSize=50、inputSchema 包含一个数组类型的输入字段

#### Scenario: 接口不依赖 Flutter

- **WHEN** 为 BubbleSortVisualizer 写纯 Dart 单测
- **THEN** 不需要引入 Flutter 的 flutter_test 依赖，visualize 方法可以直接在 Dart VM 中运行

#### Scenario: 按稳定 id 查询可视化器

- **GIVEN** 题目 "two-sum" 关联了两数之和的可视化器
- **WHEN** 系统按稳定 id "two-sum" 查询
- **THEN** 返回该题对应的可视化器，不依赖中文名称匹配

### Requirement: InputSchema 输入描述

每种算法 SHALL 通过 InputSchema 描述 visualize 所需的输入字段。InputSchema MUST 支持数组、整数、字符串、矩阵四种字段类型以及多字段组合，列出字段的必要约束（如数组最大长度、整数值范围、矩阵行列上限），供 UI 层自动生成输入表单和校验。

#### Scenario: UI 根据 InputSchema 生成输入表单

- **GIVEN** BubbleSortVisualizer 的 InputSchema 描述一个数组字段 arr
- **WHEN** UI 层渲染输入界面
- **THEN** 渲染一个文本输入框，提示用户用逗号分隔输入数字，校验总数不超过 maxInputSize

#### Scenario: 背包问题多字段输入

- **GIVEN** Knapsack01Visualizer 需要 weights、values、capacity 三个字段
- **WHEN** UI 层根据 InputSchema 渲染
- **THEN** 依次展示三个输入控件，每个有自己的校验规则

#### Scenario: 矩阵与字符串字段输入

- **GIVEN** 某道题的 InputSchema 声明一个矩阵字段 grid 和一个字符串字段 word
- **WHEN** UI 层根据 InputSchema 渲染自定义输入
- **THEN** 展示矩阵输入控件（按行输入、行内逗号分隔）和字符串输入控件，并各自执行行列上限与长度校验

### Requirement: AlgorithmRegistry 按 category 分组

系统 SHALL 提供 AlgorithmRegistry 管理所有 AlgorithmVisualizer 实例、题型渲染器与每题步骤脚本。Registry MUST 支持按 titleSlug 查询题目可视化、按 category 查询算法列表、查询单个算法、列出所有 category。category 分组 MUST 覆盖至少 sorting、tree、graph、dp 以及热题 100 的 17 个专题分组。

#### Scenario: 按分类列出算法

- **WHEN** UI 层请求 category="sorting" 的所有算法
- **THEN** Registry 返回 BubbleSortVisualizer 和 QuickSortVisualizer 等注册在 sorting 分类下的实例列表

#### Scenario: 查询所有分类

- **WHEN** UI 层请求所有 category
- **THEN** 返回已注册算法与专题所属的 category（如 sorting、tree、哈希、双指针、链表、二叉树、动态规划等）

#### Scenario: 新增算法注册

- **GIVEN** 新写了一个 MergeSortVisualizer
- **WHEN** 在 Registry 中注册它
- **THEN** category="sorting" 的查询结果自动包含 MergeSortVisualizer

#### Scenario: 按 titleSlug 查询题目

- **GIVEN** 热题 100 中某题 titleSlug 为 "reverse-linked-list"
- **WHEN** UI 层请求该题的可视化描述符
- **THEN** Registry 返回该题的步骤脚本、题型渲染器标识、代码与预置输入

## ADDED Requirements

### Requirement: 题型渲染器注册

系统 SHALL 为每种可视化题型提供独立渲染器，覆盖数组、双指针、滑动窗口、前缀和、二分查找、哈希表、矩阵/网格、链表、二叉树、回溯、栈、堆、一维动态规划、二维动态规划等题型。每个题型渲染器 MUST 声明唯一的题型标识，供题目描述符引用。

#### Scenario: 题目引用题型渲染器

- **GIVEN** 题目 "merge-two-sorted-lists" 的题型标识为 "linked-list"
- **WHEN** 渲染该题的第 0 帧
- **THEN** 系统按 "linked-list" 题型标识选用链表渲染器，而不是默认数组渲染器

#### Scenario: 未注册题型拒绝渲染

- **WHEN** 某题的题型标识在 Registry 中不存在
- **THEN** 系统展示明确的题型缺失提示，不崩溃、不回退到错误渲染器

### Requirement: 每题步骤脚本注册与查找

系统 SHALL 为热题 100 的每道题提供独立的步骤脚本，脚本接收该题的输入并返回完整的 List<SceneFrame>。Registry MUST 支持按 titleSlug 查找步骤脚本，且查询结果 MUST 包含该题的预置输入、用于高亮的本地代码以及输入上限。

#### Scenario: 打开题目生成帧序列

- **GIVEN** 题目 "two-sum" 的步骤脚本已注册
- **WHEN** 用户打开该题并选择默认预置输入
- **THEN** 系统调用该脚本生成帧序列并交给播放控制器

#### Scenario: 每题动画与自身题解对应

- **WHEN** 用户分别打开链表专题中的两道题
- **THEN** 两道题分别播放各自题目的操作序列，不共用同一段示意动画

### Requirement: 步骤脚本的隔离与规模约束

每题步骤脚本 SHALL 保持与渲染层隔离，MUST NOT 导入 Flutter SDK。每个脚本 MUST 声明输入规模上限并在超限时抛出 ArgumentError，同时 MUST 限制单次生成的帧总数，超过上限时拒绝生成并给出提示，防止帧数量爆炸。

#### Scenario: 输入超过规模上限被拒绝

- **GIVEN** 某题步骤脚本声明的输入规模上限为 50
- **WHEN** 用户提交长度为 51 的输入
- **THEN** 脚本抛出 ArgumentError，UI 展示输入超限提示，不生成帧

#### Scenario: 帧总数超过上限被拒绝

- **GIVEN** 某题步骤脚本声明的帧数上限为 2000
- **WHEN** 某次输入会生成超过 2000 帧
- **THEN** 脚本拒绝生成并提示用户缩小输入规模
