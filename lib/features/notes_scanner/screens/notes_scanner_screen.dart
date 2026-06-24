import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unihub/core/utils/json_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unihub/widgets/bottom_nav.dart';
import 'package:unihub/features/notes_scanner/services/notes_conversion_service.dart';
import 'package:unihub/features/notes_scanner/services/pdf_generator_service.dart';
import 'package:unihub/features/notes_scanner/widgets/action_button.dart';
import 'package:unihub/features/notes_scanner/widgets/export_button.dart';
import 'package:unihub/features/notes_scanner/widgets/stat_chip.dart';
import 'package:unihub/features/notes_scanner/widgets/math_markdown_widget.dart';
import 'package:unihub/features/notes_scanner/models/structured_notes.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/widgets/api_key_missing_banner.dart';

class NotesScannerScreen extends StatefulWidget {
  const NotesScannerScreen({super.key});

  @override
  State<NotesScannerScreen> createState() => _NotesScannerScreenState();
}

class _NotesScannerScreenState extends State<NotesScannerScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final NotesConversionService _notesConversionService =
      NotesConversionService();

  File? _selectedImage;
  Uint8List? _imageBytes;
  String? _transcription;
  StructuredNotes? _structuredNotes;

  bool _isTranscribing = false;
  bool _isConverting = false;
  bool _isGeneratingPdf = false;

  int _currentStep = 0; // 0: Select, 1: Transcribe, 2: Convert, 3: Export

  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageBytes = bytes;
          _transcription = null;
          _structuredNotes = null;
          _currentStep = 1;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _transcribeImage() async {
    if (_imageBytes == null) return;

    setState(() => _isTranscribing = true);

    try {
      final extension = _selectedImage!.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'webp') mimeType = 'image/webp';

      final result = await _notesConversionService.transcribeHandwriting(
          _imageBytes!, mimeType);

      setState(() {
        _transcription = result;
        _currentStep = 2;
      });
    } catch (e) {
      _showError('Transcription failed: $e');
    } finally {
      setState(() => _isTranscribing = false);
    }
  }

  Future<void> _convertToStructuredNotes() async {
    if (_transcription == null || _transcription!.isEmpty) return;

    setState(() => _isConverting = true);

    try {
      final result = await _notesConversionService
          .convertToStructuredNotes(_transcription!);

      final extracted = extractJsonFromAiResponse(result);
      if (extracted == null) throw Exception('No JSON found in AI response');

      Map<String, dynamic> json;
      try {
        json = jsonDecode(extracted);
      } catch (e) {
        try {
          final sanitized =
              extracted.replaceAll('\n', ' ').replaceAll('\r', ' ');
          json = jsonDecode(sanitized);
        } catch (e2) {
          throw e;
        }
      }

      final notes = StructuredNotes.fromJson(json);

      setState(() {
        _structuredNotes = notes;
        _currentStep = 3;
      });
    } catch (e) {
      if (e.toString().contains('Unexpected end of input')) {
        _showError('Response truncated. Please try again.');
      } else {
        _showError('Failed to convert notes: $e');
      }
    } finally {
      setState(() => _isConverting = false);
    }
  }

  Future<void> _generateAndExportPdf() async {
    if (_structuredNotes == null) return;

    setState(() => _isGeneratingPdf = true);

    try {
      final pdfBytes =
          await PdfGeneratorService.generateNotesPdf(_structuredNotes!);

      _showExportOptions(pdfBytes);
    } catch (e) {
      _showError('PDF generation failed: $e');
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  void _showExportOptions(Uint8List pdfBytes) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Export Notes PDF',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _structuredNotes?.title ?? 'Your Notes',
              style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ExportButton(
                    icon: Icons.preview_rounded,
                    label: 'Preview',
                    color: colorScheme.secondary,
                    onTap: () async {
                      Navigator.pop(context);
                      await PdfGeneratorService.previewPdf(pdfBytes);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ExportButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    color: colorScheme.tertiary,
                    onTap: () async {
                      Navigator.pop(context);
                      final fileName =
                          _structuredNotes?.title.replaceAll(' ', '_') ??
                              'notes';
                      await PdfGeneratorService.sharePdf(pdfBytes, fileName);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ExportButton(
              icon: Icons.save_rounded,
              label: 'Save to Device',
              color: colorScheme.primary,
              fullWidth: true,
              onTap: () async {
                Navigator.pop(context);
                final fileName =
                    _structuredNotes?.title.replaceAll(' ', '_') ?? 'notes';
                final path =
                    await PdfGeneratorService.savePdf(pdfBytes, fileName);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Saved to: $path',
                          style: TextStyle(
                              color: colorScheme.onSecondaryContainer)),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(color: colorScheme.onErrorContainer)),
        backgroundColor: colorScheme.errorContainer,
      ),
    );
  }

  void _reset() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
      _transcription = null;
      _structuredNotes = null;
      _currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (AIClient.tryGetInstance() == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: const Center(
            child: ApiKeyMissingBanner(featureName: 'Notes Scanner')),
        bottomNavigationBar: const BottomNav(),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(
          children: [
            // Header
            _buildHeader(colorScheme),

            // Progress Steps
            _buildProgressSteps(colorScheme),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStepContent(colorScheme),
              ),
            ),

            const BottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.document_scanner_rounded,
                  color: colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes Scanner',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Convert handwritten notes to PDF',
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            if (_currentStep > 0)
              IconButton(
                onPressed: _reset,
                icon: Icon(Icons.refresh_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.7)),
                tooltip: 'Start Over',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps(ColorScheme colorScheme) {
    final steps = ['Select', 'Draft', 'Convert', 'Export'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;

          return Flexible(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? colorScheme.primary : colorScheme.surface,
                    shape: BoxShape.circle,
                    border: isCurrent
                        ? Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.5),
                            width: 2)
                        : Border.all(
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.1)),
                  ),
                  child: Center(
                    child: isActive && index < _currentStep
                        ? Icon(Icons.check,
                            color: colorScheme.onPrimary, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  steps[index],
                  style: TextStyle(
                    color: isActive
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: index < _currentStep
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent(ColorScheme colorScheme) {
    switch (_currentStep) {
      case 0:
        return _buildImageSelectionStep(colorScheme);
      case 1:
        return _buildTranscriptionStep(colorScheme);
      case 2:
        return _buildConversionStep(colorScheme);
      case 3:
        return _buildExportStep(colorScheme);
      default:
        return _buildImageSelectionStep(colorScheme);
    }
  }

  Widget _buildImageSelectionStep(ColorScheme colorScheme) {
    return Column(
      children: [
        const SizedBox(height: 20),
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    width: 2),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: colorScheme.primary,
                size: 60,
              ),
            ),
          ),
        ).animate().fadeIn(duration: 600.ms),
        const SizedBox(height: 32),
        Text(
          'Capture Your Notes',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        Text(
          'Take a photo or select from gallery\nto convert handwritten notes to digital format',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
              height: 1.5),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.camera_alt_rounded,
                label: 'Camera',
                color: colorScheme.primary,
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                icon: Icons.photo_library_rounded,
                label: 'Gallery',
                color: colorScheme.secondary,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: colorScheme.tertiary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'For best results, ensure good lighting and keep your handwriting visible.',
                  style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildTranscriptionStep(ColorScheme colorScheme) {
    return Column(
      children: [
        // Image Preview
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.5), width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _selectedImage != null
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : Container(color: colorScheme.surface),
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 24),
        Text(
          'Image Ready',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          'AI will transcribe your handwriting accurately',
          style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 32),
        ActionButton(
          icon: Icons.text_fields_rounded,
          label: _isTranscribing ? 'Transcribing...' : 'Transcribe Notes',
          color: colorScheme.primary,
          isLoading: _isTranscribing,
          onTap: _isTranscribing ? null : _transcribeImage,
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => setState(() => _currentStep = 0),
          icon: Icon(Icons.arrow_back_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6)),
          label: Text('Choose Different Image',
              style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.6))),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildConversionStep(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transcription Result',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: SingleChildScrollView(
            child: MathMarkdownWidget(text: _transcription ?? ''),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 24),
        Text(
          'Convert to Smart Notes',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 8),
        Text(
          'AI will extract key points, definitions, create flashcards & quiz questions',
          style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 13),
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 20),
        ActionButton(
          icon: Icons.auto_awesome_rounded,
          label: _isConverting ? 'Converting...' : 'Generate Smart Notes',
          color: colorScheme.secondary,
          isLoading: _isConverting,
          onTap: _isConverting ? null : _convertToStructuredNotes,
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _currentStep = 1),
              icon: Icon(Icons.arrow_back_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 18),
              label: Text('Back',
                  style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6))),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: _reset,
              icon: Icon(Icons.refresh_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 18),
              label: Text('Start Over',
                  style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6))),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildExportStep(ColorScheme colorScheme) {
    if (_structuredNotes == null) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded,
                    color: colorScheme.onSecondary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes Generated!',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your smart notes are ready to export',
                      style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
        const SizedBox(height: 24),

        // Notes Preview
        Text(
          _structuredNotes!.title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),

        // Stats
        Row(
          children: [
            StatChip(
              icon: Icons.lightbulb_outline,
              label: '${_structuredNotes!.keyPoints.length} Key Points',
              color: colorScheme.tertiary,
            ),
            const SizedBox(width: 8),
            StatChip(
              icon: Icons.style_outlined,
              label: '${_structuredNotes!.flashcards.length} Flashcards',
              color: colorScheme.primary,
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 8),
        Row(
          children: [
            StatChip(
              icon: Icons.quiz_outlined,
              label: '${_structuredNotes!.quizQuestions.length} Questions',
              color: colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            StatChip(
              icon: Icons.book_outlined,
              label: '${_structuredNotes!.definitions.length} Definitions',
              color: colorScheme.error, // or another contrast color
            ),
          ],
        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 24),

        // Summary Preview
        if (_structuredNotes!.summary.isNotEmpty) ...[
          Text(
            'Summary',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _structuredNotes!.summary,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
        ],

        // Export Button
        ActionButton(
          icon: Icons.picture_as_pdf_rounded,
          label: _isGeneratingPdf ? 'Generating PDF...' : 'Export as PDF',
          color: colorScheme.primary,
          isLoading: _isGeneratingPdf,
          onTap: _isGeneratingPdf ? null : _generateAndExportPdf,
        ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: _reset,
            icon: Icon(Icons.add_photo_alternate_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.6), size: 18),
            label: Text('Scan Another Page',
                style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6))),
          ),
        ).animate().fadeIn(delay: 800.ms),
      ],
    );
  }
}
