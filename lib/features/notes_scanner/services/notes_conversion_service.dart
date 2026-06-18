import 'dart:convert';
import 'dart:typed_data';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/prompts/ai_prompts.dart';

class NotesConversionService {
  final AIClient? _aiClient;

  NotesConversionService({AIClient? aiClient})
      : _aiClient = aiClient ?? AIClient.tryGetInstance();

  Future<String> transcribeHandwriting(
      Uint8List imageBytes, String mimeType) async {
    try {
      if (_aiClient == null) throw Exception('API_KEY not configured');

      final base64Image = base64Encode(imageBytes);

      return await _aiClient!.generateContent(
          AIPrompts.transcribeHandwritingPrompt,
          base64Image: base64Image,
          mimeType: mimeType);
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure your OpenRouter API key in lib/config/api_config.dart';
      }
      return 'Error transcribing: $e';
    }
  }

  Future<String> convertToStructuredNotes(String transcription) async {
    try {
      if (_aiClient == null) throw Exception('API_KEY not configured');
      final prompt = AIPrompts.structuredNotesPrompt(transcription);
      return await _aiClient!.generateContent(prompt);
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure your OpenRouter API key in lib/config/api_config.dart';
      }
      return 'Error converting notes: $e';
    }
  }
}
