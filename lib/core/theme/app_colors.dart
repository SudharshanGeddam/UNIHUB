import 'package:flutter/material.dart';

/// Centralized color palette for UniHub.
///
/// All colors used across the app are defined here so that design changes
/// can be made in a single place.
abstract final class AppColors {
  // ── Backgrounds ─────────────────────────────────────────────────────────
  /// Primary deep-navy background used on most screens.
  static const Color background = Color(0xFF0A022E);

  /// Slightly lighter background used on the notes scanner screen.
  static const Color backgroundAlt = Color(0xFF0A0A12);

  // ── Surfaces ─────────────────────────────────────────────────────────────
  /// Card / sheet surface — dark navy used in dialogs, bottom sheets.
  static const Color surface = Color(0xFF1A1A2E);

  /// Secondary surface variant — slightly warmer dark, used in input containers.
  static const Color surfaceVariant = Color(0xFF1E1E28);

  /// Tinted surface used in results screen gradient mid-point.
  static const Color surfaceTinted = Color(0xFF1A1A3E);

  // ── Primary ──────────────────────────────────────────────────────────────
  /// Primary brand blue — buttons, active indicators.
  static const Color primary = Color(0xFF2B34E3);

  /// Lighter primary — secondary buttons, chips.
  static const Color primaryLight = Color(0xFF6366F1);

  // ── Accent ───────────────────────────────────────────────────────────────
  /// Deep purple accent — study planner UI, focus session.
  static const Color accent = Color(0xFF7C4DFF);

  /// Light purple accent — gradients alongside [accent].
  static const Color accentLight = Color(0xFF9C7CFF);

  // ── Semantic ─────────────────────────────────────────────────────────────
  /// Success green — export buttons, success banners.
  static const Color success = Color(0xFF10B981);

  /// Warning amber/gold — tips, highlights.
  static const Color warning = Color(0xFFFBBF24);

  /// Orange — reminders, streaks.
  static const Color orange = Color(0xFFFF9800);

  /// Pink — definitions badges.
  static const Color pink = Color(0xFFEC4899);

  /// Error red — standard error color.
  static const Color error = Colors.redAccent;

  // ── Input ────────────────────────────────────────────────────────────────
  /// Fill color for text input fields.
  static const Color inputFill = Color(0xFF55565B);

  /// Semi-transparent input fill used in some screens.
  static const Color inputFillTranslucent = Color(0x6455565B);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textHint = Colors.white54;
  static const Color textDisabled = Colors.white38;
}
