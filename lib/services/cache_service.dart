import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  final Map<String, dynamic> _memory = {};

  Future<T?> getMemory<T>(String key) async {
    final v = _memory[key];
    if (v is T) return v;
    return null;
  }

  Future<void> setMemory(String key, dynamic value) async {
    _memory[key] = value;
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final m = await getMemory<Map<String, dynamic>>(key);
    if (m != null) return m;
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(key);
    if (s == null) return null;
    final j = jsonDecode(s);
    if (j is Map<String, dynamic>) {
      await setMemory(key, j);
      return j;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    final m = await getMemory<List<Map<String, dynamic>>>(key);
    if (m != null) return m;
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(key);
    if (s == null) return null;
    final j = jsonDecode(s);
    if (j is List) {
      final list = j.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
      await setMemory(key, list);
      return list;
    }
    return null;
  }

  Future<void> setJson(String key, Map<String, dynamic> value) async {
    await setMemory(key, value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await setMemory(key, value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  Future<String?> getString(String key) async {
    final m = await getMemory<String>(key);
    if (m != null) return m;
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(key);
    if (s != null) await setMemory(key, s);
    return s;
  }

  Future<void> setString(String key, String value) async {
    await setMemory(key, value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<int?> getInt(String key) async {
    final m = await getMemory<int>(key);
    if (m != null) return m;
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(key);
    if (v != null) await setMemory(key, v);
    return v;
  }

  Future<void> setInt(String key, int value) async {
    await setMemory(key, value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
}
