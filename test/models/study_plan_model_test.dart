import 'package:flutter_test/flutter_test.dart';
import 'package:unihub/features/study_planner/models/study_plan_model.dart';

void main() {
  group('StudyPlanModel.fromJson', () {
    test('parses complete valid JSON', () {
      final json = {
        'recommendation': 'Study Dart today',
        'motivational_tip': 'You can do it!',
        'streak_days': 5,
        'weekly_tasks': [
          {
            'title': 'Dart basics',
            'subtitle': 'Overview',
            'hours_left': 3,
            'chapters': 'Ch 1-3',
            'priority': 'high',
            'topics': [
              {'name': 'Variables', 'description': 'Dart variable types'},
            ],
          },
        ],
        'key_topics': ['OOP', 'Functions'],
        'study_techniques': ['Pomodoro'],
        'break_recommendation': 'Take breaks!',
      };
      final model = StudyPlanModel.fromJson(json);

      expect(model.recommendation, 'Study Dart today');
      expect(model.streakDays, 5);
      expect(model.weeklyTasks.length, 1);
      expect(model.weeklyTasks[0].title, 'Dart basics');
      expect(model.weeklyTasks[0].topics.length, 1);
      expect(model.weeklyTasks[0].topics[0].name, 'Variables');
      expect(model.keyTopics, containsAll(['OOP', 'Functions']));
    });

    test('applies defaults for missing fields', () {
      final model = StudyPlanModel.fromJson({});
      expect(model.recommendation, isNotEmpty);
      expect(model.motivationalTip, isNotEmpty);
      expect(model.streakDays, 1);
      expect(model.weeklyTasks, isEmpty);
      expect(model.keyTopics, isEmpty);
      expect(model.studyTechniques, isEmpty);
    });

    test('handles empty weekly_tasks list', () {
      final model = StudyPlanModel.fromJson({'weekly_tasks': []});
      expect(model.weeklyTasks, isEmpty);
    });
  });

  group('StudyPlanModel.parseFromResponse', () {
    test('parses response with ```json fences', () {
      const response = '''
```json
{
  "recommendation": "Study now",
  "motivational_tip": "Keep going",
  "streak_days": 2,
  "weekly_tasks": [],
  "key_topics": [],
  "study_techniques": [],
  "break_recommendation": "Rest"
}
```''';
      final model = StudyPlanModel.parseFromResponse(response);
      expect(model, isNotNull);
      expect(model!.recommendation, 'Study now');
    });

    test('returns null for malformed JSON', () {
      final model = StudyPlanModel.parseFromResponse('not valid json at all');
      expect(model, isNull);
    });

    test('returns null for empty string', () {
      final model = StudyPlanModel.parseFromResponse('');
      expect(model, isNull);
    });

    test('parses bare JSON without fences', () {
      const response =
          '{"recommendation":"Go","motivational_tip":"t","streak_days":1,'
          '"weekly_tasks":[],"key_topics":[],"study_techniques":[],'
          '"break_recommendation":"rest"}';
      final model = StudyPlanModel.parseFromResponse(response);
      expect(model, isNotNull);
      expect(model!.recommendation, 'Go');
    });
  });

  group('StudyPlanModel.createDefault', () {
    test('creates valid model with provided inputs', () {
      final model = StudyPlanModel.createDefault(
        subject: 'Physics',
        availableTime: '2 hours',
        focusType: 'Deep Work',
      );
      expect(model.recommendation, contains('Physics'));
      expect(model.weeklyTasks, isNotEmpty);
      expect(model.keyTopics, isNotEmpty);
      expect(model.studyTechniques, isNotEmpty);
    });
  });

  group('StudyTaskModel', () {
    test('fromJson handles missing fields gracefully', () {
      final task = StudyTaskModel.fromJson({});
      expect(task.title, 'Study Task');
      expect(task.hoursLeft, 2);
      expect(task.priority, 'medium');
      expect(task.topics, isEmpty);
    });
  });

  group('TopicItem', () {
    test('fromJson reads name and description', () {
      final item = TopicItem.fromJson({'name': 'Optics', 'description': 'Light'});
      expect(item.name, 'Optics');
      expect(item.description, 'Light');
    });

    test('fromJson falls back to topic field if name is missing', () {
      final item = TopicItem.fromJson({'topic': 'Waves'});
      expect(item.name, 'Waves');
    });
  });
}
