import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unihub/features/reminders/models/reminder_model.dart';

class ReminderRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ReminderRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User not authenticated');
    return uid;
  }

  Future<void> addReminder(Reminder reminder) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .add({
      'title': reminder.title,
      'description': reminder.description,
      'dueDate': Timestamp.fromDate(reminder.dueDate),
      'type': reminder.type.toString(),
      'category': reminder.category.toString(),
      'isCompleted': reminder.isCompleted,
      'isAiSuggestion': reminder.isAiSuggestion,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Reminder>> getReminders() {
    try {
      return _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .orderBy('dueDate')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return Reminder.fromMap(data);
        }).toList();
      });
    } catch (e) {
      if (e is StateError) return Stream.value([]);
      rethrow;
    }
  }

  Future<void> toggleReminder(String reminderId, bool isCompleted) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .doc(reminderId)
        .update({'isCompleted': isCompleted});
  }

  Future<void> deleteReminder(String reminderId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();
  }
}
