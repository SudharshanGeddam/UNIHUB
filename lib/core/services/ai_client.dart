import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:unihub/config/api_config.dart';

class ChatSession {
  final AIClient client;
  final String systemInstruction;
  final List<Map<String, dynamic>> _messages = [];

  ChatSession(this.client,
      {required this.systemInstruction, List<Map<String, dynamic>>? history}) {
    if (systemInstruction.isNotEmpty) {
      _messages.add({
        "role": "system",
        "content": systemInstruction,
      });
    }
    if (history != null) {
      _messages.addAll(history);
    }
  }

  Future<String> sendMessage(String text,
      {String? base64Image, String? mimeType}) async {
    dynamic content;
    if (base64Image != null && mimeType != null) {
      content = [
        {"type": "text", "text": text},
        {
          "type": "image_url",
          "image_url": {"url": "data:$mimeType;base64,$base64Image"}
        }
      ];
    } else {
      content = text;
    }

    _messages.add({
      "role": "user",
      "content": content,
    });

    try {
      final responseText = await client.generateContentFromMessages(_messages);
      _messages.add({
        "role": "assistant",
        "content": responseText,
      });
      return responseText;
    } catch (e) {
      _messages.removeLast(); // Rollback user message on error
      rethrow;
    }
  }
}

class AIClient {
  static AIClient? _instance;

  final String _apiKey;
  final String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String _model = 'google/gemini-2.5-flash';

  final String defaultSystemInstruction =
      '''You are UniHub AI, a helpful academic assistant for college students. 
        You help with:
        - Study planning and scheduling
        - Answering academic doubts
        - Exam preparation tips
        - Note organization
        - Time management
        Keep responses concise, friendly, and actionable.''';

  AIClient._() : _apiKey = ApiConfig.openRouterApiKey {
    if (!ApiConfig.isConfigured) {
      throw Exception('OpenRouter API Key not configured');
    }
  }

  static AIClient get instance {
    _instance ??= AIClient._();
    return _instance!;
  }

  static AIClient? tryGetInstance() {
    if (!ApiConfig.isConfigured) {
      debugPrint('⚠️ AIClient: OpenRouter API key not configured.');
      return null;
    }
    return instance;
  }

  static bool get isConfigured => ApiConfig.isConfigured;
  bool get isReady => ApiConfig.isConfigured;

  ChatSession startChat({List<Map<String, dynamic>>? history}) {
    return ChatSession(this,
        systemInstruction: defaultSystemInstruction, history: history);
  }

  Future<String> generateContent(String prompt,
      {String? base64Image, String? mimeType}) async {
    dynamic content;
    if (base64Image != null && mimeType != null) {
      content = [
        {"type": "text", "text": prompt},
        {
          "type": "image_url",
          "image_url": {"url": "data:$mimeType;base64,$base64Image"}
        }
      ];
    } else {
      content = prompt;
    }

    final List<Map<String, dynamic>> messages = [
      {
        "role": "system",
        "content": defaultSystemInstruction,
      },
      {
        "role": "user",
        "content": content,
      }
    ];

    return generateContentFromMessages(messages);
  }

  Future<String> generateContentFromMessages(
      List<Map<String, dynamic>> messages) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://unihub.app',
        'X-Title': 'UniHub',
      },
      body: jsonEncode({
        "model": _model,
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 8192,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['choices']?[0]?['message']?['content'] ?? '';
    } else {
      throw Exception(
          'OpenRouter API Error: ${response.statusCode} - ${response.body}');
    }
  }
}
