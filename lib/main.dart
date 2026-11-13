import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'algorithms/registry.dart';
import 'catalog/asset_snapshot_source.dart';
import 'catalog/prefs_key_value_store.dart';
import 'catalog/problem_repository.dart';
import 'problems/problem_data.dart';
import 'ui/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 启动时注册所有基础算法; 题库异步加载, 不阻塞首帧
  AlgorithmRegistry.instance.registerAll();
  final repository = ProblemRepository(
    localProblems: allProblems(),
    store: PrefsKeyValueStore(),
    snapshot: const AssetSnapshotSource(),
  );
  unawaited(repository.load());

  runApp(AlgorithmVisualApp(repository: repository));
}

class AlgorithmVisualApp extends StatelessWidget {
  final ProblemRepository? repository;

  const AlgorithmVisualApp({super.key, this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '算法可视化',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: HomePage(repository: repository),
    );
  }
}
