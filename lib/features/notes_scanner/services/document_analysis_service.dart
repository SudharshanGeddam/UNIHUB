import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/prompts/ai_prompts.dart';
import 'package:unihub/features/notes_scanner/models/document_content.dart';

class DocumentAnalysisService {
  final AIClient _aiClient;

  DocumentAnalysisService({AIClient? aiClient}) : _aiClient = aiClient ?? AIClient.instance;

  String getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf': return 'application/pdf';
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'webp': return 'image/webp';
      case 'gif': return 'image/gif';
      case 'txt': return 'text/plain';
      case 'md': return 'text/markdown';
      case 'csv': return 'text/csv';
      case 'json': return 'application/json';
      case 'xml': return 'application/xml';
      case 'html': return 'text/html';
      case 'js': return 'text/javascript';
      case 'py':
      case 'dart':
      case 'java':
      case 'c':
      case 'cpp':
      case 'h': return 'text/plain';
      default: return 'text/plain';
    }
  }

  Future<String> extractTextFromPdf(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      String extractedText = '';
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      for (int i = 0; i < document.pages.count; i++) {
        extractedText += extractor.extractText(startPageIndex: i, endPageIndex: i);
        extractedText += '\n\n--- Page \${i + 1} ---\n\n';
      }

      document.dispose();
      return extractedText.trim();
    } catch (e) {
      throw Exception('Failed to extract text from PDF: \$e');
    }
  }

  Future<DocumentContent> readDocument(String filePath) async {
    try {
      final file = File(filePath);
      final extension = filePath.toLowerCase().split('.').last;
      final bytes = await file.readAsBytes();
      final mimeType = getMimeType(extension);

      if (extension == 'pdf') {
        return DocumentContent(bytes: bytes, mimeType: mimeType, isPdf: true, textContent: null);
      }

      if (['txt', 'md', 'csv', 'json', 'xml', 'html', 'dart', 'py', 'js', 'java', 'c', 'cpp', 'h'].contains(extension)) {
        final text = await file.readAsString();
        return DocumentContent(bytes: null, mimeType: mimeType, isPdf: false, textContent: text);
      }

      throw Exception('Unsupported file type: \$extension');
    } catch (e) {
      throw Exception('Failed to read file: \$e');
    }
  }

  Future<String> chatWithDocument({
    required String documentContent,
    required String fileName,
    String? userMessage,
    Uint8List? fileBytes,
    String? mimeType,
  }) async {
    try {
      final userPrompt = userMessage ?? 'Please analyze this document and provide a summary of its key points, important concepts, and any notable information that would be helpful for studying.';

      if (fileBytes != null) {
        final extension = fileName.split('.').last.toLowerCase();
        final actualMimeType = mimeType ?? getMimeType(extension);

        final content = Content.multi([
          TextPart('I\'ve uploaded a file named "$fileName".\n\n$userPrompt'),
          DataPart(actualMimeType, fileBytes),
        ]);

        final chat = _aiClient.model.startChat();
        final response = await chat.sendMessage(content);
        return response.text ?? "I couldn't process the file. Please try again.";
      }

      final prompt = AIPrompts.chatWithDocumentTextPrompt(
        fileName: fileName,
        documentContent: documentContent,
        userPrompt: userPrompt,
      );

      final chat = _aiClient.model.startChat();
      final response = await chat.sendMessage(Content.text(prompt));
      return response.text ?? "I couldn't process the document. Please try again.";
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure your Gemini API key in lib/config/api_config.dart';
      }
      return 'Error analyzing document: \$e';
    }
  }

  Future<String> analyzeDocument({
    required String documentContent,
    required String fileName,
    required String analysisType,
    Uint8List? fileBytes,
    String? mimeType,
  }) async {
    final promptText = AIPrompts.documentAnalysisPrompt(fileName: fileName, analysisType: analysisType);

    try {
      if (fileBytes != null) {
        final extension = fileName.split('.').last.toLowerCase();
        final actualMimeType = mimeType ?? getMimeType(extension);

        final content = Content.multi([
          TextPart(promptText),
          DataPart(actualMimeType, fileBytes),
        ]);

        final response = await _aiClient.model.generateContent([content]);
        return response.text ?? 'Unable to analyze document. Please try again.';
      }

      final prompt = AIPrompts.documentAnalysisTextPrompt(promptText: promptText, documentContent: documentContent);
      final response = await _aiClient.model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Unable to analyze document. Please try again.';
    } catch (e) {
      if (e.toString().contains('API_KEY')) {
        return 'Please configure your Gemini API key in lib/config/api_config.dart';
      }
      return 'Error: \$e';
    }
  }
}
