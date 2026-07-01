import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';

import 'db_factory.dart';
import '../models/task.dart';

class LocalDatabaseService {
  Database? _db;

  Future<void> init() async {
    final factory = databaseFactory;
    if (kIsWeb) {
      _db = await factory.openDatabase('todo_cache');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _db = await factory.openDatabase(p.join(dir.path, 'todo_cache.db'));
    }
  }

  StoreRef<String, Map<String, dynamic>> get _store =>
      StoreRef<String, Map<String, dynamic>>('tasks');

  Future<List<Task>> getTasks(String familyCode) async {
    final records = await _store.find(
      _db!,
      finder: Finder(
        filter: Filter.and([
          Filter.equals('family_code', familyCode),
          Filter.notEquals('sync_status', 'pending_delete'),
        ]),
        sortOrders: [SortOrder('created_at')],
      ),
    );
    return records.map((r) => _rowToTask(r.value)).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    final records = await _store.find(
      _db!,
      finder: Finder(
        filter: Filter.notEquals('sync_status', 'synced'),
        sortOrders: [SortOrder('created_at')],
      ),
    );
    return records.map((r) => r.value).toList();
  }

  Future<void> upsertTask(Task task, {String syncStatus = 'synced'}) async {
    await _store.record(task.id).put(_db!, _taskToRow(task, syncStatus));
  }

  Future<void> updateSyncStatus(String taskId, String status) async {
    final record = await _store.record(taskId).get(_db!);
    if (record != null) {
      record['sync_status'] = status;
      await _store.record(taskId).put(_db!, record);
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _store.record(taskId).delete(_db!);
  }

  Future<void> replaceAllTasks(String familyCode, List<Task> tasks) async {
    await _db!.transaction((txn) async {
      final records = await _store.find(
        txn,
        finder: Finder(filter: Filter.equals('family_code', familyCode)),
      );
      for (final r in records) {
        await _store.record(r.key).delete(txn);
      }
      for (final task in tasks) {
        await _store.record(task.id).put(txn, _taskToRow(task, 'synced'));
      }
    });
  }

  Future<String?> getSyncStatus(String taskId) async {
    final record = await _store.record(taskId).get(_db!);
    return record?['sync_status'] as String?;
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

  Map<String, dynamic> _taskToRow(Task task, String syncStatus) {
    return {
      'id': task.id,
      'family_code': task.familyCode,
      'title': task.title,
      'description': task.description,
      'is_done': task.isDone ? 1 : 0,
      'assigned_to': task.assignedTo,
      'created_by': task.createdBy,
      'created_at': task.createdAt.toIso8601String(),
      'done_at': task.doneAt?.toIso8601String(),
      'due_at': task.dueAt?.toIso8601String(),
      'sync_status': syncStatus,
    };
  }

  Future<void> close() async {
    await _db?.close();
  }
}
