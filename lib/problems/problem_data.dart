import '../catalog/problem_catalog.dart';
import '../catalog/problem_entry.dart';
import 'scripts/batch1.dart';
import 'scripts/batch2.dart';
import 'scripts/batch3.dart';
import 'scripts/batch4.dart';
import 'scripts/batch5.dart';
import 'scripts/batch6.dart';
import 'scripts/batch7.dart';

/// 热题 100 的全部题目 (100 条)
List<ProblemEntry> allProblems() => [
      ...batch1Problems(),
      ...batch2Problems(),
      ...batch3Problems(),
      ...batch4Problems(),
      ...batch5Problems(),
      ...batch6Problems(),
      ...batch7Problems(),
    ];

/// 内置题库目录
final ProblemCatalog builtinCatalog = ProblemCatalog(allProblems());
