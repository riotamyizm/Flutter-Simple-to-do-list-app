import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];

  List<Task> get tasks =>
      _filteredTasks.isEmpty ? _allTasks : _filteredTasks;

  void addTask(Task task) {
    _allTasks.add(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _allTasks.removeWhere((task) => task.id == id);
    _filteredTasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }

  void editTask(Task updatedTask) {
    final index =
        _allTasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _allTasks[index] = updatedTask;
      notifyListeners();
    }
  }

  void clearAllTasks() {
    _allTasks.clear();
    _filteredTasks.clear();
    notifyListeners();
  }

  void searchTask(String query) {
    if (query.isEmpty) {
      _filteredTasks = [];
    } else {
      _filteredTasks = _allTasks
          .where((task) =>
              task.title.toLowerCase().contains(query.toLowerCase()) ||
              task.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}