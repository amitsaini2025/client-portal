import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static Future<void> saveData({
    required String key,
    required List<dynamic> data,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.map((e) => e.toJson()).toList());
    await prefs.setString(key, jsonString);
  }

  static Future<List<T>> loadData<T>(
      String key, T Function(Map<String, dynamic>) fromJson) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    final List decoded = jsonDecode(jsonString);
    return decoded.map<T>((e) => fromJson(e)).toList();
  }
}