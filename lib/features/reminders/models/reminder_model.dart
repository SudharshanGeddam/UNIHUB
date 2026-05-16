

enum ReminderCategory { all, academic, community, exams }

enum ReminderType { classReminder, studySession, labSchedule, assignmentDue }

class Reminder {
  final String id;
  final String title;
  final String description;
  final ReminderType type;
  final ReminderCategory category;
  final DateTime createdAt;
  final bool isAiSuggestion;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.createdAt,
    this.isAiSuggestion = false,
  });

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
