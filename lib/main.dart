import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'services/supabase_service.dart';
import 'providers/task_provider.dart';

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );

  final supabaseService = SupabaseService(Supabase.instance.client);

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: supabaseService),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(supabaseService),
        ),
      ],
      child: const FamilyTodoApp(),
    ),
  );
}
