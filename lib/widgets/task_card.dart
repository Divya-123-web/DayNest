import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import '../theme/app_colors.dart';

/// Reusable card that shows one task.
/// - [onToggle]: tapping the round checkbox
/// - [onTap]: tapping the card (used to edit)
/// - [onDelete]: tapping the trash icon
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.isCompleted;

    // A task is overdue if it is not done and its due time has passed.
    final bool isOverdue = !isDone && task.dueDate.isBefore(DateTime.now());

    final String dueText = DateFormat('d MMM, h:mm a').format(task.dueDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Round checkbox
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, right: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color:
                            isDone ? AppColors.terracotta : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone
                              ? AppColors.terracotta
                              : task.priority.color,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                  ),
                ),

                // Title, description, date and chips
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? AppColors.textSecondary
                              : AppColors.darkBrown,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Due date
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: isOverdue
                                ? AppColors.priorityHigh
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isOverdue ? '$dueText  •  Overdue' : dueText,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight:
                                  isOverdue ? FontWeight.w600 : FontWeight.w400,
                              color: isOverdue
                                  ? AppColors.priorityHigh
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Priority and category chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Chip(
                            label: task.priority.label,
                            textColor: task.priority.color,
                            backgroundColor:
                                task.priority.color.withOpacity(0.15),
                          ),
                          _Chip(
                            label: task.category,
                            textColor: AppColors.darkBrown,
                            backgroundColor: AppColors.softBeige,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete button
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  tooltip: 'Delete task',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small rounded label (used for priority and category).
class _Chip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const _Chip({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}