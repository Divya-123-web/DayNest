import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_colors.dart';

/// The Calendar tab: month/week calendar plus the tasks of the selected day.
/// The tasks come from TaskProvider, so every screen shares the same data.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Jumps back to today.
  void _goToToday() {
    final DateTime now = DateTime.now();
    setState(() {
      _focusedDay = now;
      _selectedDay = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    // watch: this screen rebuilds whenever the tasks change anywhere.
    final TaskProvider taskProvider = context.watch<TaskProvider>();
    final List<TaskModel> dayTasks = taskProvider.tasksForDay(_selectedDay);
    final String dayLabel = DateFormat('EEEE, d MMMM').format(_selectedDay);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with a "Today" shortcut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Calendar',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _goToToday,
                    icon: const Icon(Icons.today_rounded, size: 18),
                    label: const Text('Today'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // The calendar card
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: TableCalendar<TaskModel>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                    CalendarFormat.week: 'Week',
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rowHeight: 46,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  // Gives the calendar the tasks of each day (for the dots).
                  eventLoader: taskProvider.tasksForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() => _calendarFormat = format);
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: true,
                    formatButtonShowsNext: false,
                    titleTextStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBrown,
                    ),
                    formatButtonTextStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.terracotta,
                    ),
                    formatButtonDecoration: BoxDecoration(
                      color: AppColors.lightApricot,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    formatButtonPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    leftChevronIcon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.darkBrown,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    weekendStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.terracotta,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.darkBrown,
                    ),
                    weekendTextStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.darkBrown,
                    ),
                    todayTextStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBrown,
                    ),
                    selectedTextStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                    todayDecoration: const BoxDecoration(
                      color: AppColors.peach,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.terracotta,
                      shape: BoxShape.circle,
                    ),
                    // Small dots under dates that contain tasks
                    markerDecoration: const BoxDecoration(
                      color: AppColors.darkBrown,
                      shape: BoxShape.circle,
                    ),
                    markerSize: 5,
                    markersMaxCount: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Selected day heading
              Text(
                dayLabel,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dayTasks.isEmpty
                    ? 'Nothing scheduled'
                    : '${dayTasks.length} ${dayTasks.length == 1 ? 'task' : 'tasks'} scheduled',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // The day's tasks, or an empty state
              if (dayTasks.isEmpty)
                const _EmptyDay()
              else
                ...dayTasks.map(
                  (task) => _ScheduleTile(
                    key: ValueKey(task.id),
                    task: task,
                    onToggle: () =>
                        context.read<TaskProvider>().toggleTask(task.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One scheduled task: time on the left, card on the right.
class _ScheduleTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;

  const _ScheduleTile({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 68,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                DateFormat('h:mm a').format(task.dueDate),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Task card
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
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
                  // Priority bar
                  Container(
                    width: 5,
                    height: 44,
                    decoration: BoxDecoration(
                      color: task.priority.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDone
                                ? AppColors.textSecondary
                                : AppColors.darkBrown,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${task.category}  •  ${task.priority.label}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Complete / undo button
                  IconButton(
                    onPressed: onToggle,
                    tooltip: isDone ? 'Mark as pending' : 'Mark as completed',
                    icon: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: isDone
                          ? AppColors.terracotta
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Friendly message shown when the selected day has no tasks.
class _EmptyDay extends StatelessWidget {
  const _EmptyDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.lightApricot,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available_rounded,
            size: 44,
            color: AppColors.terracotta,
          ),
          const SizedBox(height: 10),
          Text(
            'A free day',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'No tasks on this date.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}