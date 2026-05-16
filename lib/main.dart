import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:unihub/core/routing/app_router.dart';
import 'package:unihub/core/theme/app_colors.dart';
import 'package:unihub/core/theme/app_theme.dart';
import 'package:unihub/features/auth/notifiers/auth_notifier.dart';
import 'package:unihub/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) debugPrint('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    if (kDebugMode) {
      debugPrint('❌ Firebase initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    rethrow;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Build the router here so it has access to the Provider context.
    final router = createAppRouter(context);

    return MaterialApp.router(
      title: 'UniHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,

      // Loading screen shown while the router decides where to send the user.
      builder: (context, child) {
        final auth = context.watch<AuthNotifier>();
        if (auth.isLoading) {
          return const _SplashScreen();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Shown during the brief moment Firebase resolves the initial auth state.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
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
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
