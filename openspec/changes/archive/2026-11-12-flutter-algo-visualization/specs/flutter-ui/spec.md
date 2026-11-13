# Spec Delta

## Purpose

用 Flutter 构建移动端 App UI，作为可视化框架和算法库的消费端。提供算法分类浏览、题目选择、预置/自定义输入、可视化播放、代码逐行同步高亮的完整用户旅程。MVP 覆盖 iOS 和 Android，无后端依赖。

## ADDED Requirements

### Requirement: 首页算法分类列表

应用启动后 SHALL 展示首页，列出所有已注册的算法 category（如排序、树、图、动态规划），每个分类下显示该分类包含的算法数量。

#### Scenario: 首页展示所有分类

- **WHEN** 用户打开 App
- **THEN** 首页显示 sorting（2 个算法）、tree（1 个算法）等已注册分类的卡片列表
- **WHEN** 某个分类下没有算法
- **THEN** 该分类不显示或显示为禁用状态

#### Scenario: 点击分类进入算法列表

- **WHEN** 用户点击 sorting 分类卡片
- **THEN** 导航到 sorting 分类下的算法详情列表页

### Requirement: 算法详情列表

进入某个 category 后 SHALL 列出该分类下所有算法的名称和简要描述。点击某个算法 SHALL 进入可视化播放页。

#### Scenario: 算法列表展示

- **WHEN** 用户进入 sorting 分类
- **THEN** 列表展示 "冒泡排序"（带简要描述）、"快速排序" 等条目

#### Scenario: 点击算法进入播放页

- **WHEN** 用户点击 "冒泡排序"
- **THEN** 导航到冒泡排序的可视化播放页，自动加载默认输入用例

### Requirement: 可视化播放页布局

可视化播放页 SHALL 分为三个区域：上方可视化区域（约 50% 屏幕）、下方代码区域（约 30% 屏幕）、底部播放控制区域。可视化区域和代码区域 MUST 同时可见。

#### Scenario: 初始渲染布局

- **WHEN** 用户进入冒泡排序播放页
- **THEN** 上半部分显示 ArrayBar 数组可视化，下半部分显示冒泡排序代码文本，底部显示播放控制器

#### Scenario: 竖屏手机布局

- **WHEN** 设备为竖屏（常见手机形态）
- **THEN** 可视化、代码、控制区垂直堆叠，用户可通过上下滑动或控件调整代码区域高度

### Requirement: 播放控制器交互

播放控制器 SHALL 提供 play/pause 按钮、step backward 按钮、step forward 按钮、进度条（显示当前帧号 / 总帧数并可拖动跳转）、速度选择器（0.5x / 1.0x / 2.0x / 4.0x）、循环模式开关。

#### Scenario: 点击播放按钮

- **WHEN** 用户点击播放按钮
- **THEN** 按钮图标变为暂停，可视化区域自动按当前 speed 推进帧序列

#### Scenario: 拖动进度条

- **WHEN** 用户拖动进度条到 42/1225
- **THEN** 立即跳转到第 42 帧，可视化区域和代码区域同步更新

#### Scenario: 切换播放速度

- **WHEN** 用户将速度从 1.0x 切换到 2.0x
- **THEN** 后续帧间隔变为原来的一半

#### Scenario: 循环模式

- **WHEN** 用户打开循环模式开关
- **THEN** 播放到最后一帧后自动回到第一帧继续播放

### Requirement: 代码逐行同步高亮

代码区域 SHALL 显示当前算法的标准实现代码，跟随可视化帧的推进同步高亮 SceneFrame.currentLine 指向的行。activeLines 字段指定的行 SHALL 有不同的高亮样式（如高亮背景更鲜明）。

#### Scenario: 单步执行代码高亮

- **GIVEN** 当前播放到冒泡排序的某一帧，currentLine=5
- **THEN** 代码区域第 5 行背景高亮

#### Scenario: 代码和可视化同步更新

- **WHEN** 播放控制器从 frame 3 推进到 frame 4
- **THEN** 可视化区域 ArrayBar 更新为 frame 4 的状态，代码区域高亮从 frame 3.currentLine 变为 frame 4.currentLine

#### Scenario: 无 currentLine 时降级

- **GIVEN** 某个算法的 SceneFrame.currentLine 为 null
- **WHEN** 渲染该帧
- **THEN** 代码区域不高亮任何行，仅可视化区域正常更新

### Requirement: 输入用例选择与自定义

可视化播放页 SHALL 提供输入选择面板，列出该算法的预置典型用例（如冒泡排序的"已排序"、"逆序"、"有重复"）。用户 SHALL 能选择预置用例或切换到自定义输入模式。自定义输入 SHALL 根据 InputSchema 自动生成输入表单并校验。

#### Scenario: 预置用例一键加载

- **WHEN** 用户点击预置用例 "逆序 [5,4,3,2,1]"
- **THEN** 可视化区域重新生成帧序列并从第 0 帧开始播放，进度条重置

#### Scenario: 自定义输入校验

- **GIVEN** BubbleSortVisualizer 的 maxInputSize 为 50
- **WHEN** 用户在自定义输入框输入 51 个数字
- **THEN** 输入框下方显示 "超过最大长度 50" 的红色提示，生成按钮禁用

#### Scenario: 非法输入实时提示

- **WHEN** 用户在数组输入框输入 "1, abc, 3"
- **THEN** 输入框下方显示 "请输入有效数字" 的提示

#### Scenario: 多字段算法输入

- **GIVEN** Knapsack01Visualizer 需要 weights、values、capacity 三个字段
- **WHEN** 用户切换到自定义输入
- **THEN** 显示三个独立的输入控件，每个有各自的校验逻辑

### Requirement: 帧说明文字同步

SceneFrame.caption SHALL 显示在可视化区域和代码区域之间，作为当前帧的文字说明，随帧推进同步更新。

#### Scenario: 帧说明随播放更新

- **WHEN** 播放到 frame 3，caption 为 "交换 arr[1] 和 arr[2]"
- **THEN** 可视化区域和代码区域之间显示 "交换 arr[1] 和 arr[2]"
- **WHEN** 推进到 frame 4，caption 变为比较下一对
- **THEN** 说明文字同步更新

#### Scenario: 无 caption 时降级

- **GIVEN** 某个 SceneFrame.caption 为空字符串
- **THEN** 帧说明区域显示为空白或隐藏，不显示占位文字
