/// Utilities for parsing JSON from Gemini AI responses.
///
/// The Gemini API sometimes wraps JSON in markdown code fences. These helpers
/// strip the fences and extract the raw JSON object reliably.
library;

/// Extracts a JSON string from an AI response that may be wrapped in
/// markdown code fences (` ```json ... ``` ` or ` ``` ... ``` `).
///
/// Returns the cleaned JSON string, or `null` if no JSON object is found.
/// Does **not** parse the JSON — call `dart:convert jsonDecode` on the result.
String? extractJsonFromAiResponse(String response) {
  if (response.isEmpty) return null;

  String jsonStr = response.trim();

  // Strip ```json ... ``` fences
  if (jsonStr.startsWith('```json')) {
    final start = jsonStr.indexOf('```json') + 7;
    final end = jsonStr.indexOf('```', start);
    if (end > start) {
      jsonStr = jsonStr.substring(start, end).trim();
    }
  } else if (jsonStr.startsWith('```')) {
    // Strip generic ``` ... ``` fences
    final start = jsonStr.indexOf('```') + 3;
    final end = jsonStr.indexOf('```', start);
    if (end > start) {
      jsonStr = jsonStr.substring(start, end).trim();
    }
  }

  // Find the outermost JSON object
  final jsonStart = jsonStr.indexOf('{');
  final jsonEnd = jsonStr.lastIndexOf('}');
  if (jsonStart == -1 || jsonEnd == -1 || jsonEnd <= jsonStart) return null;

  return jsonStr.substring(jsonStart, jsonEnd + 1);
}
