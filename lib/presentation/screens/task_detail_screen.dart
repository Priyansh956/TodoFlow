// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/date_formatter.dart';
import '../../data/task_model.dart';
import '../task_provider.dart';
import '../widgets/common_widgets.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();
    final taskIndex = tasks.tasks.indexWhere((t) => t.id == taskId);

    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('Task not found')),
      );
    }

    final task = tasks.tasks[taskIndex];
    final isOverdue = DateFormatter.isOverdue(task.dueDate) &&
        task.status != TaskStatus.done;
    final statusColor = AppTheme.statusColor(task.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.taskEdit,
                arguments: taskId,
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.overdueColor),
            onPressed: () => _confirmDelete(context, task),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBadge(label: task.status.label, color: statusColor),
                  const SizedBox(height: 12),
                  Text(
                    task.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1, end: 0),
            const SizedBox(height: 20),
            _InfoCard(
              title: 'Description',
              icon: Icons.notes_rounded,
              child: Text(
                task.description,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.6),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Due Date',
              icon: Icons.calendar_today_rounded,
              child: Row(
                children: [
                  Text(
                    DateFormatter.formatFull(task.dueDate),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isOverdue ? AppTheme.overdueColor : null,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.overdueColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Overdue',
                        style: TextStyle(
                          color: AppTheme.overdueColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Created',
              icon: Icons.access_time_rounded,
              child: Text(
                DateFormatter.formatFull(task.createdAt),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 28),
            Text(
              'Update Status',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 12),
            Row(
              children: TaskStatus.values.map((status) {
                final isSelected = task.status == status;
                final color = AppTheme.statusColor(status);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isSelected) {
                        context
                            .read<TaskProvider>()
                            .updateTask(task.copyWith(status: status));
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          status.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected ? color : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: AppTheme.overdueColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<TaskProvider>().deleteTask(task.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}