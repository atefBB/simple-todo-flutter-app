import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/connectivity_service.dart';
import '../services/local_database_service.dart';
import '../services/supabase_service.dart';

class TaskProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;
  final LocalDatabaseService _localDb;
  final ConnectivityService _connectivityService;

  List<Task> _tasks = [];
  String? _currentFamilyCode;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Map<String, dynamic>>>? _taskSubscription;
  StreamSubscription<bool>? _connectivitySub;

  TaskProvider({
    required SupabaseService supabaseService,
    required LocalDatabaseService localDb,
    required ConnectivityService connectivityService,
  })  : _supabaseService = supabaseService,
        _localDb = localDb,
        _connectivityService = connectivityService {
    _connectivitySub =
        _connectivityService.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentFamilyCode => _currentFamilyCode;
  bool get isOnline => _connectivityService.isOnline;

  void setFamilyCode(String code) {
    _currentFamilyCode = code;
  }

  Future<void> _onConnectivityChanged(bool online) async {
    notifyListeners();
    if (online && _currentFamilyCode != null) {
      await _sync();
    }
  }

  Future<void> loadTasks(String familyCode) async {
    _isLoading = true;
    _currentFamilyCode = familyCode;
    notifyListeners();

    _tasks = await _localDb.getTasks(familyCode);
    _error = null;
    notifyListeners();

    if (isOnline) {
      await _fetchAndSubscribe(familyCode);
    } else {
      _error = 'Offline - showing cached data';
      notifyListeners();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchAndSubscribe(String familyCode) async {
    try {
      final serverTasks = await _supabaseService.getTasks(familyCode);
      await _localDb.replaceAllTasks(familyCode, serverTasks);
      _tasks = serverTasks;
      _error = null;
      notifyListeners();

      await _taskSubscription?.cancel();
      _taskSubscription =
          _supabaseService.subscribeToTasks(familyCode, (updatedTasks) {
        _tasks = updatedTasks;
        _error = null;
        _localDb.replaceAllTasks(familyCode, updatedTasks);
        notifyListeners();
      });
    } catch (e) {
      _error = isOnline ? e.toString() : 'Offline - showing cached data';
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    if (_currentFamilyCode == null) return;

    await _localDb.upsertTask(task, syncStatus: 'pending_create');

    _tasks.add(task);
    _error = null;
    notifyListeners();

    if (isOnline) {
      try {
        final serverTask = await _supabaseService.addTask(task);
        await _localDb.updateSyncStatus(task.id, 'synced');
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = serverTask;
          notifyListeners();
        }
      } catch (e) {
        _error = 'Saved locally, will sync when online';
        notifyListeners();
      }
    } else {
      _error = 'Saved locally, will sync when online';
      notifyListeners();
    }
  }

  Future<void> toggleTask(Task task) async {
    final updated = task.copyWith(
      isDone: !task.isDone,
      doneAt: !task.isDone ? DateTime.now() : null,
    );
    await _updateTaskLocal(updated);
  }

  Future<void> updateTask(Task task) async {
    await _updateTaskLocal(task);
  }

  Future<void> _updateTaskLocal(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    final currentStatus = await _localDb.getSyncStatus(task.id);
    final syncStatus = (currentStatus == 'pending_create')
        ? 'pending_create'
        : 'pending_update';

    await _localDb.upsertTask(task, syncStatus: syncStatus);

    _tasks[index] = task;
    _error = null;
    notifyListeners();

    if (isOnline) {
      try {
        await _supabaseService.updateTask(task);
        await _localDb.updateSyncStatus(task.id, 'synced');
        _error = null;
        notifyListeners();
      } catch (e) {
        _error = 'Saved locally, will sync when online';
        notifyListeners();
      }
    } else {
      _error = 'Saved locally, will sync when online';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final task = _tasks.where((t) => t.id == taskId).firstOrNull;
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();

    if (task == null) return;

    final currentStatus = await _localDb.getSyncStatus(taskId);

    if (currentStatus == 'pending_create') {
      await _localDb.deleteTask(taskId);
      return;
    }

    await _localDb.upsertTask(task, syncStatus: 'pending_delete');

    if (isOnline) {
      try {
        await _supabaseService.deleteTask(taskId);
        await _localDb.deleteTask(taskId);
      } catch (e) {
        _error = 'Will delete when online';
        notifyListeners();
      }
    } else {
      _error = 'Will delete when online';
      notifyListeners();
    }
  }

  Future<void> _sync() async {
    try {
      final pendingOps = await _localDb.getPendingOperations();
      for (final row in pendingOps) {
        final status = row['sync_status'] as String;
        final taskId = row['id'] as String;

        if (status == 'pending_delete') {
          try {
            await _supabaseService.deleteTask(taskId);
            await _localDb.deleteTask(taskId);
          } catch (_) {}
        } else {
          final task = _rowToTask(row);
          try {
            if (status == 'pending_create') {
              final serverTask = await _supabaseService.addTask(task);
              await _localDb.updateSyncStatus(taskId, 'synced');
              final index = _tasks.indexWhere((t) => t.id == taskId);
              if (index != -1) {
                _tasks[index] = serverTask;
              }
            } else if (status == 'pending_update') {
              await _supabaseService.updateTask(task);
              await _localDb.updateSyncStatus(taskId, 'synced');
            }
          } catch (_) {}
        }
      }

      await _fetchAndSubscribe(_currentFamilyCode!);
    } catch (_) {}
  }

  Future<void> refresh() async {
    if (_currentFamilyCode == null) return;
    if (isOnline) {
      await _fetchAndSubscribe(_currentFamilyCode!);
    }
  }

  Task _rowToTask(Map<String, dynamic> row) {
    return Task(
      id: row['id'] as String,
      familyCode: row['family_code'] as String,
      title: row['title'] as String,
      description: (row['description'] as String?) ?? '',
      isDone: (row['is_done'] as int?) == 1,
      assignedTo: row['assigned_to'] as String?,
      createdBy: row['created_by'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      doneAt: row['done_at'] != null
          ? DateTime.parse(row['done_at'] as String)
          : null,
      dueAt: row['due_at'] != null
          ? DateTime.parse(row['due_at'] as String)
          : null,
    );
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
