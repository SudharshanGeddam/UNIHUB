import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/features/study_planner/services/study_plan_service.dart';

@GenerateMocks([AIClient])
import 'study_plan_service_test.mocks.dart';

void main() {
  late MockAIClient mockAIClient;

  setUp(() {
    mockAIClient = MockAIClient();
  });

  group('StudyPlanService', () {
    test('generateStudyPlan returns content from AIClient', () async {
      when(mockAIClient.generateContent(any))
          .thenAnswer((_) async => 'Mock Plan');

      final service = StudyPlanService(aiClient: mockAIClient);
      final result = await service.generateStudyPlan(
        subject: 'Math',
        availableTime: '2 hours',
        focusType: 'Deep Work',
      );

      expect(result, 'Mock Plan');
      verify(mockAIClient.generateContent(any)).called(1);
    });

    test('generateStudyPlan returns API key error string when AIClient is null',
        () async {
      final service = StudyPlanService(aiClient: null);

      final result = await service.generateStudyPlan(
        subject: 'Math',
        availableTime: '2 hours',
        focusType: 'Deep Work',
      );

      expect(result,
          'Please configure OPENROUTER_API_KEY via --dart-define at build time');
    });

    test('generateStudyPlan catches general exception from AIClient', () async {
      when(mockAIClient.generateContent(any))
          .thenThrow(Exception('Network Error'));

      final service = StudyPlanService(aiClient: mockAIClient);

      final result = await service.generateStudyPlan(
        subject: 'Math',
        availableTime: '2 hours',
        focusType: 'Deep Work',
      );

      expect(
          result.contains(
              'Error generating study plan: Exception: Network Error'),
          isTrue);
    });
  });
}
