import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:unihub/features/chat/models/chat_message.dart';
import 'package:unihub/features/chat/widgets/message_bubble.dart';
import 'package:unihub/features/chat/widgets/quick_action_tile.dart';
import 'package:unihub/features/chat/widgets/typing_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:unihub/features/chat/services/chat_service.dart';
import 'package:unihub/features/notes_scanner/services/document_analysis_service.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = ChatService();
  final _docService = DocumentAnalysisService();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Document upload state
  String? _uploadedFileName;
  String? _uploadedFileContent;
  Uint8List? _uploadedFileBytes; // For native PDF/image processing
  bool _isProcessingFile = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text:
          "Hi! I'm UniHub AI 🎓\n\nI can help you with:\n• **Study planning** and scheduling\n• **Academic doubts** and explanations\n• **Exam preparation** tips\n• **Document analysis** - Upload PDFs, notes, or study materials!\n\nTap the **+** button to upload documents or use quick actions.\n\nHow can I assist you today?",
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty &&
        _uploadedFileContent == null &&
        _uploadedFileBytes == null) return;

    final hasDocument =
        _uploadedFileContent != null || _uploadedFileBytes != null;
    final fileName = _uploadedFileName;
    final fileContent = _uploadedFileContent;
    final fileBytes = _uploadedFileBytes;

    setState(() {
      _messages.add(ChatMessage(
        text: message.isEmpty && hasDocument
            ? 'Analyze this document: $fileName'
            : message,
        isUser: true,
        attachedFileName: hasDocument ? fileName : null,
        hasAttachment: hasDocument,
      ));
      _isLoading = true;
      // Clear the uploaded file after sending
      _uploadedFileName = null;
      _uploadedFileContent = null;
      _uploadedFileBytes = null;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      String response;
      if (hasDocument) {
        // Use native vision processing if file bytes are available (PDF or image)
        response = await _docService.chatWithDocument(
          documentContent: fileContent ?? '',
          fileName: fileName ?? 'document',
          userMessage: message.isEmpty ? null : message,
          fileBytes: fileBytes, // Pass file bytes for native vision processing
        );
      } else {
        response = await _chatService.chat(message);
      }

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'txt',
          'md',
          'csv',
          'json',
          'xml',
          'html',
          'png',
          'jpg',
          'jpeg',
          'webp'
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;

        if (filePath == null) {
          _showSnackBar('Could not access the file');
          return;
        }

        setState(() {
          _isProcessingFile = true;
        });

        try {
          final extension = filePath.toLowerCase().split('.').last;
          final isPdf = extension == 'pdf';
          final isImage = ['png', 'jpg', 'jpeg', 'webp'].contains(extension);

          if (isPdf || isImage) {
            // For PDFs and images, read bytes for native Gemini vision processing
            final fileObj = File(filePath);
            final bytes = await fileObj.readAsBytes();

            // Check file size (Gemini supports up to ~20MB inline)
            if (bytes.length > 20 * 1024 * 1024) {
              _showSnackBar('File too large. Please use a file under 20MB.');
              setState(() => _isProcessingFile = false);
              return;
            }

            setState(() {
              _uploadedFileName = file.name;
              _uploadedFileBytes = bytes;
              _uploadedFileContent = null; // Uses native vision processing
              _isProcessingFile = false;
            });

            final fileType = isPdf ? 'PDF' : 'image';
            _showSnackBar(
                '📄 ${file.name} attached (native $fileType processing)');
          } else {
            // For text files, extract content
            final docContent = await _docService.readDocument(filePath);
            final content = docContent.textContent ?? '';

            // Check if content is too long (Gemini has token limits)
            final truncatedContent = content.length > 30000
                ? '${content.substring(0, 30000)}\n\n[Document truncated due to length...]'
                : content;

            setState(() {
              _uploadedFileName = file.name;
              _uploadedFileContent = truncatedContent;
              _uploadedFileBytes = null;
              _isProcessingFile = false;
            });

            _showSnackBar('📄 ${file.name} attached');
          }
        } catch (e) {
          setState(() {
            _isProcessingFile = false;
          });
          _showSnackBar(
              'Error reading file: ${e.toString().replaceAll('Exception: ', '')}');
        }
      }
    } catch (e) {
      _showSnackBar('Error picking file: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _removeAttachment() {
    setState(() {
      _uploadedFileName = null;
      _uploadedFileContent = null;
      _uploadedFileBytes = null;
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear the chat history?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text: "Chat cleared! How can I help you?",
                  isUser: false,
                ));
              });
              _chatService.resetChat();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UniHub AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(10, 2, 46, 1),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/agent_home.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isLoading) {
                      return const TypingIndicator();
                    }
                    return MessageBubble(message: _messages[index]);
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(10, 2, 46, 0.9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show attached file indicator
                      if (_uploadedFileName != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 43, 52, 227)
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color.fromARGB(255, 43, 52, 227)
                                  .withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.description,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _uploadedFileName!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              InkWell(
                                onTap: () => _showDocumentActions(context),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _removeAttachment,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white70,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Show processing indicator
                      if (_isProcessingFile)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.orange,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Processing document...',
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _uploadedFileName != null
                                  ? const Color.fromARGB(255, 43, 52, 227)
                                  : const Color.fromARGB(255, 85, 86, 91),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _showQuickActions(context),
                              icon: Icon(
                                _uploadedFileName != null
                                    ? Icons.description
                                    : Icons.add,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: _uploadedFileName != null
                                    ? 'Ask about the document...'
                                    : 'Ask UniHub AI...',
                                hintStyle:
                                    const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 85, 86, 91),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 43, 52, 227),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: _isLoading || _isProcessingFile
                                  ? null
                                  : _sendMessage,
                              icon: const Icon(Icons.send, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            QuickActionTile(
              icon: Icons.upload_file,
              title: 'Upload Document',
              subtitle: 'PDF, images, TXT, MD, CSV files',
              onTap: () {
                Navigator.pop(context);
                _pickDocument();
              },
            ),
            QuickActionTile(
              icon: Icons.school,
              title: 'Explain a concept',
              onTap: () {
                Navigator.pop(context);
                _messageController.text = 'Explain the concept of ';
              },
            ),
            QuickActionTile(
              icon: Icons.quiz,
              title: 'Practice questions',
              onTap: () {
                Navigator.pop(context);
                _messageController.text = 'Give me practice questions on ';
              },
            ),
            QuickActionTile(
              icon: Icons.summarize,
              title: 'Summarize topic',
              onTap: () {
                Navigator.pop(context);
                _messageController.text = 'Summarize the topic: ';
              },
            ),
            QuickActionTile(
              icon: Icons.lightbulb,
              title: 'Study tips',
              onTap: () {
                Navigator.pop(context);
                _messageController.text = 'Give me study tips for ';
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description, color: Colors.white70),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _uploadedFileName ?? 'Document',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'What would you like to do with this document?',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            QuickActionTile(
              icon: Icons.summarize,
              title: 'Summarize',
              subtitle: 'Get a summary of key points',
              onTap: () {
                Navigator.pop(context);
                _messageController.text =
                    'Please summarize this document and highlight the key points.';
                _sendMessage();
              },
            ),
            QuickActionTile(
              icon: Icons.school,
              title: 'Exam Prep',
              subtitle: 'Generate exam questions & tips',
              onTap: () {
                Navigator.pop(context);
                _messageController.text =
                    'Help me prepare for exams using this document. Generate potential questions and key concepts.';
                _sendMessage();
              },
            ),
            QuickActionTile(
              icon: Icons.note_alt,
              title: 'Create Notes',
              subtitle: 'Convert to organized study notes',
              onTap: () {
                Navigator.pop(context);
                _messageController.text =
                    'Convert this document into well-organized study notes.';
                _sendMessage();
              },
            ),
            QuickActionTile(
              icon: Icons.help_outline,
              title: 'Ask Questions',
              subtitle: 'Ask anything about this document',
              onTap: () {
                Navigator.pop(context);
                // Just close, user can type their question
              },
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _removeAttachment();
              },
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              label: const Text('Remove Document',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}


