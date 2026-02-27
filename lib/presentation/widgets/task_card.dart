// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/app_routes.dart';
import '../../../config/app_theme.dart';
import '../../../core/date_formatter.dart';
import '../../../data/task_model.dart';
import '../../presentation//task_provider.dart';
import '../../presentation/widgets/common_widgets.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final int index;

  const TaskCard({super.key, required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    final isOverdue = DateFormatter.isOverdue(task.dueDate) &&
        task.status != TaskStatus.done;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      background: _deleteBackground(),
      child: Card(
        child: InkWell(
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.taskDetail, arguments: task.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.status == TaskStatus.done
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.status == TaskStatus.done
                              ? Colors.grey
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusDot(status: task.status),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatusBadge(
                      label: task.status.label,
                      color: AppTheme.statusColor(task.status),
                    ),
                    const Spacer(),
                    Icon(
                      isOverdue
                          ? Icons.warning_amber_rounded
                          : Icons.calendar_today_rounded,
                      size: 14,
                      color: isOverdue
                          ? AppTheme.overdueColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOverdue
                          ? 'Overdue · ${DateFormatter.format(task.dueDate)}'
                          : DateFormatter.format(task.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isOverdue ? AppTheme.overdueColor : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(
        delay: Duration(milliseconds: 60 * index),
        duration: 300.ms,
      ).slideX(begin: 0.1, end: 0),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content:
        Text('Are you sure you want to delete "${task.title}"?'),
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
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<TaskProvider>().deleteTask(task.id);
      }
      return confirmed;
    });
  }

  Widget _deleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppTheme.overdueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_rounded, color: AppTheme.overdueColor),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final TaskStatus status;

  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppTheme.statusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }
}