import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:unihub/features/auth/repositories/user_profile_repository.dart';

@GenerateMocks([FirebaseAuth, User])
import 'user_profile_repository_test.mocks.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late UserProfileRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');

    repository = UserProfileRepository(
      firestore: fakeFirestore,
      auth: mockFirebaseAuth,
    );
  });

  group('UserProfileRepository', () {
    test('createUserProfile creates document', () async {
      await repository.createUserProfile(
        email: 'test@test.com',
        name: 'Test Name',
      );

      final doc =
          await fakeFirestore.collection('users').doc('test_user_id').get();

      expect(doc.exists, true);
      expect(doc['email'], 'test@test.com');
      expect(doc['name'], 'Test Name');
    });

    test('getUserProfile retrieves data', () async {
      await fakeFirestore.collection('users').doc('test_user_id').set({
        'email': 'test@test.com',
        'name': 'Test Name',
      });

      final profile = await repository.getUserProfile();

      expect(profile, isNotNull);
      expect(profile!.email, 'test@test.com');
      expect(profile.name, 'Test Name');
    });

    test('updateUserProfile modifies existing data', () async {
      await fakeFirestore.collection('users').doc('test_user_id').set({
        'email': 'test@test.com',
        'name': 'Old Name',
      });

      await repository.updateUserProfile({'name': 'New Name'});

      final doc =
          await fakeFirestore.collection('users').doc('test_user_id').get();

      expect(doc['name'], 'New Name');
    });
  });
}
