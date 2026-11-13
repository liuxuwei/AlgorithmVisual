# Tasks

## 1. Flutter 项目骨架搭建

- [x] 1.1 初始化 Flutter 项目：通过 `flutter create --platforms=android,ios` 生成平台目录并合并到项目根 (android/、ios/、.metadata)，另加 web/ 用于验证
- [x] 1.2 创建目录结构：在 `lib/` 下建立 `core/scene/`、`core/playback/`、`core/visualization/widgets/`、`algorithms/sorting/`、`ui/` 五个子目录
- [x] 1.3 配置 pubspec.yaml 添加 flutter_lints 作为开发依赖，`flutter pub get` 成功

## 2. Scene 数据模型 (纯 Dart，无 Flutter 依赖)

- [x] 2.1 实现 SceneFrame 类：`lib/core/scene/scene_frame.dart`
- [x] 2.2 实现 Element 密封类及其 4 种子类：`element.dart` + `point.dart` (纯 Dart 坐标类)
- [x] 2.3 实现 Action 密封类及其 5 种子类：`action.dart`
- [x] 2.4 实现 InputSchema 和 InputField：`input_schema.dart`
- [x] 2.x 纯 Dart 单测：`test/core/scene/scene_models_test.dart`

## 3. PlaybackController (纯 Dart)

- [x] 3.1 实现 PlaybackController：`lib/core/playback/playback_controller.dart`
- [x] 3.2 实现循环模式和边界保护 (clamp, stepBackward 不越界, loop 自动重置)
- [x] 3.x 纯 Dart 单测：`test/core/playback/playback_controller_test.dart`

## 4. 渲染 Widget 管线

- [x] 4.1 实现 ArrayBar Widget：`lib/core/visualization/widgets/array_bar.dart`
- [x] 4.2 实现 SceneRenderer：`lib/core/visualization/scene_renderer.dart`
- [x] 4.3 实现 DpGrid Widget：`lib/core/visualization/widgets/dp_grid.dart`

## 5. AlgorithmVisualizer 接口与首批算法

- [x] 5.1 实现 AlgorithmVisualizer 抽象接口：`lib/algorithms/base.dart`
- [x] 5.2 实现 BubbleSortVisualizer：`lib/algorithms/sorting/bubble_sort.dart` (含 Swap/Highlight Action + currentLine 行号映射)
- [x] 5.3 实现 QuickSortVisualizer：`lib/algorithms/sorting/quick_sort.dart` (含 pivot/sorted 标记, Lomuto partition)
- [x] 5.4 实现 AlgorithmRegistry：`lib/algorithms/registry.dart`
- [x] 5.5 maxInputSize 校验 + 最终值排序验证：`test/algorithms/algorithms_test.dart`
- [x] 5.6 algorithms 层隔离验证：grep 确认 algorithms/ 和 core/scene/ 和 core/playback/ 零 Flutter import

## 6. Flutter UI 页面

- [x] 6.1 首页 HomePage：`lib/ui/home_page.dart` (分类卡片列表)
- [x] 6.2 算法列表页 AlgorithmListPage：`lib/ui/algorithm_list_page.dart`
- [x] 6.3 VisualizationPage 布局：上可视化 + 中 caption + 代码 + 下播放控制 (垂直堆叠)
- [x] 6.4 播放控制器 Widget：play/pause, step, 进度条, 速度 (0.5x-4x), 循环, restart
- [x] 6.5 代码逐行同步高亮：_CodeView 组件用 currentLine/activeLines 着色
- [x] 6.6 帧 caption 显示：SceneFrame.caption 显示在可视化和代码之间
- [x] 6.7 输入用例选择面板：5 个冒泡排序预置用例 (逆序/已排序/有重复/随机/单元素)
- [x] 6.8 自定义输入表单：TextField + int.parse 校验 + 超过 maxInputSize 提示

## 7. 集成验证

- [x] 7.1 端到端验证冒泡排序流程：widget 测试覆盖 首页→排序分类→冒泡排序→单步前进/后退/切换预置用例/自定义面板
- [x] 7.2 端到端验证快速排序：widget 测试覆盖页面渲染 + pivot 帧说明推进；算法层单测覆盖排序正确性
- [x] 7.3 Flutter test 运行全量：78 个测试全部通过；`flutter analyze` 零问题
- [ ] 7.4 iOS Simulator 验证 *(本机为 Windows，无法运行 iOS 模拟器)*
- [ ] 7.5 Android Emulator 验证 *(本机未配置 Android SDK/模拟器；`flutter run`/`build` 受 SDK 目录只读限制)*

## 8. Tree 渲染与 DFS/BFS (follow-up 扩展)

- [x] 8.1 实现 TreeView Widget：`lib/core/visualization/widgets/tree_view.dart` (CustomPaint 连线 + 圆形节点, 支持 visited/highlight)
- [x] 8.2 SceneRenderer 分发 TreeNode：按 ArrayBar → DpCell → TreeNode 优先级渲染
- [x] 8.3 实现层序数组建树模型：`lib/algorithms/tree/level_order_tree.dart` (-1 表示空位, 空位后代忽略, 中序坐标)
- [x] 8.4 实现 DfsTraversalVisualizer：`lib/algorithms/tree/dfs_traversal.dart` (前序遍历)
- [x] 8.5 实现 BfsTraversalVisualizer：`lib/algorithms/tree/bfs_traversal.dart` (队列层序)
- [x] 8.6 注册到 AlgorithmRegistry, 并为两类算法补充预置用例、代码高亮与自定义输入提示
- [x] 8.7 单测与 widget 测试：`test/algorithms/tree_test.dart` + 树遍历页面 smoke 用例

## Workflow follow-up

- 归档前补充 Graph 类 Element 的 Widget 实现与图/DP 算法（Tree 渲染与 DFS/BFS 已完成）
- 归档前考虑是否将 maxInputSize 校验提到 UI 层前置拦截（当前在 visualize 方法内抛异常）
- 归档后执行 openspec archive 将 delta specs 合并到主 specs 目录
