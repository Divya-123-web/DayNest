import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/note_model.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/note_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_colors.dart';
import '../notes/note_editor_screen.dart';
import '../tasks/task_form_screen.dart';

/// Home dashboard: greeting, date, progress, quick actions,
/// motivation and upcoming tasks. All numbers come from the providers.
/// [onTabChange] lets this screen switch the bottom navigation tab.
class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  // Returns a greeting based on the time of day.
  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // Writes a due date as "Today, 5:00 PM", "Tomorrow, 9:00 AM" or "12 Nov, 5:00 PM".
  String _formatDue(DateTime due) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime dueDay = DateTime(due.year, due.month, due.day);
    final int diff = dueDay.difference(today).inDays;
    final String time = DateFormat('h:mm a').format(due);

    if (diff == 0) return 'Today, $time';
    if (diff == 1) return 'Tomorrow, $time';
    if (diff < 0) return '${DateFormat('d MMM').format(due)}, $time';
    return '${DateFormat('d MMM').format(due)}, $time';
  }

  // Opens the task form and saves the new task.
  Future<void> _addTask(BuildContext context) async {
    final TaskModel? result = await Navigator.of(context).push<TaskModel>(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (result == null || !context.mounted) return;

    context.read<TaskProvider>().addTask(result);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task added')),
    );
  }

  // Opens the note editor and saves the new note.
  Future<void> _addNote(BuildContext context) async {
    final NoteModel? result = await Navigator.of(context).push<NoteModel>(
      MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
    );
    if (result == null || !context.mounted) return;

    context.read<NoteProvider>().addNote(result);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch: the dashboard updates whenever tasks or the user change.
    final AuthProvider auth = context.watch<AuthProvider>();
    final TaskProvider taskProvider = context.watch<TaskProvider>();

    final String userName = auth.user?.name ?? 'Friend';
    final String userInitial = auth.user?.initial ?? 'D';

    final int todayTotal = taskProvider.todayTotal;
    final int todayCompleted = taskProvider.todayCompleted;
    final int todayPending = todayTotal - todayCompleted;
    final double progress = todayTotal == 0 ? 0 : todayCompleted / todayTotal;

    final List<TaskModel> upcoming = taskProvider.upcomingTasks(limit: 3);
    final String today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting row with avatar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_greeting()}, $userName 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        today,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => onTabChange(4),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.peach,
                    child: Text(
                      userInitial,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's progress card
            _ProgressCard(
              completed: todayCompleted,
              total: todayTotal,
              progress: progress,
            ),
            const SizedBox(height: 16),

            // Pending and completed counters (for today)
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending',
                    value: todayPending,
                    iconColor: AppColors.priorityMedium,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.task_alt_rounded,
                    label: 'Completed',
                    value: todayCompleted,
                    iconColor: AppColors.priorityLow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.add_task_rounded,
                    label: 'Add Task',
                    isPrimary: true,
                    onTap: () => _addTask(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.note_add_rounded,
                    label: 'Add Note',
                    isPrimary: false,
                    onTap: () => _addNote(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Motivational card
            const _MotivationCard(),
            const SizedBox(height: 28),

            // Upcoming tasks header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Tasks',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBrown,
                  ),
                ),
                TextButton(
                  onPressed: () => onTabChange(1),
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Upcoming tasks preview, or a friendly message
            if (upcoming.isEmpty)
              const _AllCaughtUp()
            else
              ...upcoming.map(
                (task) => _UpcomingTaskTile(
                  task: task,
                  timeText: _formatDue(task.dueDate),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Large terracotta card with a circular progress indicator.
class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final int percent = (progress * 100).round();

    String headline;
    String subtitle;
    if (total == 0) {
      headline = 'No tasks today';
      subtitle = 'Add a task to plan your day.';
    } else if (completed == total) {
      headline = '$completed of $total tasks done';
      subtitle = 'All done. Great job!';
    } else {
      headline = '$completed of $total tasks done';
      subtitle = "You're doing great, keep going!";
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.terracotta, Color(0xFFB36D42)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's progress",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.lightApricot,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  headline,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.lightApricot,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: AppColors.white,
                    backgroundColor: const Color(0x40FFFFFF),
                  ),
                ),
                Text(
                  '$percent%',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small white card showing one number (pending or completed).
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.softBeige,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBrown,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded button used for "Add Task" and "Add Note".
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.darkBrown : AppColors.peach,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isPrimary ? AppColors.white : AppColors.darkBrown,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? AppColors.white : AppColors.darkBrown,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft apricot card with a motivational message.
class _MotivationCard extends StatelessWidget {
  const _MotivationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightApricot,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.format_quote_rounded,
            size: 36,
            color: AppColors.terracotta,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Small steps every day lead to big results.',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Daily motivation',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when there are no pending tasks.
class _AllCaughtUp extends StatelessWidget {
  const _AllCaughtUp();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration_rounded,
            size: 40,
            color: AppColors.terracotta,
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up!",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBrown,
            ),
          ),
          Text(
            'No pending tasks.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// One row in the "Upcoming Tasks" list.
class _UpcomingTaskTile extends StatelessWidget {
  final TaskModel task;
  final String timeText;

  const _UpcomingTaskTile({required this.task, required this.timeText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Coloured bar showing the priority
          Container(
            width: 5,
            height: 44,
            decoration: BoxDecoration(
              color: task.priority.color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.softBeige,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              task.category,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}