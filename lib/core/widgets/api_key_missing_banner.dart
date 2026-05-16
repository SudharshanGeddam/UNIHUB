import 'package:flutter/material.dart';
import 'package:unihub/core/theme/app_colors.dart';

/// Displayed at the top of AI-powered screens when no Gemini API key
/// has been configured via `--dart-define=GEMINI_API_KEY=...`.
///
/// Provides a clear, actionable message so developers know exactly what
/// to do, rather than seeing an opaque crash.
class ApiKeyMissingBanner extends StatelessWidget {
  /// The name of the feature that requires the API key, e.g. "AI Chat".
  final String featureName;

  const ApiKeyMissingBanner({
    super.key,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_off_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$featureName requires a Gemini API key',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Run with: flutter run --dart-define=GEMINI_API_KEY=your_key',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
