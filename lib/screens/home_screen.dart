import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';

/// Simple holder for a sample task shown in "Upcoming Tasks".
/// TEMPORARY: replaced by the real TaskModel in Phase 3.
class _SampleTask {
  final String title;
  final String time;
  final String category;
  final Color priorityColor;

  const _SampleTask({
    required this.title,
    required this.time,
    required this.category,
    required this.priorityColor,
  });
}

/// Home dashboard: greeting, date, progress, quick actions,
/// motivation and upcoming tasks.
/// [onTabChange] lets this screen switch the bottom navigation tab.
class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  // TEMPORARY sample data (replaced by Provider data in Phase 3).
  static const String _userName = 'Alex';
  static const int _totalTasks = 5;
  static const int _completedTasks = 3;

  static const List<_SampleTask> _upcomingTasks = [
    _SampleTask(
      title: 'Submit internship report',
      time: 'Today, 5:00 PM',
      category: 'Work',
      priorityColor: AppColors.priorityHigh,
    ),
    _SampleTask(
      title: 'Buy groceries',
      time: 'Today, 7:30 PM',
      category: 'Personal',
      priorityColor: AppColors.priorityMedium,
    ),
    _SampleTask(
      title: 'Read 20 pages of a book',
      time: 'Tomorrow, 9:00 PM',
      category: 'Study',
      priorityColor: AppColors.priorityLow,
    ),
  ];

  // Returns a greeting based on the time of day.
  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final int pending = _totalTasks - _completedTasks;
    final double progress = _totalTasks == 0 ? 0 : _completedTasks / _totalTasks;
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
                        '${_greeting()}, $_userName 👋',
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
                GestureDetector(
                  onTap: () => onTabChange(4),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.peach,
                    child: Text(
                      _userName[0].toUpperCase(),
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
              completed: _completedTasks,
              total: _totalTasks,
              progress: progress,
            ),
            const SizedBox(height: 16),

            // Pending and completed counters
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.pending_actions_rounded,
                    label: 'Pending',
                    value: pending,
                    iconColor: AppColors.priorityMedium,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.task_alt_rounded,
                    label: 'Completed',
                    value: _completedTasks,
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
                    // Opens the Tasks tab for now.
                    onTap: () => onTabChange(1),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.note_add_rounded,
                    label: 'Add Note',
                    isPrimary: false,
                    // Opens the Notes tab for now.
                    onTap: () => onTabChange(3),
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

            // Upcoming tasks preview
            ..._upcomingTasks.map((task) => _UpcomingTaskTile(task: task)),
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
                  '$completed of $total tasks done',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  total - completed == 0
                      ? 'All done. Great job!'
                      : "You're doing great, keep going!",
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
          Column(
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
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
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

/// One row in the "Upcoming Tasks" list.
class _UpcomingTaskTile extends StatelessWidget {
  final _SampleTask task;

  const _UpcomingTaskTile({required this.task});

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
              color: task.priorityColor,
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
                      task.time,
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