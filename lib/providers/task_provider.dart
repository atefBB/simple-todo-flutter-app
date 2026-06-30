import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/supabase_service.dart';

class TaskProvider extends ChangeNotifier {
  final SupabaseService _supabaseService;
  List<Task> _tasks = [];
  String? _currentFamilyCode;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Map<String, dynamic>>>? _taskSubscription;

  TaskProvider(this._supabaseService);

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentFamilyCode => _currentFamilyCode;

  void setFamilyCode(String code) {
    _currentFamilyCode = code;
  }

  Future<void> loadTasks(String familyCode) async {
    _isLoading = true;
    _currentFamilyCode = familyCode;
    notifyListeners();

    try {
      _tasks = await _supabaseService.getTasks(familyCode);
      _error = null;

      // Cancel any existing subscription before creating a new one
      await _taskSubscription?.cancel();

      // Subscribe to realtime updates
      _taskSubscription = _supabaseService.subscribeToTasks(familyCode, (updatedTasks) {
        _tasks = updatedTasks;
        _error = null;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    if (_currentFamilyCode == null) return;

    try {
      final newTask = await _supabaseService.addTask(task);
      _tasks.add(newTask);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleTask(Task task) async {
    try {
      final updated = task.copyWith(
        isDone: !task.isDone,
        doneAt: !task.isDone ? DateTime.now() : null,
      );
      await _supabaseService.updateTask(updated);
      // The realtime subscription will update the local list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _supabaseService.updateTask(task);
      _error = null;
      // The realtime subscription will update the local list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _supabaseService.deleteTask(taskId);
      _error = null;
      // The realtime subscription will update the local list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }
}
