import 'package:flutter/foundation.dart';
import '../../core/app_exceptions.dart';
import '../../data/task_model.dart';
import '../../data/task_service.dart';

enum TaskViewState { initial, loading, loaded, empty, error }

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  TaskViewState _state = TaskViewState.initial;
  List<Task> _tasks = [];
  String? _errorMessage;
  bool _isSubmitting = false;

  // Pagination
  bool _hasMore = true;
  bool _isFetchingMore = false;
  static const int _pageSize = 15;

  // Filter
  TaskStatus? _filterStatus;

  TaskProvider(this._taskService);

  TaskViewState get state => _state;
  List<Task> get tasks {
    if (_filterStatus == null) return _tasks;
    return _tasks.where((t) => t.status == _filterStatus).toList();
  }

  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;
  bool get hasMore => _hasMore;
  bool get isFetchingMore => _isFetchingMore;
  TaskStatus? get filterStatus => _filterStatus;

  int get todoCount => _tasks.where((t) => t.status == TaskStatus.todo).length;
  int get inProgressCount =>
      _tasks.where((t) => t.status == TaskStatus.inProgress).length;
  int get doneCount => _tasks.where((t) => t.status == TaskStatus.done).length;

  Future<void> loadTasks(String userId, {bool refresh = false}) async {
    if (refresh) {
      _tasks = [];
      _hasMore = true;
    }

    _state = TaskViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _taskService.getTasks(userId, limit: _pageSize);
      _tasks = result;
      _hasMore = result.length == _pageSize;
      _state = _tasks.isEmpty ? TaskViewState.empty : TaskViewState.loaded;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _state = TaskViewState.error;
    }
    notifyListeners();
  }

  Future<void> loadMore(String userId) async {
    if (!_hasMore || _isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();

    try {
      final result = await _taskService.getTasks(
        userId,
        limit: _pageSize,
      );
      _tasks.addAll(result);
      _hasMore = result.length == _pageSize;
    } on AppException catch (_) {
      // Silent fail for pagination
    }

    _isFetchingMore = false;
    notifyListeners();
  }

  Future<bool> createTask({
    required String userId,
    required String title,
    required String description,
    required TaskStatus status,
    required DateTime dueDate,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final task = Task(
        id: '',
        title: title.trim(),
        description: description.trim(),
        status: status,
        dueDate: dueDate,
        createdAt: DateTime.now(),
        userId: userId,
      );
      final created = await _taskService.createTask(task);
      _tasks.insert(0, created);
      _state = TaskViewState.loaded;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _taskService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) _tasks[index] = updated;
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      if (_tasks.isEmpty) _state = TaskViewState.empty;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void setFilter(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}