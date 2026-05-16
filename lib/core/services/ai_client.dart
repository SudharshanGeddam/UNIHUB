import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:unihub/config/api_config.dart';

/// Singleton wrapper around the Gemini [GenerativeModel].
///
/// Use [AIClient.tryGetInstance()] from service classes rather than
/// [AIClient.instance] to avoid an unhandled exception when the API key is
/// absent (e.g. during development without `--dart-define=GEMINI_API_KEY`).
class AIClient {
  static AIClient? _instance;

  late final GenerativeModel model;

  AIClient._() {
    if (!ApiConfig.isGeminiConfigured) {
      throw Exception(
          'Please set GEMINI_API_KEY via --dart-define=GEMINI_API_KEY=your_key');
    }

    model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: ApiConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 8192,
      ),
      systemInstruction: Content.text(
        '''You are UniHub AI, a helpful academic assistant for college students. 
        You help with:
        - Study planning and scheduling
        - Answering academic doubts
        - Exam preparation tips
        - Note organization
        - Time management
        Keep responses concise, friendly, and actionable.''',
      ),
    );
  }

  /// Returns the shared [AIClient] instance.
  ///
  /// Throws an [Exception] if [ApiConfig.isGeminiConfigured] is `false`.
  /// Prefer [tryGetInstance] in screens to handle the missing-key case.
  static AIClient get instance {
    _instance ??= AIClient._();
    return _instance!;
  }

  /// Returns `null` instead of throwing when the API key is absent.
  ///
  /// Screens should check for `null` and display [ApiKeyMissingBanner].
  ///
  /// ```dart
  /// final client = AIClient.tryGetInstance();
  /// if (client == null) {
  ///   return const ApiKeyMissingBanner(featureName: 'AI Chat');
  /// }
  /// ```
  static AIClient? tryGetInstance() {
    if (!ApiConfig.isGeminiConfigured) {
      debugPrint('⚠️ AIClient: GEMINI_API_KEY not configured.');
      return null;
    }
    return instance;
  }

  /// Whether a valid Gemini API key is configured.
  static bool get isConfigured => ApiConfig.isGeminiConfigured;

  /// For backward compatibility — prefer the static [isConfigured].
  bool get isReady => ApiConfig.isGeminiConfigured;
}
