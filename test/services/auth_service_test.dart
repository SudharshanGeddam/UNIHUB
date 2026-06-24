import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:unihub/features/auth/services/auth_service.dart';
import 'package:unihub/features/auth/repositories/user_profile_repository.dart';

@GenerateMocks([FirebaseAuth, UserProfileRepository])
import 'auth_service_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserProfileRepository mockUserProfileRepository;
  late AuthService authService;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserProfileRepository = MockUserProfileRepository();
    authService = AuthService(
        auth: mockFirebaseAuth,
        userProfileRepository: mockUserProfileRepository);
  });

  group('AuthService Exception Handling', () {
    test('handles user-not-found', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      expect(
        () => authService.signInWithEmail('test@test.com', 'password'),
        throwsA('No user found with this email.'),
      );
    });

    test('handles wrong-password', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => authService.signInWithEmail('test@test.com', 'password'),
        throwsA('Wrong password provided.'),
      );
    });

    test('handles email-already-in-use', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@test.com', password: 'password'))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => authService.signUpWithEmail(
            email: 'test@test.com', password: 'password', name: 'Test User'),
        throwsA('Email is already registered.'),
      );
    });

    test('handles invalid-email', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
              email: 'test', password: 'password'))
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      expect(
        () => authService.signInWithEmail('test', 'password'),
        throwsA('Invalid email address.'),
      );
    });

    test('handles weak-password', () async {
      when(mockFirebaseAuth.createUserWithEmailAndPassword(
              email: 'test@test.com', password: '123'))
          .thenThrow(FirebaseAuthException(code: 'weak-password'));

      expect(
        () => authService.signUpWithEmail(
            email: 'test@test.com', password: '123', name: 'Test User'),
        throwsA('Password must be at least 6 characters.'),
      );
    });
  });
}
