import 'package:flutter/material.dart';
import 'package:unihub/features/study_planner/models/study_plan_model.dart';

/// UI extensions on [StudyTaskModel] that map domain data to Flutter visuals.
///
/// These are separated from the model so that [StudyTaskModel] stays
/// Flutter-free (a pure Dart class) and can be tested without a UI context.
extension StudyTaskUiExtension on StudyTaskModel {
  /// Returns a [Color] representing the task's priority level.
  Color get color {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFF7C4DFF);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'low':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF7C4DFF);
    }
  }

  /// Returns an [IconData] based on the task's title keywords.
  IconData get icon {
    final lower = title.toLowerCase();
    if (lower.contains('math') || lower.contains('calculus')) {
      return Icons.calculate;
    } else if (lower.contains('code') || lower.contains('programming')) {
      return Icons.code;
    } else if (lower.contains('review') || lower.contains('revision')) {
      return Icons.psychology;
    } else if (lower.contains('practice') || lower.contains('exercise')) {
      return Icons.fitness_center;
    } else if (lower.contains('read') || lower.contains('theory')) {
      return Icons.auto_stories;
    } else {
      return Icons.menu_book;
    }
  }
}
