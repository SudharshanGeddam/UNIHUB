import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/features/notes_scanner/services/notes_conversion_service.dart';

@GenerateMocks([AIClient])
import 'notes_conversion_service_test.mocks.dart';

void main() {
  late MockAIClient mockAIClient;

  setUp(() {
    mockAIClient = MockAIClient();
  });

  group('NotesConversionService', () {
    test('transcribeHandwriting returns content', () async {
      when(mockAIClient.generateContent(any,
              base64Image: anyNamed('base64Image'),
              mimeType: anyNamed('mimeType')))
          .thenAnswer((_) async => 'Transcribed Text');

      final service = NotesConversionService(aiClient: mockAIClient);
      final result = await service.transcribeHandwriting(
          Uint8List.fromList([1, 2, 3]), 'image/jpeg');

      expect(result, 'Transcribed Text');
    });

    test('convertToStructuredNotes returns structured data', () async {
      when(mockAIClient.generateContent(any))
          .thenAnswer((_) async => 'Structured Data');

      final service = NotesConversionService(aiClient: mockAIClient);
      final result = await service.convertToStructuredNotes('Raw text');

      expect(result, 'Structured Data');
    });
  });
}
