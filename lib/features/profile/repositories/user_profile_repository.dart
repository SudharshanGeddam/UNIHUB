import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileStats {
  final int totalReminders;
  final int completedReminders;
  final int totalStudyPlans;

  UserProfileStats({
    required this.totalReminders,
    required this.completedReminders,
    required this.totalStudyPlans,
  });
}

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  UserProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');
    return uid;
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': name,
        'email': user.email,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<UserProfileStats> getUserStats() async {
    try {
      final remindersSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .get();

      final int totalReminders = remindersSnapshot.docs.length;
      final int completedReminders = remindersSnapshot.docs
          .where((doc) => doc.data()['isCompleted'] == true)
          .length;

      final studyPlansSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('studyPlans')
          .get();
      final int totalStudyPlans = studyPlansSnapshot.docs.length;

      return UserProfileStats(
        totalReminders: totalReminders,
        completedReminders: completedReminders,
        totalStudyPlans: totalStudyPlans,
      );
    } catch (e) {
      return UserProfileStats(
        totalReminders: 0,
        completedReminders: 0,
        totalStudyPlans: 0,
      );
    }
  }
}
