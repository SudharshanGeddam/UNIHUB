import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unihub/features/study_planner/models/study_plan_model.dart';

class StudyPlanRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StudyPlanRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');
    return uid;
  }

  Future<void> saveStudyPlan({
    required String title,
    required String subject,
    required String availableTime,
    required String focusType,
    required StudyPlanModel plan,
  }) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('studyPlans')
        .add({
      'title': title,
      'subject': subject,
      'availableTime': availableTime,
      'focusType': focusType,
      'generatedPlan': jsonEncode(plan.toJson()),
      'createdAt': FieldValue.serverTimestamp(),
      'isCompleted': false,
    });
  }

  Stream<List<SavedStudyPlan>> getStudyPlans() {
    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('studyPlans')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final planString = data['generatedPlan'] as String?;
          StudyPlanModel plan;
          if (planString != null) {
            try {
              final jsonStr = planString.trim().startsWith('{') ? planString : null; // Basic check
              if (jsonStr != null) {
                plan = StudyPlanModel.fromJson(jsonDecode(jsonStr));
              } else {
                plan = StudyPlanModel.parseFromResponse(planString) ?? StudyPlanModel.createDefault(
                  subject: data['subject'] ?? 'Study Plan',
                  availableTime: data['availableTime'] ?? '',
                  focusType: data['focusType'] ?? '',
                );
              }
            } catch (e) {
              plan = StudyPlanModel.parseFromResponse(planString) ?? StudyPlanModel.createDefault(
                subject: data['subject'] ?? 'Study Plan',
                availableTime: data['availableTime'] ?? '',
                focusType: data['focusType'] ?? '',
              );
            }
          } else {
            plan = StudyPlanModel.createDefault(
              subject: data['subject'] ?? 'Study Plan',
              availableTime: data['availableTime'] ?? '',
              focusType: data['focusType'] ?? '',
            );
          }

          return SavedStudyPlan(
            id: doc.id,
            title: data['title'] ?? 'Study Plan',
            subject: data['subject'] ?? '',
            availableTime: data['availableTime'] ?? '',
            focusType: data['focusType'] ?? '',
            plan: plan,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();
      });
    } catch (e) {
      if (e is StateError) return Stream.value([]);
      rethrow;
    }
  }

  Future<void> deleteStudyPlan(String planId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('studyPlans')
        .doc(planId)
        .delete();
  }
}

class SavedStudyPlan {
  final String id;
  final String title;
  final String subject;
  final String availableTime;
  final String focusType;
  final StudyPlanModel plan;
  final DateTime createdAt;

  SavedStudyPlan({
    required this.id,
    required this.title,
    required this.subject,
    required this.availableTime,
    required this.focusType,
    required this.plan,
    required this.createdAt,
  });
}
