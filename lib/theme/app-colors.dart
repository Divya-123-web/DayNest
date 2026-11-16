import 'package:flutter/material.dart';

/// All Daynest colours in one place.
/// Use these everywhere instead of typing hex codes in screens.
class AppColors {
  // Prevents anyone from creating an object of this class.
  AppColors._();

  // Brand palette
  static const Color warmCream = Color(0xFFFFF8E9);
  static const Color softBeige = Color(0xFFF3E5CE);
  static const Color peach = Color(0xFFF6C99D);
  static const Color lightApricot = Color(0xFFFBE0BD);
  static const Color terracotta = Color(0xFFC98255);
  static const Color darkBrown = Color(0xFF44352C);
  static const Color white = Color(0xFFFFFFFF);

  // Text colours
  static const Color textPrimary = darkBrown;
  static const Color textSecondary = Color(0xFF8A7868);

  // Priority colours (used on task cards later)
  static const Color priorityHigh = Color(0xFFD9694F);
  static const Color priorityMedium = Color(0xFFE5A44F);
  static const Color priorityLow = Color(0xFF8DAE7B);

  // Shadow colour for cards
  static const Color shadow = Color(0x1A44352C);
}