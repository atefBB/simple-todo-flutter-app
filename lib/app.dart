import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'generated/app_localizations.dart';
import 'providers/language_provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/setup_screen.dart';

class FamilyTodoApp extends StatefulWidget {
  const FamilyTodoApp({super.key});

  @override
  State<FamilyTodoApp> createState() => _FamilyTodoAppState();
}

class _FamilyTodoAppState extends State<FamilyTodoApp> {
  bool _hasFamily = false;
  bool _checkedFamily = false;

  @override
  void initState() {
    super.initState();
    context.read<LanguageProvider>().load();
    _checkStoredFamily();
  }

  Future<void> _checkStoredFamily() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('family_code');
    if (code != null && mounted) {
      context.read<TaskProvider>().setFamilyCode(code);
      if (mounted) {
        setState(() {
          _hasFamily = true;
          _checkedFamily = true;
        });
      }
    } else if (mounted) {
      setState(() => _checkedFamily = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    Widget home;
    if (!langProvider.initialized || !_checkedFamily) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (!langProvider.languageSelected) {
      home = const LanguageSelectionScreen();
    } else if (_hasFamily) {
      home = const HomeScreen();
    } else {
      home = const SetupScreen();
    }

    return MaterialApp(
      title: 'Family Todo',
      debugShowCheckedModeBanner: false,
      locale: langProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: home,
    );
  }
}
