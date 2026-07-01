import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/task.dart';

class LocalDatabaseService {
  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo_cache.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            family_code TEXT NOT NULL,
            title TEXT NOT NULL,
            description TEXT DEFAULT '',
            is_done INTEGER DEFAULT 0,
            assigned_to TEXT,
            created_by TEXT NOT NULL,
            created_at TEXT NOT NULL,
            done_at TEXT,
            due_at TEXT,
            sync_status TEXT NOT NULL DEFAULT 'synced'
          )
        ''');
      },
    );
  }

  Future<List<Task>> getTasks(String familyCode) async {
    final rows = await _db!.query(
      'tasks',
      where: 'family_code = ? AND sync_status != ?',
      whereArgs: [familyCode, 'pending_delete'],
      orderBy: 'created_at ASC',
    );
    return rows.map(_rowToTask).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    return _db!.query(
      'tasks',
      where: 'sync_status != ?',
      whereArgs: ['synced'],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> upsertTask(Task task, {String syncStatus = 'synced'}) async {
    await _db!.insert(
      'tasks',
      _taskToRow(task, syncStatus),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSyncStatus(String taskId, String status) async {
    await _db!.update(
      'tasks',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _db!.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  Future<void> replaceAllTasks(String familyCode, List<Task> tasks) async {
    await _db!.transaction((txn) async {
      await txn.delete('tasks', where: 'family_code = ?', whereArgs: [familyCode]);
      for (final task in tasks) {
        await txn.insert('tasks', _taskToRow(task, 'synced'));
      }
    });
  }

  Future<String?> getSyncStatus(String taskId) async {
    final rows = await _db!.query(
      'tasks',
      columns: ['sync_status'],
      where: 'id = ?',
      whereArgs: [taskId],
    );
    if (rows.isEmpty) return null;
    return rows.first['sync_status'] as String;
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
