// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../presentation//auth_provider.dart';
import '../../presentation//task_provider.dart';
import '../../../config/app_theme.dart';
import '../../../core/validators.dart';
import '../../../data/task_model.dart';
import '../../presentation/widgets/common_widgets.dart';

class TaskFormScreen extends StatefulWidget {
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});

  bool get isEditing => taskId != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskStatus _status = TaskStatus.todo;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  Task? _existingTask;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadExistingTask();
  }

  void _loadExistingTask() {
    final tasks = context.read<TaskProvider>();
    _existingTask = tasks.tasks.firstWhere(
          (t) => t.id == widget.taskId,
      orElse: () => throw Exception('Task not found'),
    );
    _titleCtrl.text = _existingTask!.title;
    _descCtrl.text = _existingTask!.description;
    _status = _existingTask!.status;
    _dueDate = _existingTask!.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppTheme.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final tasks = context.read<TaskProvider>();
    final userId = context.read<AuthProvider>().user!.uid;

    bool success;
    if (widget.isEditing) {
      success = await tasks.updateTask(
        _existingTask!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          status: _status,
          dueDate: _dueDate,
        ),
      );
    } else {
      success = await tasks.createTask(
        userId: userId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        status: _status,
        dueDate: _dueDate,
      );
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing
              ? 'Task updated successfully!'
              : 'Task created successfully!'),
          backgroundColor: AppTheme.doneColor,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tasks.errorMessage ?? 'Something went wrong'),
          backgroundColor: AppTheme.overdueColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Task Title',
                hint: 'What needs to be done?',
                controller: _titleCtrl,
                validator: Validators.taskTitle,
                maxLength: 100,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                hint: 'Add details about this task...',
                controller: _descCtrl,
                validator: Validators.taskDescription,
                maxLines: 4,
                maxLength: 500,
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Status').animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 10),
              _buildStatusSelector().animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 20),
              const _SectionLabel(label: 'Due Date').animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 10),
              _buildDatePicker().animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 32),
              AppButton(
                label: widget.isEditing ? 'Update Task' : 'Create Task',
                onPressed: _submit,
                isLoading: tasks.isSubmitting,
                icon: widget.isEditing
                    ? Icons.check_rounded
                    : Icons.add_circle_outline_rounded,
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: TaskStatus.values.map((status) {
        final isSelected = _status == status;
        final color = AppTheme.statusColor(status);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _status = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: isSelected ? color : Colors.grey,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? color : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePicker() {
    final formatted = DateFormat('EEE, MMM d, yyyy').format(_dueDate);
    final isOverdue = _dueDate.isBefore(DateTime.now());

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue
                ? AppTheme.overdueColor.withOpacity(0.5)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: isOverdue ? AppTheme.overdueColor : AppTheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                formatted,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isOverdue ? AppTheme.overdueColor : null,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
      ),
    );
  }
}