import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generated/app_localizations.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final l10n = AppLocalizations.of(context)!;
    final isOverdue = task.dueAt != null &&
        !task.isDone &&
        task.dueAt!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => provider.toggleTask(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey : null,
          ),
        ),
        subtitle: _buildSubtitle(l10n, isOverdue),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _confirmDelete(context, provider, l10n),
        ),
        onTap: () => _showTaskDetails(context, l10n),
      ),
    );
  }

  Widget? _buildSubtitle(AppLocalizations l10n, bool isOverdue) {
    final lines = <Widget>[];

    if (task.description.isNotEmpty) {
      lines.add(
        Text(
          task.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    if (task.dueAt != null) {
      lines.add(
        Row(
          children: [
            if (isOverdue)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(Icons.warning_amber_rounded,
                    size: 14, color: Colors.red[400]),
              ),
            Text(
              l10n.dueDate(_formatDueDate(task.dueAt!)),
              style: TextStyle(
                fontSize: 12,
                color: isOverdue ? Colors.red[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (lines.isEmpty) return null;
    if (lines.length == 1) return lines.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }

  void _showTaskDetails(BuildContext context, AppLocalizations l10n) {
    final isOverdue = task.dueAt != null &&
        !task.isDone &&
        task.dueAt!.isBefore(DateTime.now());

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              task.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(task.description),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text(l10n.createdBy(task.createdBy)),
              ],
            ),
            if (task.dueAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning_amber_rounded : Icons.event,
                    size: 16,
                    color: isOverdue ? Colors.red[400] : null,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.dueDate(_formatDueDate(task.dueAt!)),
                    style: TextStyle(
                      color: isOverdue ? Colors.red[400] : null,
                      fontWeight: isOverdue ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ],
            if (task.doneAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(l10n.doneDate(_formatDate(task.doneAt!))),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text(l10n.createdDate(_formatDate(task.createdAt))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, TaskProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTask),
        content: Text(l10n.deleteConfirm(task.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.pop(context);
            },
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $hour:$minute';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
