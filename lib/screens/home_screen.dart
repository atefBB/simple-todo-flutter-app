import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/empty_state.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              if (provider.currentFamilyCode != null) {
                provider.loadTasks(provider.currentFamilyCode!);
              }
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    l10n.somethingWentWrong,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
