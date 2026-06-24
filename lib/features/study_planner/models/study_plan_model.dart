import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:unihub/core/utils/json_utils.dart';

/// Data model representing a full AI-generated study plan.
class StudyPlanModel {
  final String recommendation;
  final String motivationalTip;
  final int streakDays;
  final List<StudyTaskModel> weeklyTasks;
  final List<String> keyTopics;
  final List<String> studyTechniques;
  final String breakRecommendation;

  StudyPlanModel({
    required this.recommendation,
    required this.motivationalTip,
    required this.streakDays,
    required this.weeklyTasks,
    required this.keyTopics,
    required this.studyTechniques,
    required this.breakRecommendation,
  });

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    return StudyPlanModel(
      recommendation: json['recommendation'] ?? 'Focus on your studies today!',
      motivationalTip:
          json['motivational_tip'] ?? 'Stay consistent and you will succeed!',
      streakDays: json['streak_days'] ?? 1,
      weeklyTasks: (json['weekly_tasks'] as List<dynamic>?)
              ?.map((task) => StudyTaskModel.fromJson(task))
              .toList() ??
          [],
      keyTopics: List<String>.from(json['key_topics'] ?? []),
      studyTechniques: List<String>.from(json['study_techniques'] ?? []),
      breakRecommendation: json['break_recommendation'] ??
          'Take a 5-10 minute break every hour.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation,
      'motivational_tip': motivationalTip,
      'streak_days': streakDays,
      'weekly_tasks': weeklyTasks.map((task) => task.toJson()).toList(),
      'key_topics': keyTopics,
      'study_techniques': studyTechniques,
      'break_recommendation': breakRecommendation,
    };
  }

  /// Parses a [StudyPlanModel] from a raw AI response string.
  ///
  /// Returns `null` if the response cannot be parsed.
  static StudyPlanModel? parseFromResponse(String response) {
    try {
      final jsonStr = extractJsonFromAiResponse(response);
      if (jsonStr == null) return null;
      final Map<String, dynamic> json = jsonDecode(jsonStr);
      return StudyPlanModel.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing study plan JSON: $e');
      return null;
    }
  }

  /// Creates a sensible default/fallback model from basic inputs.
  static StudyPlanModel createDefault({
    required String subject,
    required String availableTime,
    required String focusType,
  }) {
    return StudyPlanModel(
      recommendation:
          'Focus on $subject today. You have $availableTime available — perfect for $focusType!',
      motivationalTip: 'Consistency is key. Keep up the great work!',
      streakDays: 1,
      weeklyTasks: [
        StudyTaskModel(
          title: subject,
          subtitle: focusType,
          hoursLeft: 4,
          chapters: 'Core concepts',
          priority: 'high',
          topics: [
            TopicItem(
                name: 'Introduction to $subject',
                description: 'Basic concepts and overview'),
            TopicItem(
                name: 'Core Fundamentals',
                description: 'Key principles and theories'),
            TopicItem(
                name: 'Practice Examples',
                description: 'Worked examples and solutions'),
          ],
        ),
        StudyTaskModel(
          title: 'Review & Practice',
          subtitle: 'Practice Problems',
          hoursLeft: 2,
          chapters: 'Revision',
          priority: 'medium',
          topics: [
            TopicItem(
                name: 'Review Notes', description: 'Summarize key points'),
            TopicItem(
                name: 'Practice Problems',
                description: 'Solve practice questions'),
          ],
        ),
      ],
      keyTopics: ['Core Concepts', 'Practice Problems', 'Review Notes'],
      studyTechniques: [
        'Active Recall',
        'Spaced Repetition',
        'Pomodoro Technique'
      ],
      breakRecommendation: 'Take a 5-10 minute break every 25 minutes.',
    );
  }
}

/// A single task inside a [StudyPlanModel].
class StudyTaskModel {
  final String title;
  final String subtitle;
  final int hoursLeft;
  final String chapters;
  final String priority;
  final List<TopicItem> topics;

  StudyTaskModel({
    required this.title,
    required this.subtitle,
    required this.hoursLeft,
    required this.chapters,
    required this.priority,
    this.topics = const [],
  });

  factory StudyTaskModel.fromJson(Map<String, dynamic> json) {
    return StudyTaskModel(
      title: json['title'] ?? 'Study Task',
      subtitle: json['subtitle'] ?? '',
      hoursLeft: json['hours_left'] ?? 2,
      chapters: json['chapters'] ?? '',
      priority: json['priority'] ?? 'medium',
      topics: (json['topics'] as List<dynamic>?)
              ?.map((topic) => TopicItem.fromJson(topic))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'hours_left': hoursLeft,
      'chapters': chapters,
      'priority': priority,
      'topics': topics.map((topic) => topic.toJson()).toList(),
    };
  }
}

/// A granular topic within a [StudyTaskModel].
class TopicItem {
  final String name;
  final String description;

  TopicItem({
    required this.name,
    this.description = '',
  });

  factory TopicItem.fromJson(Map<String, dynamic> json) {
    return TopicItem(
      name: json['name'] ?? json['topic'] ?? 'Topic',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
