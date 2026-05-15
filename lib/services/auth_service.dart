import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:unihub/features/auth/repositories/user_profile_repository.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final UserProfileRepository _userProfileRepository = UserProfileRepository();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email & Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with Email & Password
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

      // Update display name in Firebase Auth
      await credential.user?.updateDisplayName(name);

      // Save additional user data to Firestore
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

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if we have the required tokens
      if (googleAuth.idToken == null) {
        throw 'Google sign-in failed: ID token is null. Please ensure OAuth client is configured in Firebase Console.';
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);

      // Save/update user profile in Firestore (only if new user or missing data)
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final existingProfile = await _userProfileRepository.getUserProfile();

        // Only create profile if it doesn't exist
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

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Handle Firebase Auth Exceptions
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
