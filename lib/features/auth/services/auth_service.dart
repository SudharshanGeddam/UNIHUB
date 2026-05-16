import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unihub/features/auth/repositories/user_profile_repository.dart';

/// Handles all Firebase Authentication operations for UniHub.
///
/// Supports email/password auth, Google Sign-In, and password reset.
/// Errors are converted to human-readable strings before being thrown,
/// so UI layers can display them directly.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final UserProfileRepository _userProfileRepository = UserProfileRepository();

  /// The currently signed-in Firebase user, or `null` if signed out.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits auth state changes (sign-in / sign-out events).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Email / Password ────────────────────────────────────────────────────

  Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? college,
    String? year,
    String? course,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      await _userProfileRepository.createUserProfile(
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        college: college,
        year: year,
        course: course,
        photoUrl: credential.user?.photoURL,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── Google Sign-In ──────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw 'Google sign-in failed: ID token is null. Please ensure '
            'OAuth client is configured in Firebase Console.';
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final user = userCredential.user!;
        final existingProfile =
            await _userProfileRepository.getUserProfile();

        if (existingProfile == null) {
          await _userProfileRepository.createUserProfile(
            email: user.email ?? googleUser.email,
            name: user.displayName ?? googleUser.displayName ?? 'User',
            photoUrl: user.photoURL ?? googleUser.photoUrl,
          );
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw 'Google sign-in failed: ${e.message ?? e.code}';
    } catch (e) {
      throw 'Google sign-in failed: $e';
    }
  }

  // ── Password Reset ──────────────────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An error occurred: ${e.code}';
    }
  }
}
