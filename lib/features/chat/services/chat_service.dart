import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/prompts/ai_prompts.dart';

class ChatService {
  final AIClient? _aiClient;
  ChatSession? _chat;

  ChatService({AIClient? aiClient})
      : _aiClient = aiClient ?? AIClient.tryGetInstance();

  ChatSession _getOrCreateActiveChat([List<Map<String, dynamic>>? history]) {
    if (_aiClient == null) throw Exception('API_KEY not configured');
    _chat ??= _aiClient!.startChat(history: history);
    return _chat!;
  }

  void initChat(List<Map<String, dynamic>> history) {
    if (_aiClient == null) return;
    _chat = _aiClient!.startChat(history: history);
  }

  void resetChat() {
    if (_aiClient == null) return;
    _chat = _aiClient!.startChat();
  }

  Future<String> chat(String message) async {
    try {
      final response = await _getOrCreateActiveChat().sendMessage(message);
      return response;
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure OPENROUTER_API_KEY via --dart-define at build time';
      }
      return 'Error: $e';
    }
  }

  Future<String> solveDoubt(String question, {String? subject}) async {
    try {
      if (_aiClient == null) throw Exception('API_KEY not configured');
      final prompt = AIPrompts.doubtSolvingPrompt(question, subject: subject);
      return await _aiClient!.generateContent(prompt);
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure OPENROUTER_API_KEY via --dart-define at build time';
      }
      return 'Error: $e';
    }
  }
}
