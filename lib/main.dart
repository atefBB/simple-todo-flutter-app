import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/connectivity_service.dart';
import 'services/local_database_service.dart';
import 'services/supabase_service.dart';
import 'providers/task_provider.dart';
import 'providers/language_provider.dart';

const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );

  SharedPreferences.getInstance();

  final supabaseService = SupabaseService(Supabase.instance.client);
  final localDb = LocalDatabaseService();
  await localDb.init();
  final connectivityService = ConnectivityService();
  await connectivityService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: supabaseService),
        Provider<LocalDatabaseService>.value(value: localDb),
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => TaskProvider(
            supabaseService: supabaseService,
            localDb: localDb,
            connectivityService: connectivityService,
          ),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider(),
        ),
      ],
      child: const FamilyTodoApp(),
    ),
  );
}
