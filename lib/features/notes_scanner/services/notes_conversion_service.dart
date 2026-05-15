import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/prompts/ai_prompts.dart';

class NotesConversionService {
  final AIClient _aiClient;

  NotesConversionService({AIClient? aiClient}) : _aiClient = aiClient ?? AIClient.instance;

  Future<String> transcribeHandwriting(Uint8List imageBytes, String mimeType) async {
    try {
      final content = Content.multi([
        TextPart(AIPrompts.transcribeHandwritingPrompt),
        DataPart(mimeType, imageBytes),
      ]);

      final response = await _aiClient.model.generateContent([content]);
      return response.text ?? 'Unable to transcribe. Please try again.';
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure your Gemini API key in lib/config/api_config.dart';
      }
      return 'Error transcribing: \$e';
    }
  }

  Future<String> convertToStructuredNotes(String transcription) async {
    try {
      final prompt = AIPrompts.structuredNotesPrompt(transcription);
      final response = await _aiClient.model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to convert notes. Please try again.';
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure your Gemini API key in lib/config/api_config.dart';
      }
      return 'Error converting notes: \$e';
    }
  }
}
