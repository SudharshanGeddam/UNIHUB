import 'dart:convert';
import 'package:flutter/material.dart';

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

  static StudyPlanModel? parseFromResponse(String response) {
    try {
      // Try to extract JSON from the response
      String jsonStr = response;

      // Check if response contains markdown code blocks
      if (response.contains('```json')) {
        final startIndex = response.indexOf('```json') + 7;
        final endIndex = response.indexOf('```', startIndex);
        if (endIndex > startIndex) {
          jsonStr = response.substring(startIndex, endIndex).trim();
        }
      } else if (response.contains('```')) {
        final startIndex = response.indexOf('```') + 3;
        final endIndex = response.indexOf('```', startIndex);
        if (endIndex > startIndex) {
          jsonStr = response.substring(startIndex, endIndex).trim();
        }
      }

      // Try to find JSON object in the string
      final jsonStartIndex = jsonStr.indexOf('{');
      final jsonEndIndex = jsonStr.lastIndexOf('}');
      if (jsonStartIndex != -1 &&
          jsonEndIndex != -1 &&
          jsonEndIndex > jsonStartIndex) {
        jsonStr = jsonStr.substring(jsonStartIndex, jsonEndIndex + 1);
      }

      final Map<String, dynamic> json = jsonDecode(jsonStr);
      return StudyPlanModel.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing study plan JSON: $e');
      return null;
    }
  }

  // Create a default/fallback model from basic inputs
  static StudyPlanModel createDefault({
    required String subject,
    required String availableTime,
    required String focusType,
  }) {
    return StudyPlanModel(
      recommendation:
          'Focus on $subject today. You have $availableTime available - perfect for $focusType!',
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

  IconData get icon {
    if (title.toLowerCase().contains('math') ||
        title.toLowerCase().contains('calculus')) {
      return Icons.calculate;
    } else if (title.toLowerCase().contains('code') ||
        title.toLowerCase().contains('programming')) {
      return Icons.code;
    } else if (title.toLowerCase().contains('review') ||
        title.toLowerCase().contains('revision')) {
      return Icons.psychology;
    } else if (title.toLowerCase().contains('practice') ||
        title.toLowerCase().contains('exercise')) {
      return Icons.fitness_center;
    } else if (title.toLowerCase().contains('read') ||
        title.toLowerCase().contains('theory')) {
      return Icons.auto_stories;
    } else {
      return Icons.menu_book;
    }
  }
}

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
}
