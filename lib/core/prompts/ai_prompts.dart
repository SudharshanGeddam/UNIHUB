class AIPrompts {
  static String studyPlanPrompt({
    required String subject,
    required String availableTime,
    required String focusType,
    String? additionalContext,
  }) {
    return '''
You are an AI Study Planner. Create a personalized study plan based on the following inputs:

**Subject/Topic:** $subject
**Available Time:** $availableTime
**Focus Type:** $focusType
${additionalContext != null ? '**Additional Context:** $additionalContext' : ''}

IMPORTANT: Respond ONLY with a valid JSON object (no markdown, no explanation, just pure JSON).

Use this exact JSON structure:
{
  "recommendation": "A personalized AI recommendation message about what to focus on today based on the subject and time available (1-2 sentences)",
  "motivational_tip": "A short motivational quote or tip to keep the student motivated",
  "streak_days": 7,
  "weekly_tasks": [
    {
      "title": "Main subject or topic name",
      "subtitle": "Brief description of focus area",
      "hours_left": 4,
      "chapters": "Chapter numbers or section names",
      "priority": "high",
      "topics": [
        {"name": "Specific topic 1 to study", "description": "Brief description of what to cover"},
        {"name": "Specific topic 2 to study", "description": "Brief description of what to cover"},
        {"name": "Specific topic 3 to study", "description": "Brief description of what to cover"}
      ]
    },
    {
      "title": "Second task (like Review or Practice)",
      "subtitle": "Description of what to do",
      "hours_left": 2,
      "chapters": "Related topics",
      "priority": "medium",
      "topics": [
        {"name": "Topic to review", "description": "What to focus on"},
        {"name": "Practice area", "description": "Types of problems to solve"}
      ]
    }
  ],
  "key_topics": ["Topic 1", "Topic 2", "Topic 3", "Topic 4"],
  "study_techniques": ["Technique 1 suited for the focus type", "Technique 2", "Technique 3"],
  "break_recommendation": "Specific break schedule recommendation"
}

Rules:
- Create 2-4 weekly_tasks based on the subject and available time
- Each weekly_task MUST have 2-5 specific topics with name and description
- priority must be one of: "high", "medium", "low"
- hours_left should be realistic based on available time
- Make the recommendation personalized and specific to the subject
- study_techniques should match the focus type (\$focusType)
- Topics should be specific, actionable items the student can check off
- Return ONLY the JSON, no other text
''';
  }

  static String doubtSolvingPrompt(String question, {String? subject}) {
    return '''
${subject != null ? 'Subject: $subject\n' : ''}Student Question: $question

Please provide:
1. A clear, step-by-step explanation
2. Examples if applicable
3. Key concepts to remember
4. Related topics to explore
''';
  }

  static String examPrepAnalysisPrompt(String content) {
    return '''
Analyze the following study material and provide exam preparation insights:

$content

Please provide:
1. Key concepts likely to be tested
2. Important definitions and formulas
3. Potential exam questions
4. Topics that need more focus
5. Quick revision points
''';
  }

  static String documentAnalysisPrompt({
    required String fileName,
    required String analysisType,
  }) {
    switch (analysisType) {
      case 'summary':
        return '''
Analyze this document "$fileName" and provide:
1. A comprehensive summary
2. Main topics covered
3. Key takeaways
''';
      case 'exam_prep':
        return '''
Analyze this document "$fileName" for exam preparation:
1. Key concepts likely to be tested
2. Important definitions and formulas
3. 5-10 potential exam questions with brief answers
4. Topics that need more focus
5. Quick revision bullet points
''';
      case 'notes':
        return '''
Convert this document "$fileName" into well-organized study notes:
1. Create clear headings and subheadings
2. Highlight key terms and definitions
3. Summarize complex concepts simply
4. Add bullet points for easy revision
5. Include any formulas or important data
''';
      case 'questions':
        return '''
Based on this document "$fileName", generate practice questions:
1. 5 Multiple Choice Questions (with correct answers)
2. 5 Short Answer Questions
3. 2-3 Essay/Long Answer Questions
4. Key concepts each question tests
''';
      default:
        return 'Analyze this document "$fileName" and help me understand it better.';
    }
  }

  static String documentAnalysisTextPrompt({
    required String promptText,
    required String documentContent,
  }) {
    return '''
$promptText

Document content:
$documentContent
''';
  }

  static String chatWithDocumentTextPrompt({
    required String fileName,
    required String documentContent,
    required String userPrompt,
  }) {
    return '''
I've uploaded a document named "$fileName". Here's its content:

---START OF DOCUMENT---
$documentContent
---END OF DOCUMENT---

$userPrompt
''';
  }

  static const String transcribeHandwritingPrompt = '''
Transcribe this handwritten page as accurately as possible.
Preserve line breaks and bullets.
If a word is unclear, output [UNK] (don't guess).
Return only plain text.
''';

  static String structuredNotesPrompt(String transcription) {
    return '''
Convert the following transcription into structured study notes.

TRANSCRIPTION:
$transcription

IMPORTANT: Respond ONLY with a valid JSON object (no markdown, no explanation, just pure JSON).
Ensure all strings are properly escaped. Do not use unescaped double quotes inside strings.
Ensure there are no trailing commas.
Ensure all newlines within strings are escaped as \\n.

Use this exact JSON structure:
{
  "title": "A descriptive title for these notes based on the content",
  "key_points": [
    "Key point 1",
    "Key point 2",
    "Key point 3"
  ],
  "definitions": [
    {"term": "Term 1", "definition": "Definition of term 1"},
    {"term": "Term 2", "definition": "Definition of term 2"}
  ],
  "formulas": [
    {"name": "Formula name", "formula": "The formula itself", "description": "What it's used for"}
  ],
  "examples": [
    {"title": "Example title", "content": "Example explanation or problem solved"}
  ],
  "flashcards": [
    {"front": "Question or term", "back": "Answer or definition"},
    {"front": "Question or term", "back": "Answer or definition"},
    {"front": "Question or term", "back": "Answer or definition"},
    {"front": "Question or term", "back": "Answer or definition"},
    {"front": "Question or term", "back": "Answer or definition"}
  ],
  "quiz_questions": [
    {"question": "Quiz question 1?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]},
    {"question": "Quiz question 2?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]},
    {"question": "Quiz question 3?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]},
    {"question": "Quiz question 4?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]},
    {"question": "Quiz question 5?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]}
  ],
  "summary": "A brief 2-3 sentence summary of the notes"
}

Rules:
- Generate at least 3 key_points from the content
- Extract all definitions found, or create 2-3 if none explicit
- Include formulas only if present in the notes, otherwise empty array
- Create examples from worked problems or create 1-2 based on content
- Generate exactly 5 flashcards for key concepts
- Generate exactly 5 quiz questions with 4 options each
- Make the title specific to the actual content
- Return ONLY the JSON, no other text
''';
  }

  static String generateTopicContentPrompt(String subject, String focusType) {
    return '''
Generate comprehensive and structured study materials for the following topic.

TOPIC:
$subject

FOCUS MODE:
$focusType

Adjust the emphasis of the content based on the FOCUS MODE:
- If "Notes", focus on detailed key points, definitions, and comprehensive coverage.
- If "Revision", focus on concise summaries, flashcards, and high-yield facts.
- If "Exam Prep", focus on quiz questions, potential exam topics, and examples.

IMPORTANT: Respond ONLY with a valid JSON object (no markdown, no explanation, just pure JSON).
Ensure all strings are properly escaped. Do not use unescaped double quotes inside strings.
Ensure there are no trailing commas.
Ensure all newlines within strings are escaped as \\n.

Use this exact JSON structure:
{
  "title": "A descriptive title based on the topic",
  "key_points": [
    "Detailed key point 1",
    "Detailed key point 2",
    "Detailed key point 3",
    "Detailed key point 4"
  ],
  "definitions": [
    {"term": "Important Term 1", "definition": "Definition"},
    {"term": "Important Term 2", "definition": "Definition"}
  ],
  "formulas": [
    {"name": "Formula name", "formula": "The formula itself", "description": "What it's used for"}
  ],
  "examples": [
    {"title": "Example title", "content": "Example explanation or problem solved"}
  ],
  "flashcards": [
    {"front": "Question or term", "back": "Answer or definition"},
    {"front": "Question or term", "back": "Answer or definition"},
    {"front": "Question or term", "back": "Answer or definition"},
    {"front": "Question or term", "back": "Answer or definition"},
    {"front": "Question or term", "back": "Answer or definition"}
  ],
  "quiz_questions": [
    {"question": "Quiz question 1?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]},
    {"question": "Quiz question 2?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]},
    {"question": "Quiz question 3?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]},
    {"question": "Quiz question 4?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]},
    {"question": "Quiz question 5?", "answer": "Correct answer", "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"]}
  ],
  "summary": "A brief 2-3 sentence summary of the generated material"
}

Rules:
- Generate 4-7 key_points
- Generate 3-5 definitions
- Include formulas only if relevant to the topic, otherwise empty array
- Create 1-3 practical examples
- Generate exactly 5 flashcards
- Generate exactly 5 quiz questions with 4 options each
- Make the title specific to the topic
- Return ONLY the JSON, no other text
''';
  }
}
