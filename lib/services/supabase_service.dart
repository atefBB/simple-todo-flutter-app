import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/family_member.dart';
import '../models/task.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  SupabaseClient get client => _client;

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AuthResponse> signInAnonymously() {
    return _client.auth.signInAnonymously();
  }

  String? get currentUserId => _client.auth.currentUser?.id;

  // ── Families ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getFamily(String code) async {
    final data = await _client
        .from('families')
        .select()
        .eq('code', code)
        .maybeSingle();
    return data;
  }

  Future<void> createFamily(String code, String name, List<FamilyMember> members) async {
    await _client.from('families').insert({
      'code': code,
      'name': name,
      'members': members.map((m) => m.toJson()).toList(),
    });
  }

  Future<void> joinFamily(String code, FamilyMember member) async {
    final family = await getFamily(code);
    if (family == null) throw Exception('Family not found');

    final members = (family['members'] as List<dynamic>)
        .map((m) => FamilyMember.fromJson(m as Map<String, dynamic>))
        .toList();

    // Don't add if already a member
    if (members.any((m) => m.uid == member.uid)) return;

    members.add(member);
    await _client
        .from('families')
        .update({'members': members.map((m) => m.toJson()).toList()})
        .eq('code', code);
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  Future<List<Task>> getTasks(String familyCode) async {
    final data = await _client
        .from('tasks')
        .select()
        .eq('family_code', familyCode)
        .order('created_at');
    return (data as List<dynamic>)
        .map((json) => Task.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  StreamSubscription<List<Map<String, dynamic>>> subscribeToTasks(
    String familyCode,
    Function(List<Task>) onUpdate,
  ) {
    final stream = _client
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('family_code', familyCode)
        .order('created_at');
    return stream.listen((data) {
      final tasks = data
          .map((json) => Task.fromJson(json))
          .toList();
      onUpdate(tasks);
    });
  }

  Future<Task> addTask(Task task) async {
    final data = await _client
        .from('tasks')
        .insert(task.toJson())
        .select()
        .single();
    return Task.fromJson(data);
  }

  Future<void> updateTask(Task task) async {
    await _client
        .from('tasks')
        .update(task.toUpdateMap())
        .eq('id', task.id);
  }

  Future<void> deleteTask(String taskId) async {
    await _client
        .from('tasks')
        .delete()
        .eq('id', taskId);
  }
}
