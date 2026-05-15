import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:unihub/firebase_options.dart';
import 'package:unihub/features/auth/screens/login_screen.dart';
import 'package:unihub/features/home/screens/home_screen.dart';
import 'package:unihub/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      debugPrint('✅ Firebase initialized successfully');
    }
  } catch (e, stackTrace) {
    // Log the full error for debugging
    if (kDebugMode) {
      debugPrint('❌ Firebase initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    // Don't continue if Firebase fails - it's required for auth
    rethrow;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A022E),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A022E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A022E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// Auth wrapper to check login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if Firebase is initialized
    try {
      final app = Firebase.app();
      if (kDebugMode) {
        debugPrint('✅ Firebase app found: ${app.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase app not found: $e');
      }
      // Show error screen if Firebase not initialized
      return Scaffold(
        backgroundColor: const Color(0xFF0A022E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 20),
                const Text(
                  'Firebase Not Initialized',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please check the console for error details.\n\nTry restarting the app.',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    try {
      final authService = AuthService();

      return StreamBuilder(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          // Show loading while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0A022E),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'UniHub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // User is logged in
          if (snapshot.hasData && snapshot.data != null) {
            return const HomeScreen();
          }

          // User is not logged in
          return const LoginScreen();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Auth service error: $e');
      }
      // If auth service fails, show login screen anyway
      return const LoginScreen();
    }
  }
}
