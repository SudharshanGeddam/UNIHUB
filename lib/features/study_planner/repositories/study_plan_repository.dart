import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unihub/models/study_plan_model.dart';

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
    required String generatedPlan,
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
      'generatedPlan': generatedPlan,
      'createdAt': FieldValue.serverTimestamp(),
      'isCompleted': false,
    });
  }

  Stream<List<StudyPlanModel>> getStudyPlans() {
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
          if (planString != null) {
            final parsed = StudyPlanModel.parseFromResponse(planString);
            if (parsed != null) return parsed;
          }
          return StudyPlanModel.createDefault(
            subject: data['subject'] ?? 'Study Plan',
            availableTime: data['availableTime'] ?? '',
            focusType: data['focusType'] ?? '',
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
