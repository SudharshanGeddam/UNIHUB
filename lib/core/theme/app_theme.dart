import 'package:flutter/material.dart';
import 'package:unihub/core/theme/app_colors.dart';

/// Application-wide [ThemeData].
///
/// Use [AppTheme.dark] as the [MaterialApp.theme].
abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.background,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.inputFill,
          hintStyle: const TextStyle(color: AppColors.textHint),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surface,
          contentTextStyle: const TextStyle(color: AppColors.textPrimary),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
}
