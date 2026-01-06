import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageService {
  static const String _tasksKey = 'tasks_v1';
  static const String _lastSyncKey = 'last_sync';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save all tasks to local storage
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      await init();
      final jsonList = tasks.map((task) => task.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      final success = await _prefs!.setString(_tasksKey, jsonString);
      if (success) {
        await _prefs!.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      }
      return success;
    } catch (e) {
      print('Error saving tasks: $e');
      return false;
    }
  }

  /// Load all tasks from local storage
  Future<List<Task>> loadTasks() async {
    try {
      await init();
      final jsonString = _prefs!.getString(_tasksKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  /// Clear all tasks from storage
  Future<bool> clearTasks() async {
    try {
      await init();
      return await _prefs!.remove(_tasksKey);
    } catch (e) {
      print('Error clearing tasks: $e');
      return false;
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      await init();
      final timestamp = _prefs!.getInt(_lastSyncKey);
      if (timestamp == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  /// Check if storage has data
  Future<bool> hasData() async {
    await init();
    return _prefs!.containsKey(_tasksKey);
  }

  /// Get storage size (approximate)
  Future<int> getStorageSize() async {
    await init();
    final jsonString = _prefs!.getString(_tasksKey);
    return jsonString?.length ?? 0;
  }
}