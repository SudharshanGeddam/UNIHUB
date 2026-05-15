import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/prompts/ai_prompts.dart';

class StudyPlanService {
  final AIClient _aiClient;

  StudyPlanService({AIClient? aiClient}) : _aiClient = aiClient ?? AIClient.instance;

  Future<String> generateStudyPlan({
    required String subject,
    required String availableTime,
    required String focusType,
    String? additionalContext,
  }) async {
    final prompt = AIPrompts.studyPlanPrompt(
      subject: subject,
      availableTime: availableTime,
      focusType: focusType,
      additionalContext: additionalContext,
    );

    try {
      final response = await _aiClient.model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to generate study plan. Please try again.';
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure GEMINI_API_KEY via --dart-define at build time';
      }
      return 'Error generating study plan: $e';
    }
  }

  Future<String> analyzeForExam(String content) async {
    final prompt = AIPrompts.examPrepAnalysisPrompt(content);

    try {
      final response = await _aiClient.model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to analyze. Please try again.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
