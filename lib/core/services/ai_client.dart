import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:unihub/config/api_config.dart';

class AIClient {
  static AIClient? _instance;
  late final GenerativeModel model;

  AIClient._() {
    if (!ApiConfig.isGeminiConfigured) {
      throw Exception(
          'Please set GEMINI_API_KEY via --dart-define at build time');
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

  static AIClient get instance {
    _instance ??= AIClient._();
    return _instance!;
  }
  
  bool get isReady => ApiConfig.isGeminiConfigured;
}
