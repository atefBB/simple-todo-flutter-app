import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'generated/app_localizations.dart';
import 'providers/language_provider.dart';
import 'screens/language_selection_screen.dart';
import 'screens/setup_screen.dart';

class FamilyTodoApp extends StatefulWidget {
  const FamilyTodoApp({super.key});

  @override
  State<FamilyTodoApp> createState() => _FamilyTodoAppState();
}

class _FamilyTodoAppState extends State<FamilyTodoApp> {
  @override
  void initState() {
    super.initState();
    context.read<LanguageProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

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
      home: langProvider.initialized
          ? (langProvider.languageSelected
              ? const SetupScreen()
              : const LanguageSelectionScreen())
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
