import 'package:flutter_test/flutter_test.dart';
import 'package:unihub/features/reminders/models/reminder_model.dart';

void main() {
  group('Reminder Model Formatting', () {
    test('timeAgo formats minutes correctly', () {
      final reminder = Reminder(
        id: '1',
        title: 'Test',
        description: 'Test desc',
        type: ReminderType.classReminder,
        category: ReminderCategory.academic,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      
      expect(reminder.timeAgo, '5 minutes ago');
    });

    test('timeAgo formats hours correctly', () {
      final reminder = Reminder(
        id: '2',
        title: 'Test',
        description: 'Test desc',
        type: ReminderType.studySession,
        category: ReminderCategory.academic,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      
      expect(reminder.timeAgo, '2 hours ago');
    });

    test('timeAgo formats days correctly', () {
      final reminder = Reminder(
        id: '3',
        title: 'Test',
        description: 'Test desc',
        type: ReminderType.assignmentDue,
        category: ReminderCategory.exams,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      
      expect(reminder.timeAgo, '3 days ago');
    });
  });
}
