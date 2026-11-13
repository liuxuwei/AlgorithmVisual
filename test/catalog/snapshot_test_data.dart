import 'dart:convert';
import 'dart:io';

/// 读取真实内置快照, 供目录 / 仓库测试构造 100 条数据
Map<String, dynamic> loadSnapshotJson() {
  final raw = File('assets/problem_catalog.json').readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

String loadSnapshotRaw() => File('assets/problem_catalog.json').readAsStringSync();
