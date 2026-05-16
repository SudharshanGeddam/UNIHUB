import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:unihub/features/auth/notifiers/auth_notifier.dart';
import 'package:unihub/features/auth/screens/login_screen.dart';
import 'package:unihub/features/chat/screens/agent_screen.dart';
import 'package:unihub/features/community/screens/community_screen.dart';
import 'package:unihub/features/home/screens/home_screen.dart';
import 'package:unihub/features/notes_scanner/screens/notes_scanner_screen.dart';
import 'package:unihub/features/profile/screens/profile_screen.dart';
import 'package:unihub/features/reminders/screens/smart_reminders_screen.dart';
import 'package:unihub/features/study_planner/models/study_plan_model.dart';
import 'package:unihub/features/study_planner/screens/focus_session_screen.dart';
import 'package:unihub/features/study_planner/screens/study_planner_results_screen.dart';
import 'package:unihub/features/study_planner/screens/study_planner_screen.dart';

/// Route name constants to avoid magic strings at call sites.
abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const chat = '/chat';
  static const studyPlanner = '/study-planner';
  static const studyPlannerResults = '/study-planner/results';
  static const notesScanner = '/notes-scanner';
  static const reminders = '/reminders';
  static const community = '/community';
  static const focusSession = '/focus-session';
  static const profile = '/profile';
}

/// Application router built with [GoRouter].
///
/// - Unauthenticated users are redirected to [AppRoutes.login].
/// - Authenticated users landing on `/` or `/login` are redirected to
///   [AppRoutes.home].
/// - Auth state changes are listened to via [AuthNotifier].
GoRouter createAppRouter(BuildContext context) {
  final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: AppRoutes.home,
    redirect: (BuildContext ctx, GoRouterState state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final isLoading = authNotifier.isLoading;

      // During startup, don't redirect yet
      if (isLoading) return null;

      final onLoginPage = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated && !onLoginPage) {
        return AppRoutes.login;
      }
      if (isAuthenticated && onLoginPage) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        builder: (context, state) => const AgentScreen(),
      ),
      GoRoute(
        path: AppRoutes.studyPlanner,
        name: 'study-planner',
        builder: (context, state) => const StudyPlanner(),
        routes: [
          GoRoute(
            path: 'results',
            name: 'study-planner-results',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return StudyPlannerResults(
                subject: extra['subject'] as String,
                availableTime: extra['availableTime'] as String,
                focusType: extra['focusType'] as String,
                studyPlan: extra['studyPlan'] as StudyPlanModel,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notesScanner,
        name: 'notes-scanner',
        builder: (context, state) => const NotesScannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.reminders,
        name: 'reminders',
        builder: (context, state) => const SmartRemindersScreen(),
      ),
      GoRoute(
        path: AppRoutes.community,
        name: 'community',
        builder: (context, state) => const CommunityScreen(),
      ),
      GoRoute(
        path: AppRoutes.focusSession,
        name: 'focus-session',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return FocusSessionScreen(
            subject: extra['subject'] as String,
            focusType: extra['focusType'] as String,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}
