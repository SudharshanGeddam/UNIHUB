import 'package:flutter_test/flutter_test.dart';
import 'package:unihub/features/notes_scanner/models/structured_notes.dart';

void main() {
  group('StructuredNotes.fromJson', () {
    test('parses complete valid JSON', () {
      final json = {
        'title': 'Quantum Mechanics Notes',
        'key_points': ['Wave-particle duality', 'Uncertainty principle'],
        'definitions': [
          {'term': 'Photon', 'definition': 'A quantum of light'},
        ],
        'formulas': [
          {'name': "Planck's law", 'formula': 'E = hf'},
        ],
        'examples': [
          {'title': 'Photoelectric effect', 'description': 'Light ejects electrons'},
        ],
        'flashcards': [
          {'question': 'What is a photon?', 'answer': 'A particle of light'},
        ],
        'quiz_questions': [
          {
            'question': 'What is h?',
            'options': ['Planck constant', 'Gravitational constant'],
            'correct': 'Planck constant',
          },
        ],
        'summary': 'Overview of quantum principles.',
      };

      final notes = StructuredNotes.fromJson(json);

      expect(notes.title, 'Quantum Mechanics Notes');
      expect(notes.keyPoints.length, 2);
      expect(notes.definitions.length, 1);
      expect(notes.definitions[0]['term'], 'Photon');
      expect(notes.formulas.length, 1);
      expect(notes.examples.length, 1);
      expect(notes.flashcards.length, 1);
      expect(notes.quizQuestions.length, 1);
      expect(notes.summary, isNotEmpty);
    });

    test('uses default title when missing', () {
      final notes = StructuredNotes.fromJson({});
      expect(notes.title, 'Untitled Notes');
    });

    test('handles empty arrays correctly', () {
      final json = {
        'title': 'Empty',
        'key_points': <String>[],
        'definitions': <Map<String, String>>[],
        'formulas': <Map<String, String>>[],
        'examples': <Map<String, String>>[],
        'flashcards': <Map<String, String>>[],
        'quiz_questions': <Map<String, dynamic>>[],
        'summary': '',
      };
      final notes = StructuredNotes.fromJson(json);
      expect(notes.keyPoints, isEmpty);
      expect(notes.definitions, isEmpty);
      expect(notes.flashcards, isEmpty);
      expect(notes.quizQuestions, isEmpty);
    });

    test('applies empty list defaults for missing array fields', () {
      final notes = StructuredNotes.fromJson({'title': 'Partial'});
      expect(notes.keyPoints, isEmpty);
      expect(notes.definitions, isEmpty);
      expect(notes.formulas, isEmpty);
      expect(notes.examples, isEmpty);
      expect(notes.flashcards, isEmpty);
      expect(notes.quizQuestions, isEmpty);
      expect(notes.summary, '');
    });
  });
}
