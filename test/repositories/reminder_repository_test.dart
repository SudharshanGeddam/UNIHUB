import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:unihub/features/reminders/models/reminder_model.dart';
import 'package:unihub/features/reminders/repositories/reminder_repository.dart';

@GenerateMocks([FirebaseAuth, User])
import 'reminder_repository_test.mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late ReminderRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');

    repository = ReminderRepository(
      firestore: fakeFirestore,
      auth: mockFirebaseAuth,
    );
  });

  group('ReminderRepository', () {
    test('addReminder adds a reminder to firestore', () async {
      final reminder = Reminder(
        id: '1',
        title: 'Test Reminder',
        dueDate: DateTime(2025, 1, 1),
        type: ReminderType.assignmentDue,
        category: ReminderCategory.academic,
        description: 'Test Desc',
        createdAt: DateTime.now(),
      );

      await repository.addReminder(reminder);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('reminders')
          .get();

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first['title'], 'Test Reminder');
    });

    test('getReminders returns stream of reminders', () async {
      final reminder = Reminder(
        id: '1',
        title: 'Test Reminder',
        dueDate: DateTime(2025, 1, 1),
        type: ReminderType.assignmentDue,
        category: ReminderCategory.academic,
        description: 'Test Desc',
        createdAt: DateTime.now(),
      );

      await repository.addReminder(reminder);

      final stream = repository.getReminders();
      final reminders = await stream.first;

      expect(reminders.length, 1);
      expect(reminders.first.title, 'Test Reminder');
    });

    test('toggleReminder updates isCompleted status', () async {
      final docRef = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('reminders')
          .add({'isCompleted': false, 'dueDate': DateTime.now()});

      await repository.toggleReminder(docRef.id, true);

      final doc = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('reminders')
          .doc(docRef.id)
          .get();

      expect(doc['isCompleted'], true);
    });

    test('deleteReminder removes document', () async {
      final docRef = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('reminders')
          .add({'title': 'To be deleted', 'dueDate': DateTime.now()});

      await repository.deleteReminder(docRef.id);

      final snapshot = await fakeFirestore
          .collection('users')
          .doc('test_user_id')
          .collection('reminders')
          .get();

      expect(snapshot.docs.isEmpty, true);
    });
  });
}
