import 'package:flutter/services.dart';

import 'problem_repository.dart';

/// 从应用资源包加载内置题库快照
class AssetSnapshotSource implements SnapshotSource {
  final String assetPath;

  const AssetSnapshotSource({this.assetPath = 'assets/problem_catalog.json'});

  @override
  Future<String?> load() async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (_) {
      return null;
    }
  }
}
