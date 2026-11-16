import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daynest/theme/app-colors.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The three priority levels a task can have.
enum TaskPriority { high, medium, low }

/// Helper getters so the UI can show a label and colour for each priority.
extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }
}

/// One task. Its fields match the Firestore plan:
/// id, title, description, category, priority, dueDate,
/// isCompleted, createdAt, updatedAt.
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Categories the user can choose from.
  static const List<String> categories = [
    'Work',
    'Personal',
    'Study',
    'Health',
    'Shopping',
    'Other',
  ];

  /// Turns this task into a map that Firestore can store.
  /// Dates are saved as Firestore Timestamps.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Builds a task from Firestore data.
  /// [id] is the Firestore document id.
  factory TaskModel.fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Other',
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: _toDate(map['dueDate']),
      isCompleted: (map['isCompleted'] as bool?) ?? false,
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

  /// Makes a copy of this task with some fields changed.
  /// (Tasks are never edited directly; we always create a changed copy.)
  TaskModel copyWith({
    String? title,
    String? description,
    String? category,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}