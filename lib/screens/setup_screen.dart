import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../generated/app_localizations.dart';
import '../models/family_member.dart';
import '../providers/task_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/family_code_dialog.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  String _generateFamilyCode() {
    return const Uuid().v4().substring(0, 6).toUpperCase();
  }

  Future<void> _createFamily() async {
    final l10n = AppLocalizations.of(context)!;
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final supabase = context.read<SupabaseService>();
      await supabase.signInAnonymously();
      final uid = supabase.currentUserId;
      if (uid == null) throw Exception('Failed to get user ID');

      final code = _generateFamilyCode();
      final member = FamilyMember(uid: uid, nickname: nickname);
      await supabase.createFamily(code, 'My Family', [member]);

      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('family_code', code);

      final taskProvider = context.read<TaskProvider>();
      taskProvider.setFamilyCode(code);
      await taskProvider.loadTasks(code);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorPrefix(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinFamily() async {
    final l10n = AppLocalizations.of(context)!;
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    final code = await showDialog<String>(
      context: context,
      builder: (_) => const FamilyCodeDialog(),
    );

    if (code == null || code.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final supabase = context.read<SupabaseService>();
      await supabase.signInAnonymously();
      final uid = supabase.currentUserId;
      if (uid == null) throw Exception('Failed to get user ID');

      final member = FamilyMember(uid: uid, nickname: nickname);
      await supabase.joinFamily(code, member);

      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('family_code', code);

      final taskProvider = context.read<TaskProvider>();
      taskProvider.setFamilyCode(code);
      await taskProvider.loadTasks(code);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorPrefix(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.welcome,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pickNickname,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: l10n.yourNickname,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createFamily,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.createFamily),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _joinFamily,
                  child: Text(l10n.joinFamily),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
