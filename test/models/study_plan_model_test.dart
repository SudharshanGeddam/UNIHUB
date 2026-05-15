import 'package:flutter_test/flutter_test.dart';
import 'package:unihub/models/study_plan_model.dart';

void main() {
  group('StudyPlanModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'recommendation': 'Good luck',
        'motivational_tip': 'You can do it',
        'streak_days': 5,
        'weekly_tasks': [
          {
            'title': 'Math',
            'subtitle': 'Algebra',
            'hours_left': 2,
            'chapters': 'Ch 1',
            'priority': 'high',
            'topics': [
              {'name': 'Linear Equations', 'description': 'Solve for x'}
            ]
          }
        ],
        'key_topics': ['Algebra'],
        'study_techniques': ['Pomodoro'],
        'break_recommendation': '10 mins'
      };

      final model = StudyPlanModel.fromJson(json);
      expect(model.recommendation, 'Good luck');
      expect(model.motivationalTip, 'You can do it');
      expect(model.streakDays, 5);
      expect(model.keyTopics, contains('Algebra'));
      expect(model.studyTechniques, contains('Pomodoro'));
      expect(model.breakRecommendation, '10 mins');
      expect(model.weeklyTasks.length, 1);
      
      final task = model.weeklyTasks.first;
      expect(task.title, 'Math');
      expect(task.subtitle, 'Algebra');
      expect(task.hoursLeft, 2);
      expect(task.chapters, 'Ch 1');
      expect(task.priority, 'high');
      expect(task.topics.length, 1);
      expect(task.topics.first.name, 'Linear Equations');
      expect(task.topics.first.description, 'Solve for x');
    });

    test('createDefault generates a valid plan', () {
      final model = StudyPlanModel.createDefault(
        subject: 'Physics',
        availableTime: '3 hours',
        focusType: 'Deep Work'
      );
      
      expect(model.recommendation, contains('Physics'));
      expect(model.weeklyTasks.isNotEmpty, true);
    });
  });
}
