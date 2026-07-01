import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TaskProvider>();
      if (provider.currentFamilyCode != null && provider.tasks.isEmpty) {
        provider.loadTasks(provider.currentFamilyCode!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = context.read<TaskProvider>();
              provider.refresh();
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tasks.isEmpty && provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Offline',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No cached tasks available',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (provider.tasks.isEmpty) {
            return const EmptyState();
          }

          final tasks = provider.tasks;
          final pendingTasks = tasks.where((t) => !t.isDone).toList();
          final completedTasks = tasks.where((t) => t.isDone).toList();

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!provider.isOnline)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off, size: 18, color: Colors.orange[800]),
                        const SizedBox(width: 8),
                        Text(
                          'You are offline - changes will sync when online',
                          style: TextStyle(fontSize: 13, color: Colors.orange[900]),
                        ),
                      ],
                    ),
                  ),
                if (pendingTasks.isNotEmpty) ...[
                  Text(
                    l10n.toDo(pendingTasks.length),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...pendingTasks.map(
                    (task) => TaskCard(task: task),
                  ),
                ],
                if (completedTasks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.completed(completedTasks.length),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...completedTasks.map(
                    (task) => TaskCard(task: task),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
