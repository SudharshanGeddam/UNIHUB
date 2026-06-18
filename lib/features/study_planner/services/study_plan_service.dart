import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/prompts/ai_prompts.dart';

class StudyPlanService {
  final AIClient? _aiClient;

  StudyPlanService({AIClient? aiClient})
      : _aiClient = aiClient ?? AIClient.tryGetInstance();

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
      if (_aiClient == null) throw Exception('API_KEY not configured');
      return await _aiClient!.generateContent(prompt);
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure OPENROUTER_API_KEY via --dart-define at build time';
      }
      return 'Error generating study plan: $e';
    }
  }

  Future<String> analyzeForExam(String content) async {
    final prompt = AIPrompts.examPrepAnalysisPrompt(content);

    try {
      if (_aiClient == null) throw Exception('API_KEY not configured');
      return await _aiClient!.generateContent(prompt);
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure OPENROUTER_API_KEY via --dart-define at build time';
      }
      return 'Error: $e';
    }
  }
}
