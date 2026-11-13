import 'package:material_ui/material_ui.dart';

import '../catalog/problem_entry.dart';
import '../catalog/problem_repository.dart';
import '../core/playback/playback_controller.dart';
import '../core/scene/input_schema.dart';
import '../core/scene/scene_frame.dart';
import '../core/visualization/scene_renderer.dart';
import 'input_parsing.dart';
import 'offline_banner.dart';
import 'problem_list_page.dart';
import 'statement_text.dart';

/// VisualizationPage —— 可视化播放页
///
/// 题目源码、预置用例与步骤脚本全部来自 [ProblemEntry],
/// 页面不再按算法名称硬编码。
class VisualizationPage extends StatefulWidget {
  final ProblemEntry problem;
  final ProblemRepository? repository;

  const VisualizationPage({
    super.key,
    required this.problem,
    this.repository,
  });

  @override
  State<VisualizationPage> createState() => _VisualizationPageState();
}

class _VisualizationPageState extends State<VisualizationPage> {
  PlaybackController? _controller;
  int _selectedPresetIndex = 0;
  bool _showCustomInput = false;
  final Map<String, TextEditingController> _inputs = {};
  final Map<String, String?> _errors = {};
  String? _scriptError;
  double _currentSpeed = 1.0;
  bool _loopEnabled = false;
  bool _retrying = false;

  bool _statementExpanded = false;
  bool _statementLoading = false;
  String? _statementHtml;
  String? _statementError;

  @override
  void initState() {
    super.initState();
    for (final field in widget.problem.inputSchema.fields) {
      _inputs[field.name] = TextEditingController();
    }
    final presets = widget.problem.presets;
    if (presets.isNotEmpty) {
      _generateAndPlay(presets.first.input);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    for (final controller in _inputs.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _generateAndPlay(Map<String, dynamic> input) {
    final script = widget.problem.script;
    if (script == null) {
      setState(() => _scriptError = '该题暂无可视化脚本');
      return;
    }
    _controller?.dispose();
    try {
      final frames = script(input);
      setState(() {
        _scriptError = null;
        _controller = PlaybackController(frames)
          ..setSpeed(_currentSpeed)
          ..setLoop(_loopEnabled);
      });
    } on ArgumentError catch (e) {
      setState(() {
        _controller = null;
        _scriptError = e.message?.toString() ?? '$e';
      });
    }
  }

  void _onPresetTap(int index) {
    setState(() {
      _selectedPresetIndex = index;
      _showCustomInput = false;
    });
    _generateAndPlay(widget.problem.presets[index].input);
  }

  void _onCustomSubmit() {
    final values = <String, dynamic>{};
    var hasError = false;
    for (final field in widget.problem.inputSchema.fields) {
      final parsed = parseInputField(field, _inputs[field.name]!.text);
      if (parsed.hasError) {
        hasError = true;
        _errors[field.name] = parsed.error;
      } else {
        _errors[field.name] = null;
        values[field.name] = parsed.value;
      }
    }
    setState(() {});
    if (hasError) return;
    _generateAndPlay(values);
  }

  Future<void> _toggleStatement() async {
    final expanded = !_statementExpanded;
    setState(() => _statementExpanded = expanded);
    if (expanded && _statementHtml == null && !_statementLoading) {
      await _loadStatement();
    }
  }

  Future<void> _loadStatement() async {
    setState(() {
      _statementLoading = true;
      _statementError = null;
    });
    String? html;
    final repository = widget.repository;
    if (repository != null) {
      html = await repository.statementFor(widget.problem);
    }
    html ??= widget.problem.statementHtml;
    if (!mounted) return;
    setState(() {
      _statementLoading = false;
      _statementHtml = html;
      _statementError =
          html == null || html.trim().isEmpty ? '题面加载失败, 请稍后重试' : null;
    });
  }

  Future<void> _retry() async {
    final repository = widget.repository;
    if (repository == null || _retrying) return;
    setState(() => _retrying = true);
    await repository.refresh();
    if (!mounted) return;
    setState(() => _retrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository;
    if (repository == null) {
      return _buildScaffold(context, offline: false);
    }
    return ValueListenableBuilder<CatalogState>(
      valueListenable: repository.state,
      builder: (context, state, _) => _buildScaffold(
        context,
        offline: state.isOffline,
      ),
    );
  }

  Widget _buildScaffold(BuildContext context, {required bool offline}) {
    final controller = _controller;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem.title),
        actions: [
          if (widget.problem.number > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '#${widget.problem.number}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: OfflineBanner(onRetry: _retry, retrying: _retrying),
            ),
          _buildStatementCard(context),
          _buildInputPanel(context),
          Expanded(
            child: controller == null
                ? const Center(child: Text('暂无可播放的步骤脚本'))
                : ValueListenableBuilder<SceneFrame>(
                    valueListenable: controller,
                    builder: (context, frame, _) {
                      return Column(
                        children: [
                          Expanded(
                            flex: 9,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: SceneRenderer(frame: frame),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Text(
                              frame.caption,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: _CodeView(
                              code: widget.problem.code,
                              currentLine: frame.currentLine,
                              activeLines: frame.activeLines,
                            ),
                          ),
                          _buildPlaybackControls(context),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementCard(BuildContext context) {
    final hasDifficulty = widget.problem.number > 0;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleStatement,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    _statementExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text('题目描述',
                      style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  if (hasDifficulty)
                    DifficultyBadge(difficulty: widget.problem.difficulty),
                ],
              ),
            ),
          ),
          if (_statementExpanded)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: _buildStatementBody(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatementBody(BuildContext context) {
    if (_statementLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_statementError != null) {
      return Row(
        children: [
          Expanded(child: Text(_statementError!)),
          TextButton(onPressed: _loadStatement, child: const Text('重试')),
        ],
      );
    }
    final html = _statementHtml;
    if (html == null) {
      return const Text('暂无题面');
    }
    return SingleChildScrollView(
      child: StatementText(html: html),
    );
  }

  Widget _buildInputPanel(BuildContext context) {
    final presets = widget.problem.presets;
    final fields = widget.problem.inputSchema.fields;
    if (presets.isEmpty && fields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (var i = 0; i < presets.length; i++)
                  FilterChip(
                    label: Text(presets[i].label),
                    selected: _selectedPresetIndex == i && !_showCustomInput,
                    onSelected: (_) => _onPresetTap(i),
                  ),
                if (fields.isNotEmpty)
                  FilterChip(
                    label: const Text('自定义'),
                    selected: _showCustomInput,
                    onSelected: (_) {
                      setState(() => _showCustomInput = !_showCustomInput);
                    },
                  ),
              ],
            ),
          ),
          if (_showCustomInput) _buildCustomForm(context),
          if (_scriptError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _scriptError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomForm(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      padding: const EdgeInsets.only(top: 4),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final field in widget.problem.inputSchema.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: TextField(
                  controller: _inputs[field.name],
                  keyboardType: switch (field.type) {
                    InputFieldType.int => TextInputType.number,
                    InputFieldType.matrix => TextInputType.multiline,
                    _ => TextInputType.text,
                  },
                  maxLines: field.type == InputFieldType.matrix ? 3 : 1,
                  decoration: InputDecoration(
                    labelText: field.label,
                    hintText: hintOf(field),
                    errorText: _errors[field.name],
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            FilledButton.tonal(
              onPressed: _onCustomSubmit,
              child: const Text('生成'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    final controller = _controller!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                '${controller.currentIndex + 1}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: controller.currentIndex.toDouble(),
                  min: 0,
                  max: (controller.frameCount - 1).toDouble(),
                  onChanged: (v) => controller.seek(v.round()),
                ),
              ),
              Text(
                '${controller.frameCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                tooltip: '上一帧',
                onPressed: controller.stepBackward,
              ),
              IconButton.filled(
                icon: Icon(
                  controller.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
                tooltip: controller.isPlaying ? '暂停' : '播放',
                onPressed: controller.togglePlay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                tooltip: '下一帧',
                onPressed: controller.stepForward,
              ),
              PopupMenuButton<double>(
                initialValue: _currentSpeed,
                tooltip: '播放速度',
                onSelected: (speed) {
                  setState(() => _currentSpeed = speed);
                  controller.setSpeed(speed);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  PopupMenuItem(value: 2.0, child: Text('2.0x')),
                  PopupMenuItem(value: 4.0, child: Text('4.0x')),
                ],
                child: Chip(
                  label: Text('${_currentSpeed}x'),
                  avatar: const Icon(Icons.speed, size: 16),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.repeat,
                  color: _loopEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                tooltip: '循环播放',
                onPressed: () {
                  setState(() => _loopEnabled = !_loopEnabled);
                  controller.setLoop(_loopEnabled);
                },
              ),
              IconButton(
                icon: const Icon(Icons.restart_alt),
                tooltip: '从头开始',
                onPressed: controller.restart,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 代码查看组件 —— 带逐行高亮
class _CodeView extends StatelessWidget {
  final String code;
  final int? currentLine;
  final List<int>? activeLines;

  const _CodeView({
    required this.code,
    this.currentLine,
    this.activeLines,
  });

  @override
  Widget build(BuildContext context) {
    final lines = code.split('\n');
    final activeSet = <int>{};
    if (currentLine != null) activeSet.add(currentLine!);
    if (activeLines != null) activeSet.addAll(activeLines!);

    return Container(
      color: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final lineNum = index + 1;
          final isActive = activeSet.contains(lineNum);
          final isCurrent = lineNum == currentLine;

          Color bgColor;
          if (isCurrent) {
            bgColor = Colors.orange.shade200;
          } else if (isActive) {
            bgColor = Colors.orange.shade100;
          } else {
            bgColor = Colors.transparent;
          }

          return Container(
            color: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '$lineNum',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isCurrent ? Colors.deepOrange : Colors.grey,
                      fontSize: 12,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lines[index],
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: isCurrent ? Colors.black87 : Colors.black54,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
