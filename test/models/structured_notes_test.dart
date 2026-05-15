import 'package:flutter_test/flutter_test.dart';
import 'package:unihub/models/structured_notes.dart';

void main() {
  group('StructuredNotes', () {
    test('fromJson parses correctly', () {
      final json = {
        'title': 'Biology Notes',
        'summary': 'Cell structure',
        'key_points': ['Mitochondria is the powerhouse'],
        'flashcards': [
          {'front': 'What is a cell?', 'back': 'Basic unit of life'}
        ],
        'quiz_questions': [
          {
            'question': 'Which organelle produces energy?',
            'options': ['Nucleus', 'Mitochondria', 'Ribosome'],
            'correct_answer': 'Mitochondria'
          }
        ]
      };

      final notes = StructuredNotes.fromJson(json);
      expect(notes.title, 'Biology Notes');
      expect(notes.summary, 'Cell structure');
      expect(notes.keyPoints, contains('Mitochondria is the powerhouse'));
      
      expect(notes.flashcards.length, 1);
      expect(notes.flashcards.first['front'], 'What is a cell?');
      expect(notes.flashcards.first['back'], 'Basic unit of life');
      
      expect(notes.quizQuestions.length, 1);
      expect(notes.quizQuestions.first['question'], 'Which organelle produces energy?');
      expect(notes.quizQuestions.first['options'], contains('Nucleus'));
      expect(notes.quizQuestions.first['correct_answer'], 'Mitochondria');
    });
  });
}
