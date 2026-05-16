import 'package:flutter_test/flutter_test.dart';
import 'package:unihub/core/utils/json_utils.dart';

void main() {
  group('extractJsonFromAiResponse', () {
    test('returns null for empty string', () {
      expect(extractJsonFromAiResponse(''), isNull);
    });

    test('returns null when no JSON object is present', () {
      expect(extractJsonFromAiResponse('just some plain text'), isNull);
    });

    test('extracts bare JSON object', () {
      const input = '{"key": "value", "number": 42}';
      final result = extractJsonFromAiResponse(input);
      expect(result, equals('{"key": "value", "number": 42}'));
    });

    test('strips ```json fences', () {
      const input = '```json\n{"key": "value"}\n```';
      final result = extractJsonFromAiResponse(input);
      expect(result, equals('{"key": "value"}'));
    });

    test('strips generic ``` fences', () {
      const input = '```\n{"key": "value"}\n```';
      final result = extractJsonFromAiResponse(input);
      expect(result, equals('{"key": "value"}'));
    });

    test('extracts JSON from surrounding prose text', () {
      const input =
          'Here is your result:\n{"recommendation": "Study hard"}\nHope that helps!';
      final result = extractJsonFromAiResponse(input);
      expect(result, equals('{"recommendation": "Study hard"}'));
    });

    test('returns null when no closing brace exists', () {
      expect(extractJsonFromAiResponse('{"key": "value"'), isNull);
    });

    test('handles nested JSON objects correctly', () {
      const input = '{"outer": {"inner": 1}}';
      final result = extractJsonFromAiResponse(input);
      expect(result, equals('{"outer": {"inner": 1}}'));
    });

    test('strips ```json fences with extra whitespace', () {
      const input = '  ```json\n  {"key": "value"}\n  ```  ';
      final result = extractJsonFromAiResponse(input.trim());
      expect(result, isNotNull);
      expect(result, contains('"key"'));
    });
  });
}
