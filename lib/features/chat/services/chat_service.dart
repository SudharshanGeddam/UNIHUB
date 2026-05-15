import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/prompts/ai_prompts.dart';

class ChatService {
  final AIClient _aiClient;
  ChatSession? _chat;

  ChatService({AIClient? aiClient}) : _aiClient = aiClient ?? AIClient.instance;

  ChatSession get _activeChat {
    _chat ??= _aiClient.model.startChat();
    return _chat!;
  }

  void resetChat() {
    _chat = _aiClient.model.startChat();
  }

  Future<String> chat(String message) async {
    try {
      final response = await _activeChat.sendMessage(Content.text(message));
      return response.text ?? 'I couldn\'t process that. Please try again.';
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure GEMINI_API_KEY via --dart-define at build time';
      }
      return 'Error: $e';
    }
  }

  Future<String> solveDoubt(String question, {String? subject}) async {
    try {
      final prompt = AIPrompts.doubtSolvingPrompt(question, subject: subject);
      final response = await _aiClient.model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to answer. Please try again.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
