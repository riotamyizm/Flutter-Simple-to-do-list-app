import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

// Re-export Task and TaskType from models to avoid conflicts
export '../models/task.dart' show Task, TaskType;

// Export enums so they can be used elsewhere
enum TaskFilter { all, completed, pending }
enum TaskSort { dateDesc, dateAsc, titleAsc, titleDesc }

class TaskProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.dateDesc;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskFilter get currentFilter => _currentFilter;
  TaskSort get currentSort => _currentSort;

  List<Task> get tasks {
    List<Task> result = _searchQuery.isEmpty ? _allTasks : _filteredTasks;

    // Apply filter
    switch (_currentFilter) {
      case TaskFilter.completed:
      // FIXED: Only show completed todos, exclude all notes
        result = result.where((t) => t.type == TaskType.todo && t.isDone).toList();
        break;
      case TaskFilter.pending:
      // FIXED: Show pending todos and all notes
        result = result.where((t) =>
        t.type == TaskType.note || (t.type == TaskType.todo && !t.isDone)
        ).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // Apply sort
    result = List.from(result);
    switch (_currentSort) {
      case TaskSort.dateDesc:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSort.dateAsc:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case TaskSort.titleAsc:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case TaskSort.titleDesc:
        result.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    return result;
  }

  List<Task> get allTasks => List.unmodifiable(_allTasks);

  // FIXED: Only count todos for completion tracking
  List<Task> get completedTasks => _allTasks.where((t) => t.type == TaskType.todo && t.isDone).toList();
  List<Task> get pendingTasks => _allTasks.where((t) => t.type == TaskType.todo && !t.isDone).toList();

  // FIXED: Separate counters for todos and notes
  int get totalTasks => _allTasks.where((t) => t.type == TaskType.todo).length;
  int get totalNotes => _allTasks.where((t) => t.type == TaskType.note).length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;

  // FIXED: Calculate percentage based only on todos
  double get completionPercentage =>
      totalTasks == 0 ? 0.0 : (completedCount / totalTasks) * 100;

  // Constructor
  TaskProvider() {
    loadTasks();
  }

  /// Load tasks from storage
  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allTasks = await _storage.loadTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tasks: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save tasks to storage
  Future<bool> _saveTasks() async {
    try {
      return await _storage.saveTasks(_allTasks);
    } catch (e) {
      _error = 'Failed to save tasks: $e';
      notifyListeners();
      return false;
    }
  }

  /// Add new task
  Future<bool> addTask(Task task) async {
    _allTasks.add(task);
    notifyListeners();
    return await _saveTasks();
  }

  /// Update existing task
  Future<bool> updateTask(Task updatedTask) async {
    final index = _allTasks.indexWhere((t) => t.id == updatedTask.id);
    if (index == -1) {
      _error = 'Task not found';
      notifyListeners();
      return false;
    }

    _allTasks[index] = updatedTask;

    // Update filtered list if exists
    final filteredIndex = _filteredTasks.indexWhere((t) => t.id == updatedTask.id);
    if (filteredIndex != -1) {
      _filteredTasks[filteredIndex] = updatedTask;
    }

    notifyListeners();
    return await _saveTasks();
  }

  /// Toggle task completion
  Future<bool> toggleTask(String id) async {
    final index = _allTasks.indexWhere((t) => t.id == id);
    if (index == -1) return false;

    final task = _allTasks[index];

    // FIXED: Don't toggle if it's a note
    if (task.type == TaskType.note) {
      return false;
    }

    final updatedTask = task.copyWith(isDone: !task.isDone);
    return await updateTask(updatedTask);
  }

  /// Delete task
  Future<bool> deleteTask(String id) async {
    final initialLength = _allTasks.length;
    _allTasks.removeWhere((t) => t.id == id);
    _filteredTasks.removeWhere((t) => t.id == id);

    if (_allTasks.length == initialLength) {
      _error = 'Task not found';
      notifyListeners();
      return false;
    }

    notifyListeners();
    return await _saveTasks();
  }

  /// Clear all tasks
  Future<bool> clearAllTasks() async {
    _allTasks.clear();
    _filteredTasks.clear();
    _searchQuery = '';
    notifyListeners();
    return await _storage.clearTasks();
  }

  /// Search tasks
  void searchTask(String query) {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _filteredTasks = [];
    } else {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredTasks = _allTasks.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
            task.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredTasks = [];
    notifyListeners();
  }

  /// Set filter
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Set sort
  void setSort(TaskSort sort) {
    _currentSort = sort;
    notifyListeners();
  }

  /// Get task by ID
  Task? getTaskById(String id) {
    try {
      return _allTasks.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Bulk operations
  Future<bool> deleteCompletedTasks() async {
    // FIXED: Only delete completed todos, not notes
    _allTasks.removeWhere((t) => t.type == TaskType.todo && t.isDone);
    _filteredTasks.removeWhere((t) => t.type == TaskType.todo && t.isDone);
    notifyListeners();
    return await _saveTasks();
  }

  Future<bool> markAllAsCompleted() async {
    // FIXED: Only mark todos as completed, not notes
    _allTasks = _allTasks.map((t) {
      if (t.type == TaskType.todo) {
        return t.copyWith(isDone: true);
      }
      return t;
    }).toList();
    notifyListeners();
    return await _saveTasks();
  }

  Future<bool> markAllAsPending() async {
    // FIXED: Only mark todos as pending, not notes
    _allTasks = _allTasks.map((t) {
      if (t.type == TaskType.todo) {
        return t.copyWith(isDone: false);
      }
      return t;
    }).toList();
    notifyListeners();
    return await _saveTasks();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}