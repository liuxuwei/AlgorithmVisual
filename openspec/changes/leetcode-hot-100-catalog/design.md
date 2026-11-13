# Design

## Context

见 `proposal.md` 的 Why。以下是影响方案实现的现状与约束：

- 现有可视化框架已具备快照帧模型：`SceneFrame` 不可变、支持 O(1) seek，`PlaybackController` 接收完整帧列表，`AlgorithmVisualizer.visualize` 同步返回 `List<SceneFrame>`。
- 算法层与渲染层已隔离：`lib/algorithms/**` 只依赖 `lib/core/scene/**`，不导入 Flutter。
- 现有 4 个算法通过中文 `name` 在 `AlgorithmRegistry` 注册；`visualization_page.dart` 用 `if (name == ...)` 硬编码源码与预置用例。
- 现有元素类型只有 ArrayBar / TreeNode / GraphNode / DpCell；`InputSchema` 只实现数组与整数。
- 依赖仅有 Flutter 与 `material_ui`，无 HTTP 客户端，无 HTML 渲染能力。
- 目标平台为 iOS / Android / Web；Web 端受浏览器 CORS 限制。

已实测的网络事实（约束来源）：

- `POST https://leetcode.cn/graphql/`，`Content-Type: application/json` 可用。
- `studyPlanV2Detail(planSlug: "top-100-liked")` 返回「LeetCode 热题 100」，共 100 题、17 个专题组，字段含 `titleSlug / questionFrontendId / title / difficulty`。
- `question(titleSlug: ...)` 返回 `translatedTitle` 与 `translatedContent`（中文题面，HTML）。
- 响应头**不含** `Access-Control-Allow-Origin`，浏览器直连会被拦截。
- 属于网页端非公开接口，无稳定性承诺。

## Goals / Non-Goals

**Goals:**

- 题库内容与可视化实现解耦：网络/缓存只提供题目内容，可视化完全本地可控。
- 断网、Web CORS、接口变更三种情况下降级到内置快照，功能不残缺。
- 100 道题共享 14 种渲染词汇，但每题拥有独立步骤脚本、独立代码与独立预置输入。
- 保留现有 4 个算法与其测试，不作为迁移代价。

**Non-Goals:**

- 不做 LeetCode 登录、提交、判题、提交结果回显。
- 不做用户做题进度、收藏、云端同步。
- 不抓取官方题解代码（行号不可控）。
- 不自建 CORS 代理；Web 端只保证内置快照可用。
- 不引入流式/懒生成帧，仍保持一次性生成全部帧。

## Decisions

### D1. 数据源：LeetCode 网页端 GraphQL

使用 `studyPlanV2Detail` 拉列表、`question` 按需拉题面。理由是它是唯一能同时提供官方 100 题清单（含 17 个专题分组）和中文题面的来源；`/api/problems/all/` 虽可用但只有全量列表、无分组无题面，官方无公开 API。

备选：第三方镜像仓库（稳定性依赖维护者）、纯人工整理 JSON（无法满足"从网络获取"）。

### D2. 内容边界：网络只管题面，其余本地

网络提供：`titleSlug、题号、中文标题、难度、专题分组、中文题面`。本地提供：题解代码、预置输入、步骤脚本、题型映射。

理由：`SceneFrame.currentLine` 依赖精确行号，任何来自外部的代码改动都会让高亮错位。这条边界同时让断网时的可视化行为与在线完全一致。

备选：网络提供官方题解代码 + 本地行号映射表（题解改版即失配）；网络提供全部内容（不可行）。

### D3. 三层结构：目录 / 渲染器 / 步骤脚本

```
ProblemRepository  -> ProblemCatalog -> ProblemEntry -> 步骤脚本 -> List<SceneFrame>
                                            |
                                            +-> patternId -> PatternRenderer
```

- `ProblemCatalog`：100 条 `ProblemEntry`，按 17 个专题分组，以 `titleSlug` 为键。
- `ProblemEntry`：`titleSlug`、题号、中文标题、难度、分组、`patternId`、`AlgorithmVisualizer` 步骤脚本实例、本地代码、预置输入、`maxInputSize`、`maxFrames`、题面（懒加载）。
- `PatternRenderer`：14 种题型标识，渲染层按 `patternId` + 元素类型选择组件。

理由：`AlgorithmVisualizer` 接口保持不变，现有 4 个算法零改动；把代码/预置输入/上限从接口外置，避免改动既有契约。

备选：让 100 道题各自实现扩展后的新接口（破坏现有接口与测试）。

### D4. 题型渲染器划分（14 种）

| patternId | 覆盖专题 | 题数 |
|---|---|---|
| `array-basic` | 普通数组 / 贪心算法 / 技巧 | 14 |
| `array-two-pointer` | 双指针 | 4 |
| `array-sliding-window` | 滑动窗口 | 2 |
| `array-prefix-sum` | 子串 | 3 |
| `array-binary-search` | 二分查找 | 6 |
| `hash-table` | 哈希 | 3 |
| `matrix-grid` | 矩阵 / 图论 | 8 |
| `linked-list` | 链表 | 14 |
| `binary-tree` | 二叉树 | 15 |
| `backtracking` | 回溯 | 8 |
| `stack` | 栈 | 5 |
| `heap` | 堆 | 3 |
| `dp-1d` | 动态规划 | 10 |
| `dp-2d` | 多维动态规划 | 5 |

渲染器只提供"怎么画"（元素、指针、区间、着色），不提供"怎么走"。例如 `linked-list` 提供节点与箭头绘制，反转链表与合并链表的步骤序列仍分别由各自脚本产出。

备选：17 个专题各配一个渲染器（滑动窗口与双指针画法几乎相同，切得过细）；按元素类型直接渲染（无法表达指针/窗口等语义标注）。

### D5. 数据模型扩展：Element / Action / InputSchema

- `Element`（sealed，仍在 `element.dart` 内穷尽）：新增 `LinkedListNode`（data、nextId、prevId）、`MatrixCell`（row、col、value、state）、`StackFrame`（index、value）、`HashEntry`（key、value、bucket）、`PointerMarker`（label、targetId）。`PointerMarker` 作为覆盖层元素，`position` 由目标元素决定。
- `Action`（sealed）：新增 `Pointer`（label + targetId）与 `Range`（label + 起止 targetId）。
- `InputSchema`：新增 `matrix`、`string` 工厂与 `rows/cols` 约束；`InputField` 增加矩阵行列上限字段。UI 按类型渲染：数组/矩阵用多行文本、字符串用单行文本、整数用数字框。

兼容性：sealed class 新增子类属于编译期扩展，现有 `switch` 需要补全分支（当前渲染层用 `whereType` 判断，不受影响）。

### D6. 渲染分发：主元素类型 + 覆盖层

`SceneRenderer` 保持"按元素类型分发"的入口，但改为：

1. 先按该帧的主元素类型选基础渲染器（ArrayBar → 数组；LinkedListNode → 链表；MatrixCell/DpCell → 网格；TreeNode → 树；StackFrame → 栈；HashEntry → 哈希桶）。
2. 再把 `PointerMarker` 与 `Pointer/Range` 动作作为覆盖层叠加到基础渲染器之上（Stack + 自定义绘制）。

理由：帧内可能同时存在基础元素和标注，按主类型 + 覆盖层能保持现有 `SceneRenderer(frame)` 签名不变，`visualization_page` 改动最小。

备选：把 `patternId` 传进 `SceneRenderer` 显式选择（渲染器与题型耦合更紧，但会让页面强依赖题型配置）。

### D7. 网络、缓存与兜底

- 依赖：`http`（Web/移动端一致），`shared_preferences`（跨端键值缓存，Web 落 localStorage）。
- 启动流程：读缓存 → 立即渲染 → 后台请求刷新 → 成功则更新并按需重试未变更项。
- 无缓存或刷新失败：读 `assets/problem_catalog.json` 内置快照（含 100 条元数据 + 中文题面），标记为离线。
- 题面：按 `titleSlug` 懒加载，缓存键 `statement:<titleSlug>`；快照内已含全部题面，因此离线首开也有内容。
- 快照生成：开发期 Dart 脚本 `tool/fetch_catalog.dart` 调 GraphQL 产出快照，随仓库提交，发版时重新生成。

理由：`shared_preferences` 无需额外平台插件注册、Web 原生支持；100 条题面约 200-300KB，远低于 localStorage 5MB 限制。

备选：`path_provider` + 文件（Web 不可用）；只存内存（不满足"二次启动用缓存"）。

### D8. 题面渲染：flutter_html

题面是 HTML，`flutter_html` 支持 Web 与移动端，覆盖 `p/code/pre/ul/strong/em/img` 等场景，避免自研解析器。

风险回退：若与当前 SDK 版本冲突，则退化为"白名单标签转纯文本 + 代码块等宽展示"，规格中的"不得出现原始 HTML 标签"仍可满足。

### D9. 页面结构

- 首页：`热题 100` 主入口（17 组卡片 + 难度筛选 Chip）+ `基础算法` 入口（原分类列表）。
- 主题列表页：新增 `ProblemListPage`，展示题号/中文标题/难度；原 `AlgorithmListPage` 保留给基础算法。
- 详情页：`VisualizationPage` 顶部加 `ExpansionTile` 题面卡片（默认收起，懒加载题面），下方保持 可视化 / caption / 代码 / 控制 的原有布局。
- 输入面板：预置用例来自 `ProblemEntry.presets`；自定义输入按 `InputSchema` 动态生成字段控件。

### D10. 规模保护

- 每题声明 `maxInputSize` 与 `maxFrames`（建议 2000）。
- 步骤脚本使用 `FrameCollector` 辅助类累积帧，超过 `maxFrames` 立即抛 `ArgumentError`，避免先生成再检查造成的内存峰值。
- UI 捕获 `ArgumentError` 展示错误，不崩溃。

### D11. 目录与文件布局

```
lib/catalog/
  problem_entry.dart        # ProblemEntry / ProblemGroup / ProblemDifficulty
  problem_catalog.dart      # 按 titleSlug / 分组索引
  leetcode_client.dart      # GraphQL 请求与解析（纯 Dart，可注入 http.Client）
  problem_repository.dart   # 缓存、刷新、快照降级
lib/problems/
  scripts/<group>/<slug>.dart   # 100 份步骤脚本
  problem_data.dart             # 100 条 ProblemEntry 组装
  script_helpers.dart           # FrameCollector、指针/区间辅助
lib/assets/problem_catalog.json # 兜底快照
tool/fetch_catalog.dart         # 快照生成脚本
```

`lib/catalog` 与 `lib/problems` 保持纯 Dart（除渲染器外不导入 Flutter），`leetcode_client` 通过注入 `http.Client` 维持可测试性。

## Risks / Trade-offs

- [GraphQL 字段或路径变更] → 内置快照兜底；客户端解析容错（缺字段视为失败）；快照生成脚本可在发版前重新跑。
- [Web 端 CORS 拦截] → 明确非目标，Web 始终使用快照；UI 显示离线标识，不报错。
- [flutter_html 版本兼容风险] → 先验证编译；不兼容则退化为纯文本 + 代码块渲染。
- [`shared_preferences` 在 Web 的容量限制] → 题面按题分键存储，单键 KB 级；总量 < 5MB。
- [100 份脚本工作量大且易漂移] → 统一 `FrameCollector` 与指针/区间辅助；按专题分批实现并用纯 Dart 单测锁住帧数与关键帧。
- [题面图片依赖外链，离线不可用] → 展示占位符，不阻塞文字内容。
- [快照陈旧] → 记录 `fetchedAt` 并在离线标识中展示；启动成功刷新后覆盖缓存。
- [每题代码与脚本不同步] → 代码与脚本同文件维护（`ProblemEntry` 内常量），单测校验 `currentLine` 不越界。

## Migration Plan

无数据迁移；现有 4 个算法与其测试保留。实施顺序：数据模型扩展 → 目录与网络层 → 渲染组件 → 14 个渲染器 → 100 份脚本（按专题分批）→ 页面改造 → 快照与依赖收尾。

回滚：移除新增依赖与 `assets/problem_catalog.json`，恢复 `main.dart` 启动流程与首页入口即可；基础算法功能不依赖新模块。

## Open Questions

- 是否展示题目通过率与完成状态（需要用户身份，本期不做，后续可加）。
- 题面内图片是否做离线缓存（当前只保留外链与占位符）。
