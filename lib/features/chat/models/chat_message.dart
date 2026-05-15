class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? attachedFileName;
  final bool hasAttachment;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.attachedFileName,
    this.hasAttachment = false,
  }) : timestamp = timestamp ?? DateTime.now();
}
