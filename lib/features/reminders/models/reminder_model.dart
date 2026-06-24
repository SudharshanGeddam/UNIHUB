import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderCategory { all, academic, community, exams }

enum ReminderType { classReminder, studySession, labSchedule, assignmentDue }

class Reminder {
  final String id;
  final String title;
  final String description;
  final ReminderType type;
  final ReminderCategory category;
  final DateTime createdAt;
  final DateTime dueDate;
  final bool isAiSuggestion;
  final bool isCompleted;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.createdAt,
    required this.dueDate,
    this.isAiSuggestion = false,
    this.isCompleted = false,
  });

  factory Reminder.fromMap(Map<String, dynamic> data) {
    return Reminder(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: ReminderType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => ReminderType.classReminder,
      ),
      category: ReminderCategory.values.firstWhere(
        (e) => e.toString() == data['category'],
        orElse: () => ReminderCategory.academic,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAiSuggestion: data['isAiSuggestion'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }
}
