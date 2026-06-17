import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unihub/core/routing/app_router.dart';
import 'package:unihub/core/theme/app_theme.dart';
import 'package:unihub/core/theme/theme_provider.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
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
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'UniHub',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'UniHub',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
          ].animate(interval: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
        ),
      ),
    );
  }
}
