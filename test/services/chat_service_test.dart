import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/features/chat/services/chat_service.dart';

@GenerateMocks([AIClient, ChatSession])
import 'chat_service_test.mocks.dart';

void main() {
  late MockAIClient mockAIClient;
  late MockChatSession mockChatSession;

  setUp(() {
    mockAIClient = MockAIClient();
    mockChatSession = MockChatSession();
  });

  group('ChatService', () {
    test('chat returns response from AIClient', () async {
      when(mockAIClient.startChat(history: anyNamed('history')))
          .thenReturn(mockChatSession);
      when(mockChatSession.sendMessage(any))
          .thenAnswer((_) async => 'Hello from AI');

      final service = ChatService(aiClient: mockAIClient);
      final result = await service.chat('Hi');

      expect(result, 'Hello from AI');
    });

    test('solveDoubt returns response', () async {
      when(mockAIClient.generateContent(any))
          .thenAnswer((_) async => 'Math Answer');

      final service = ChatService(aiClient: mockAIClient);
      final result = await service.solveDoubt('What is 2+2?');

      expect(result, 'Math Answer');
    });
  });
}
