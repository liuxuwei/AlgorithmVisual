import 'package:shared_preferences/shared_preferences.dart';

import 'problem_repository.dart';

/// shared_preferences 实现: 移动端落原生存储, Web 落 localStorage
class PrefsKeyValueStore implements KeyValueStore {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String?> read(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }
}
