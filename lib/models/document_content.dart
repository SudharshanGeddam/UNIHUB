import 'dart:typed_data';

// Helper class to hold document content
class DocumentContent {
  final Uint8List? bytes;
  final String mimeType;
  final bool isPdf;
  final String? textContent;

  DocumentContent({
    required this.bytes,
    required this.mimeType,
    required this.isPdf,
    required this.textContent,
  });
}
