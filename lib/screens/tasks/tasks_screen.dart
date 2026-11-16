import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/task_card.dart';
import 'task_form_screen.dart';

/// The filters shown as chips above the list.
enum TaskFilter { all, today, upcoming, completed }

extension TaskFilterX on TaskFilter {
  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.today:
        return 'Today';
      case TaskFilter.upcoming:
        return 'Upcoming';
      case TaskFilter.completed:
        return 'Completed';
    }
  }
}

/// The Tasks tab: search, filters, list, add, edit, complete and delete.
/// The tasks come from TaskProvider, so every screen shares the same data.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  TaskFilter _filter = TaskFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // True when two dates fall on the same calendar day.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // The tasks to show, after applying the filter and the search.
  List<TaskModel> _visibleTasks(List<TaskModel> allTasks) {
    final DateTime now = DateTime.now();
    final DateTime startOfTomorrow = DateTime(now.year, now.month, now.day + 1);
    final String query = _searchQuery.trim().toLowerCase();

    final List<TaskModel> list = allTasks.where((task) {
      // 1. Filter
      bool matchesFilter;
      switch (_filter) {
        case TaskFilter.all:
          matchesFilter = true;
          break;
        case TaskFilter.today:
          matchesFilter = _isSameDay(task.dueDate, now);
          break;
        case TaskFilter.upcoming:
          matchesFilter =
              !task.isCompleted && !task.dueDate.isBefore(startOfTomorrow);
          break;
        case TaskFilter.completed:
          matchesFilter = task.isCompleted;
          break;
      }
      if (!matchesFilter) return false;

      // 2. Search (title or description)
      if (query.isEmpty) return true;
      return task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
    }).toList();

    // Pending tasks first (soonest due first), completed tasks last.
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      return a.dueDate.compareTo(b.dueDate);
    });

    return list;
  }

  // Opens the form to add a task (task == null) or edit one.
  Future<void> _openForm({TaskModel? task}) async {
    final TaskModel? result = await Navigator.of(context).push<TaskModel>(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );

    if (result == null || !mounted) return;

    final TaskProvider provider = context.read<TaskProvider>();
    if (task == null) {
      provider.addTask(result);
    } else {
      provider.updateTask(result);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(task == null ? 'Task added' : 'Task updated')),
    );
  }

  // Asks for confirmation, then deletes the task.
  Future<void> _confirmDelete(TaskModel task) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.warmCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Delete task?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrown,
            ),
          ),
          content: Text(
            '"${task.title}" will be removed permanently.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.priorityHigh,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    context.read<TaskProvider>().deleteTask(task.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch: this screen rebuilds whenever the tasks change anywhere.
    final TaskProvider taskProvider = context.watch<TaskProvider>();
    final List<TaskModel> visibleTasks = _visibleTasks(taskProvider.tasks);
    final int pendingCount = taskProvider.pendingCount;

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Task',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Tasks',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pendingCount == 0
                        ? 'Nothing pending. Enjoy your day!'
                        : '$pendingCount pending ${pendingCount == 1 ? 'task' : 'tasks'}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.darkBrown,
                ),
                decoration: InputDecoration(
                  hintText: 'Search tasks',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.terracotta,
                  ),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Filter chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: TaskFilter.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final TaskFilter filter = TaskFilter.values[index];
                  final bool isSelected = filter == _filter;

                  return ChoiceChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _filter = filter),
                    selectedColor: AppColors.terracotta,
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.terracotta
                          : AppColors.softBeige,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? AppColors.white : AppColors.darkBrown,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Task list or empty state
            Expanded(
              child: visibleTasks.isEmpty
                  ? _EmptyState(
                      isSearching: _searchQuery.trim().isNotEmpty,
                      filter: _filter,
                    )
                  : ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                      itemCount: visibleTasks.length,
                      itemBuilder: (context, index) {
                        final TaskModel task = visibleTasks[index];
                        return TaskCard(
                          key: ValueKey(task.id),
                          task: task,
                          onToggle: () => context
                              .read<TaskProvider>()
                              .toggleTask(task.id),
                          onTap: () => _openForm(task: task),
                          onDelete: () => _confirmDelete(task),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Friendly message shown when no task matches.
class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final TaskFilter filter;

  const _EmptyState({required this.isSearching, required this.filter});

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    IconData icon;

    if (isSearching) {
      title = 'No results found';
      message = 'Try a different word.';
      icon = Icons.search_off_rounded;
    } else {
      switch (filter) {
        case TaskFilter.all:
          title = 'No tasks yet';
          message = 'Tap "New Task" to plan your day.';
          icon = Icons.checklist_rounded;
          break;
        case TaskFilter.today:
          title = 'Nothing due today';
          message = 'Enjoy the free time or add a task.';
          icon = Icons.wb_sunny_rounded;
          break;
        case TaskFilter.upcoming:
          title = 'No upcoming tasks';
          message = 'Tasks due after today appear here.';
          icon = Icons.event_available_rounded;
          break;
        case TaskFilter.completed:
          title = 'No completed tasks';
          message = 'Finished tasks will show up here.';
          icon = Icons.task_alt_rounded;
          break;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.lightApricot,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 46, color: AppColors.terracotta),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}