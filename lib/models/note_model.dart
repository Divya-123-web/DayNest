import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// One note. Its fields match the Firestore plan:
/// id, title, content, category, isPinned, createdAt, updatedAt.
class NoteModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Categories the user can choose from.
  static const List<String> categories = [
    'Personal',
    'Work',
    'Ideas',
    'Study',
    'Journal',
    'Other',
  ];

  /// Each category gets its own soft colour from the Daynest palette.
  /// Used for the background of note cards.
  static Color colorForCategory(String category) {
    switch (category) {
      case 'Personal':
        return AppColors.lightApricot;
      case 'Work':
        return AppColors.softBeige;
      case 'Ideas':
        return AppColors.peach;
      case 'Study':
        return const Color(0xFFF5E1C8);
      case 'Journal':
        return const Color(0xFFFAEBD7);
      default:
        return AppColors.white;
    }
  }

  /// Turns this note into a map that Firestore can store.
  /// Dates are saved as Firestore Timestamps.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'isPinned': isPinned,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Builds a note from Firestore data.
  /// [id] is the Firestore document id.
  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      title: (map['title'] as String?) ?? '',
      content: (map['content'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Other',
      isPinned: (map['isPinned'] as bool?) ?? false,
      createdAt: _toDate(map['createdAt']),
      updatedAt: _toDate(map['updatedAt']),
    );
  }

  /// Safely turns a Firestore Timestamp into a DateTime.
  static DateTime _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  /// Makes a copy of this note with some fields changed.
  /// (Notes are never edited directly; we always create a changed copy.)
  NoteModel copyWith({
    String? title,
    String? content,
    String? category,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}