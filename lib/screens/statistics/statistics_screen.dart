import 'package:daynest/theme/app-colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../theme/app_colors.dart';

/// Productivity statistics: totals, completion percentage
/// and a weekly bar chart drawn with fl_chart.
/// All numbers come from TaskProvider, so they match the other screens.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch: the numbers and the chart update whenever tasks change.
    final TaskProvider taskProvider = context.watch<TaskProvider>();

    final int totalTasks = taskProvider.totalCount;
    final int completedTasks = taskProvider.completedCount;
    final int pendingTasks = taskProvider.pendingCount;
    final double completionRate = taskProvider.completionRate;

    // Tasks completed on each of the last 7 days (today is the last one).
    final List<int> weeklyCompleted = taskProvider.weeklyCompleted;

    // Day names for the last 7 days, ending with today.
    final DateTime now = DateTime.now();
    final List<String> dayLabels = List.generate(7, (index) {
      final DateTime day = now.subtract(Duration(days: 6 - index));
      return DateFormat('E').format(day);
    });

    // Finds the most productive day for the insight card.
    int bestIndex = 0;
    for (int i = 1; i < weeklyCompleted.length; i++) {
      if (weeklyCompleted[i] > weeklyCompleted[bestIndex]) bestIndex = i;
    }
    final int weekTotal = weeklyCompleted.reduce((a, b) => a + b);

    String insight;
    if (weekTotal == 0) {
      insight = 'Complete a task to start your streak!';
    } else {
      final String taskWord = weekTotal == 1 ? 'task' : 'tasks';
      insight = 'You finished $weekTotal $taskWord this week. '
          '${dayLabels[bestIndex]} was your best day '
          'with ${weeklyCompleted[bestIndex]}.';
    }

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Productivity'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion percentage card
              _CompletionCard(
                rate: completionRate,
                completed: completedTasks,
                total: totalTasks,
              ),
              const SizedBox(height: 16),

              // Total, completed and pending
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.list_alt_rounded,
                      label: 'Total',
                      value: totalTasks,
                      color: AppColors.terracotta,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.task_alt_rounded,
                      label: 'Done',
                      value: completedTasks,
                      color: AppColors.priorityLow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.pending_actions_rounded,
                      label: 'Pending',
                      value: pendingTasks,
                      color: AppColors.priorityMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Weekly chart
              Text(
                'This week',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tasks completed per day',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _WeeklyChart(values: weeklyCompleted, labels: dayLabels),
              const SizedBox(height: 20),

              // Insight
              _InsightCard(message: insight),
            ],
          ),
        ),
      ),
    );
  }
}

/// Terracotta card with a big completion ring.
class _CompletionCard extends StatelessWidget {
  final double rate;
  final int completed;
  final int total;

  const _CompletionCard({
    required this.rate,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final int percent = (rate * 100).round();

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
                  'Completion rate',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.lightApricot,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$percent%',
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  '$completed of $total tasks completed',
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
            width: 96,
            height: 96,
            child: CircularProgressIndicator(
              value: rate,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              color: AppColors.white,
              backgroundColor: const Color(0x40FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small white card with an icon and one number.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
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
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.softBeige,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
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
    );
  }
}

/// The weekly bar chart (fl_chart). Today's bar is the darkest.
class _WeeklyChart extends StatelessWidget {
  final List<int> values;
  final List<String> labels;

  const _WeeklyChart({required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    // Height of the chart: at least 4, and one above the biggest bar.
    final int biggest = values.reduce((a, b) => a > b ? a : b);
    final double maxY = (biggest < 3 ? 4 : biggest + 1).toDouble();
    final double step = maxY <= 6 ? 1 : 2;

    return Container(
      height: 260,
      padding: const EdgeInsets.fromLTRB(8, 24, 16, 12),
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
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),

          // Light horizontal lines only
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: step,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.softBeige,
              strokeWidth: 1,
            ),
          ),

          // Axis labels
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // Numbers on the left
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: step,
                getTitlesWidget: (value, meta) {
                  // Only show whole numbers.
                  if (value != value.roundToDouble()) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toInt().toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            // Day names at the bottom
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  final bool isToday = index == labels.length - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      labels[index],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                        color: isToday
                            ? AppColors.terracotta
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // One bar per day
          barGroups: List.generate(values.length, (index) {
            final bool isToday = index == values.length - 1;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: values[index].toDouble(),
                  width: 22,
                  color: isToday ? AppColors.terracotta : AppColors.peach,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  // Soft background bar behind each bar
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: AppColors.warmCream,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// Soft apricot card with a short sentence about the week.
class _InsightCard extends StatelessWidget {
  final String message;

  const _InsightCard({required this.message});

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
            Icons.lightbulb_rounded,
            size: 30,
            color: AppColors.terracotta,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBrown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}