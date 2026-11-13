# Tasks

## 1. 依赖与数据模型扩展

- [x] 1.1 在 `pubspec.yaml` 添加 `http`、`shared_preferences`、`flutter_html` 依赖，执行 `flutter pub get`，验证依赖解析成功且 `flutter analyze` 无新增报错
- [x] 1.2 扩展 `lib/core/scene/element.dart`：新增 `LinkedListNode`、`MatrixCell`、`StackFrame`、`HashEntry`、`PointerMarker`，验证 `flutter analyze` 通过且 sealed class 穷尽分支无遗漏
- [x] 1.3 扩展 `lib/core/scene/action.dart`：新增 `Pointer`（label + targetId）与 `Range`（label + 起止 targetId），验证现有 `Highlight/Swap/Insert/Remove/Mark` 用例仍通过
- [x] 1.4 扩展 `lib/core/scene/input_schema.dart`：新增 `matrix`、`string` 工厂与矩阵行列上限字段，验证 `test/core/input_schema_test.dart` 覆盖四种字段类型的构造与约束
- [x] 1.5 为新增 Element/Action 补纯 Dart 单测 `test/core/scene_model_test.dart`，验证 id 唯一性、位置字段与标签字段可正确读取

## 2. 题库目录与网络层

- [x] 2.1 新建 `lib/catalog/problem_entry.dart`：定义 `ProblemEntry`、`ProblemGroup`、`ProblemDifficulty`，含 titleSlug、题号、中文标题、难度、分组、patternId、代码、预置输入、maxInputSize、maxFrames，验证构造与 JSON 序列化往返一致
- [x] 2.2 新建 `lib/catalog/problem_catalog.dart`：按 titleSlug 与分组建立索引，验证单测可查出 100 条、17 组，且重复 titleSlug 被拒绝
- [x] 2.3 新建 `lib/catalog/leetcode_client.dart`：实现 `studyPlanV2Detail(planSlug: "top-100-liked")` 拉列表与 `question(titleSlug)` 拉中文题面，注入 `http.Client` 以便测试，验证 mock 响应可解析出 100 题与题面 HTML
- [x] 2.4 新建 `lib/catalog/problem_repository.dart`：实现"读缓存 → 立即返回 → 后台刷新 → 失败降级快照"流程，验证单测覆盖缓存命中、缓存损坏、网络失败、返回题目数异常四条路径
- [x] 2.5 新建 `tool/fetch_catalog.dart` 快照生成脚本，输出 `assets/problem_catalog.json`（100 条元数据 + 中文题面），验证脚本执行后文件含 100 条记录且可在 `ProblemCatalog` 中解析
- [x] 2.6 在 `pubspec.yaml` 注册 assets 并实现快照加载入口，验证断网时（mock 网络失败）仓库返回快照数据且带离线标记

## 3. 渲染组件

- [x] 3.1 新建链表渲染组件（节点 Widget + CustomPaint 箭头/空指针），验证注入 `LinkedListNode` 帧时节点按 next 关系排列且箭头正确
- [x] 3.2 新建矩阵/网格渲染组件（按 row/col 排布 MatrixCell，支持状态着色），验证 `matrix-grid` 帧渲染出正确行列数
- [x] 3.3 新建栈/队列渲染组件（StackFrame 自底向上排布），验证元素数量与顺序和帧数据一致
- [x] 3.4 新建哈希桶渲染组件（HashEntry 按 bucket 分组展示 key/value），验证同桶多条目正确分组
- [x] 3.5 在 `lib/core/visualization/scene_renderer.dart` 接入新组件并实现"主元素类型 + 覆盖层"分发，验证 `PointerMarker` 与 `Pointer/Range` 动作能叠加显示在基础渲染器之上
- [x] 3.6 为渲染组件补 Widget 测试 `test/ui/renderers_test.dart`，验证四种新组件在给定帧下渲染无异常且关键文本可见

## 4. 步骤脚本基础设施

- [x] 4.1 新建 `lib/problems/script_helpers.dart`：提供 `FrameCollector` 与指针/区间/着色辅助方法，验证超过 maxFrames 时立即抛 `ArgumentError`
- [x] 4.2 建立 `lib/problems/problem_data.dart` 的 100 条 `ProblemEntry` 组装骨架（先占位 patternId 与脚本），验证目录能返回 100 条且依赖 14 个合法 patternId
- [x] 4.3 为 `FrameCollector` 与规模保护补单测 `test/problems/script_helpers_test.dart`，验证输入超限与帧数超限两条拒绝路径

## 5. 按专题实现 100 份步骤脚本

- [x] 5.1 实现哈希（3）、双指针（4）、滑动窗口（2）、子串（3）共 12 道题脚本与本地代码/预置输入，验证 `flutter test test/problems/batch1_test.dart` 每题帧数 ≤ maxFrames 且第 0 帧元素完整
- [x] 5.2 实现普通数组（5）、矩阵（4）、二分查找（6）共 15 道题脚本与本地代码/预置输入，验证 `test/problems/batch2_test.dart` 每题可生成帧且 currentLine 不越界
- [x] 5.3 实现链表（14）道题脚本与本地代码/预置输入，验证 `test/problems/linked_list_test.dart` 覆盖相交、反转、环检测、合并、删除倒数第 N、排序链表等关键题的帧序列
- [x] 5.4 实现二叉树（15）道题脚本与本地代码/预置输入，验证 `test/problems/binary_tree_test.dart` 覆盖中序/层序/深度/路径等关键题的帧序列
- [x] 5.5 实现图论（4）、回溯（8）共 12 道题脚本与本地代码/预置输入，验证 `test/problems/batch5_test.dart` 每题帧数 ≤ maxFrames 且 visited/选择-撤销动作成对出现
- [x] 5.6 实现栈（5）、堆（3）、贪心（4）共 12 道题脚本与本地代码/预置输入，验证 `test/problems/batch6_test.dart` 每题可生成帧且元素类型与 patternId 匹配
- [x] 5.7 实现动态规划（10）、多维动态规划（5）、技巧（5）共 20 道题脚本与本地代码/预置输入，验证 `test/problems/batch7_test.dart` 每题可生成帧且 DP 格子按依赖顺序填充
- [x] 5.8 汇总校验 `problem_data.dart` 覆盖全部 100 个 titleSlug，验证 `test/problems/catalog_coverage_test.dart` 断言数量为 100 且每个 patternId 均有脚本

## 6. UI 改造

- [x] 6.1 重写 `lib/ui/home_page.dart`：热题 100 主入口（17 组卡片 + 难度筛选）+「基础算法」入口，验证 Widget 测试可看到两个入口并可进入专题列表
- [x] 6.2 新建 `lib/ui/problem_list_page.dart`：展示题号、中文标题、难度，验证 Widget 测试点击题目可跳转播放页
- [x] 6.3 改造 `lib/ui/visualization_page.dart`：移除按中文名硬编码的源码与预置用例，改为从 `ProblemEntry` 读取，验证基础算法 4 个页面仍可正常播放
- [x] 6.4 在播放页加入折叠题面卡片（默认收起、懒加载、加载态），验证 Widget 测试展开后可看到题面文本且可视化区域仍可见
- [x] 6.5 改造输入面板：按 `InputSchema` 动态渲染数组/整数/字符串/矩阵字段与校验，验证 Widget 测试覆盖矩阵与字符串输入的错误提示
- [x] 6.6 接入离线标识与重试入口（首页与播放页），验证 mock 降级场景下离线标识可见、重试成功后消失
- [x] 6.7 更新 `lib/main.dart` 启动流程：先注册基础算法与题型渲染器，再异步加载题库，验证 App 启动不阻塞且题库加载中出现加载态

## 7. 集成验证

- [x] 7.1 执行 `flutter analyze`，验证零 error、零 warning
- [x] 7.2 执行 `flutter test`，验证全部单测与 Widget 测试通过，且原有 4 个算法测试仍为绿
- [x] 7.3 在移动端模拟器运行，验证首页 17 组加载、任选 5 道不同题型题目可播放动画且代码高亮同步
- [x] 7.4 在 Web 端运行，验证 CORS 拦截下自动降级快照、离线标识显示、题库与可视化仍可用

## Workflow follow-up

- 实现完成并通过验证后，按项目评审要求归档该 change。
- 归档后确认 `openspec/specs/` 中新增 `problem-catalog` 能力且三个既有能力已合并本次增量。
