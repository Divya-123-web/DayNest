
import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/note_model.dart';
import '../theme/app_colors.dart';

/// Reusable card that shows one note.
/// - [onTap]: tapping the card (used to edit)
/// - [onTogglePin]: pin or unpin from the small menu
/// - [onDelete]: delete from the small menu
class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String dateText = DateFormat('d MMM').format(note.updatedAt);
    final bool hasTitle = note.title.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: NoteModel.colorForCategory(note.category),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 6, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: pin icon (if pinned) and the small menu
                Row(
                  children: [
                    if (note.isPinned)
                      const Icon(
                        Icons.push_pin_rounded,
                        size: 16,
                        color: AppColors.terracotta,
                      ),
                    const Spacer(),
                    SizedBox(
                      width: 32,
                      height: 24,
                      child: PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.more_horiz_rounded,
                          size: 20,
                          color: AppColors.darkBrown,
                        ),
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) {
                          if (value == 'pin') onTogglePin();
                          if (value == 'delete') onDelete();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'pin',
                            child: Row(
                              children: [
                                Icon(
                                  note.isPinned
                                      ? Icons.push_pin_outlined
                                      : Icons.push_pin_rounded,
                                  size: 20,
                                  color: AppColors.terracotta,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  note.isPinned ? 'Unpin' : 'Pin',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: AppColors.priorityHigh,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Delete',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.priorityHigh,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Title
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    hasTitle ? note.title : 'Untitled',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: hasTitle
                          ? AppColors.darkBrown
                          : AppColors.textSecondary,
                    ),
                  ),
                ),

                // Content preview
                if (note.content.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      note.content,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.darkBrown.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Category label and date
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            note.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkBrown,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateText,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}