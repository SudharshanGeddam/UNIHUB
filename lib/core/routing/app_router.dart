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

Page<dynamic> _fadeTransition(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
  );
}

GoRouter createAppRouter(BuildContext context) {
  final authNotifier = Provider.of<AuthNotifier>(context, listen: false);

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: AppRoutes.home,
    redirect: (BuildContext ctx, GoRouterState state) {
      final isAuthenticated = authNotifier.isAuthenticated;
      final isLoading = authNotifier.isLoading;

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
        pageBuilder: (context, state) => _fadeTransition(const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => _fadeTransition(const HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.chat,
        name: 'chat',
        pageBuilder: (context, state) => _fadeTransition(const AgentScreen()),
      ),
      GoRoute(
        path: AppRoutes.studyPlanner,
        name: 'study-planner',
        pageBuilder: (context, state) => _fadeTransition(const StudyPlanner()),
        routes: [
          GoRoute(
            path: 'results',
            name: 'study-planner-results',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return _fadeTransition(
                StudyPlannerResults(
                  subject: extra['subject'] as String,
                  availableTime: extra['availableTime'] as String,
                  focusType: extra['focusType'] as String,
                  studyPlan: extra['studyPlan'] as StudyPlanModel,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notesScanner,
        name: 'notes-scanner',
        pageBuilder: (context, state) => _fadeTransition(const NotesScannerScreen()),
      ),
      GoRoute(
        path: AppRoutes.reminders,
        name: 'reminders',
        pageBuilder: (context, state) => _fadeTransition(const SmartRemindersScreen()),
      ),
      GoRoute(
        path: AppRoutes.community,
        name: 'community',
        pageBuilder: (context, state) => _fadeTransition(const CommunityScreen()),
      ),
      GoRoute(
        path: AppRoutes.focusSession,
        name: 'focus-session',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _fadeTransition(
            FocusSessionScreen(
              subject: extra['subject'] as String,
              focusType: extra['focusType'] as String,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => _fadeTransition(const ProfileScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
