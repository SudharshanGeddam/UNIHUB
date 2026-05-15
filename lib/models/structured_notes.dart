// Model class for structured notes
class StructuredNotes {
  final String title;
  final List<String> keyPoints;
  final List<Map<String, String>> definitions;
  final List<Map<String, String>> formulas;
  final List<Map<String, String>> examples;
  final List<Map<String, String>> flashcards;
  final List<Map<String, dynamic>> quizQuestions;
  final String summary;

  StructuredNotes({
    required this.title,
    required this.keyPoints,
    required this.definitions,
    required this.formulas,
    required this.examples,
    required this.flashcards,
    required this.quizQuestions,
    required this.summary,
  });

  factory StructuredNotes.fromJson(Map<String, dynamic> json) {
    return StructuredNotes(
      title: json['title'] ?? 'Untitled Notes',
      keyPoints: List<String>.from(json['key_points'] ?? []),
      definitions: (json['definitions'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      formulas: (json['formulas'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      flashcards: (json['flashcards'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      quizQuestions: (json['quiz_questions'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      summary: json['summary'] ?? '',
    );
  }
}
