// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../core/app_constants.dart';
import '../../data/task_model.dart';
import '../../presentation/auth_provider.dart';
import '../../presentation//task_provider.dart';
import '../../presentation//theme_provider.dart';
import '../../presentation/widgets/common_widgets.dart';
import '../../presentation/widgets/task_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _loadTasks({bool refresh = false}) {
    final userId = context.read<AuthProvider>().user?.uid ?? '';
    context.read<TaskProvider>().loadTasks(userId, refresh: refresh);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final userId = context.read<AuthProvider>().user?.uid ?? '';
      context.read<TaskProvider>().loadMore(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.appName),
            Text(
              'Hi, ${auth.user?.name.split(' ').first ?? 'there'} 👋',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              theme.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: theme.toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await auth.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            tooltip: 'Sign out',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildStatsRow(tasks),
          _buildFilterBar(tasks),
          Expanded(child: _buildBody(tasks)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result =
          await Navigator.pushNamed(context, AppRoutes.taskNew);
          if (result == true) _loadTasks(refresh: true);
        },
        child: const Icon(Icons.add_rounded),
      ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildStatsRow(TaskProvider tasks) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _StatChip(
            label: 'To Do',
            count: tasks.todoCount,
            color: AppTheme.todoColor,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'In Progress',
            count: tasks.inProgressCount,
            color: AppTheme.inProgressColor,
          ),
          const SizedBox(width: 10),
          _StatChip(
            label: 'Done',
            count: tasks.doneCount,
            color: AppTheme.doneColor,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildFilterBar(TaskProvider tasks) {
    final statuses = [null, TaskStatus.todo, TaskStatus.inProgress, TaskStatus.done];
    final labels = ['All', 'To Do', 'In Progress', 'Done'];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = tasks.filterStatus == statuses[i];
          return FilterChip(
            label: Text(labels[i]),
            selected: isSelected,
            onSelected: (_) => tasks.setFilter(statuses[i]),
            selectedColor: AppTheme.primaryLight,
            checkmarkColor: AppTheme.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppTheme.primary : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            side: BorderSide(
              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(TaskProvider tasks) {
    switch (tasks.state) {
      case TaskViewState.loading:
        return const TaskListSkeleton();

      case TaskViewState.error:
        return ErrorState(
          message: tasks.errorMessage ?? 'Something went wrong.',
          onRetry: () => _loadTasks(refresh: true),
        );

      case TaskViewState.empty:
        return EmptyState(
          icon: Icons.task_alt_rounded,
          title: tasks.filterStatus != null
              ? 'No ${tasks.filterStatus!.label} tasks'
              : 'No tasks yet',
          subtitle: tasks.filterStatus != null
              ? 'Tasks with this status will appear here.'
              : 'Tap the + button to create your first task.',
          actionLabel: tasks.filterStatus == null ? 'Create Task' : null,
          onAction: () =>
              Navigator.pushNamed(context, AppRoutes.taskNew),
        );

      case TaskViewState.loaded:
      default:
        return RefreshIndicator(
          onRefresh: () async => _loadTasks(refresh: true),
          color: AppTheme.primary,
          child: ListView.separated(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: tasks.tasks.length + (tasks.isFetchingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == tasks.tasks.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return TaskCard(task: tasks.tasks[index], index: index);
            },
          ),
        );
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}