import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task_model.dart';
import '../services/task_service.dart';

/// Holds all tasks and the logic to change them.
/// Screens read from it with context.watch / Consumer and
/// call its methods to add, edit, delete and complete tasks.
///
/// The tasks live in Cloud Firestore (users/{uid}/tasks).
/// This provider listens to them live, so every screen updates
/// when the data changes, even if the change came from another device.
class TaskProvider extends ChangeNotifier {
  final TaskService _service = TaskService();

  StreamSubscription<List<TaskModel>>? _subscription;
  String? _uid;
  bool _disposed = false;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// True until the first list of tasks arrives from Firestore.
  bool get isLoading => _isLoading;

  /// The last error message, or null.
  String? get errorMessage => _errorMessage;

  /// All tasks (read only, so screens cannot change the list directly).
  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  // ---------------------------------------------------------------------
  // Connecting to the signed-in user
  // ---------------------------------------------------------------------

  /// Called whenever the signed-in user changes.
  /// - A uid starts listening to that user's tasks.
  /// - null (logged out) stops listening and clears the tasks.
  void setUser(String? uid) {
    // Nothing to do if it is the same user.
    if (uid == _uid) return;

    _subscription?.cancel();
    _subscription = null;
    _uid = uid;
    _tasks = [];
    _errorMessage = null;

    if (uid == null) {
      _isLoading = false;
    } else {
      _isLoading = true;
      _subscription = _service.watchTasks(uid).listen(
        (List<TaskModel> tasks) {
          _tasks = tasks;
          _isLoading = false;
          _errorMessage = null;
          _notify();
        },
        onError: (Object error) {
          debugPrint('Tasks stream error: $error');
          _isLoading = false;
          _errorMessage = 'Could not load your tasks.';
          _notify();
        },
      );
    }

    _notify();
  }

  // ---------------------------------------------------------------------
  // Numbers for the Home and Statistics screens
  // ---------------------------------------------------------------------

  int get totalCount => _tasks.length;

  int get completedCount => _tasks.where((t) => t.isCompleted).length;

  int get pendingCount => totalCount - completedCount;

  /// Completion rate from 0.0 to 1.0.
  double get completionRate =>
      totalCount == 0 ? 0 : completedCount / totalCount;

  /// Tasks due today.
  List<TaskModel> get todayTasks {
    final DateTime now = DateTime.now();
    return _tasks.where((t) => _isSameDay(t.dueDate, now)).toList();
  }

  int get todayTotal => todayTasks.length;

  int get todayCompleted => todayTasks.where((t) => t.isCompleted).length;

  /// Pending tasks, soonest first (used for the Home preview).
  List<TaskModel> upcomingTasks({int limit = 3}) {
    final List<TaskModel> pending =
        _tasks.where((t) => !t.isCompleted).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return pending.take(limit).toList();
  }

  /// All tasks due on the given day, ordered by time (used by the Calendar).
  List<TaskModel> tasksForDay(DateTime day) {
    final List<TaskModel> list =
        _tasks.where((t) => _isSameDay(t.dueDate, day)).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  /// Tasks completed on each of the last 7 days.
  /// Index 0 is 6 days ago and index 6 is today.
  /// (A completed task counts on the day it was last updated.)
  List<int> get weeklyCompleted {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final List<int> counts = List.filled(7, 0);

    for (final TaskModel task in _tasks) {
      if (!task.isCompleted) continue;

      final DateTime updated = DateTime(
        task.updatedAt.year,
        task.updatedAt.month,
        task.updatedAt.day,
      );
      final int daysAgo = today.difference(updated).inDays;

      if (daysAgo >= 0 && daysAgo <= 6) {
        counts[6 - daysAgo] += 1;
      }
    }
    return counts;
  }

  // ---------------------------------------------------------------------
  // Actions
  //
  // We do not wait for the cloud here. Firestore shows our own change
  // on screen immediately (even offline) and sends it to the cloud when
  // it can. The live stream above then updates the list.
  // ---------------------------------------------------------------------

  /// Adds a new task.
  void addTask(TaskModel task) {
    final String? uid = _uid;
    if (uid == null) return;

    _run(_service.addTask(uid, task), 'Could not save the task.');
  }

  /// Saves the changes of a task.
  void updateTask(TaskModel task) {
    final String? uid = _uid;
    if (uid == null) return;

    _run(_service.updateTask(uid, task), 'Could not update the task.');
  }

  /// Removes a task.
  void deleteTask(String id) {
    final String? uid = _uid;
    if (uid == null) return;

    _run(_service.deleteTask(uid, id), 'Could not delete the task.');
  }

  /// Marks a task as completed, or back to pending.
  void toggleTask(String id) {
    final String? uid = _uid;
    if (uid == null) return;

    final int index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final TaskModel changed =
        _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);

    _run(_service.updateTask(uid, changed), 'Could not update the task.');
  }

  /// Clears the last error message.
  void clearError() {
    _errorMessage = null;
    _notify();
  }

  // ---------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------

  /// Runs a Firestore write and records an error if it fails.
  void _run(Future<void> action, String errorText) {
    action.catchError((Object error) {
      debugPrint('Task write error: $error');
      _errorMessage = errorText;
      _notify();
    });
  }

  /// Notifies the screens. It waits a moment first, so it is also safe to
  /// call while Flutter is still building the screen.
  void _notify() {
    Future.microtask(() {
      if (!_disposed) notifyListeners();
    });
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}