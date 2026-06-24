import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unihub/features/notes_scanner/models/structured_notes.dart';
import 'package:unihub/features/notes_scanner/widgets/stat_chip.dart';
import 'package:unihub/features/notes_scanner/widgets/action_button.dart';
import 'package:unihub/features/notes_scanner/services/pdf_generator_service.dart';
import 'package:go_router/go_router.dart';

class GeneratedNotesScreen extends StatefulWidget {
  final StructuredNotes structuredNotes;
  final String focusType;

  const GeneratedNotesScreen({
    super.key,
    required this.structuredNotes,
    required this.focusType,
  });

  @override
  State<GeneratedNotesScreen> createState() => _GeneratedNotesScreenState();
}

class _GeneratedNotesScreenState extends State<GeneratedNotesScreen> {
  bool _isGeneratingPdf = false;

  Future<void> _generateAndExportPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes =
          await PdfGeneratorService.generateNotesPdf(widget.structuredNotes);
      await PdfGeneratorService.sharePdf(
          pdfBytes, 'unihub_${widget.focusType.toLowerCase()}_notes');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF ready to share/save!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notes = widget.structuredNotes;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.focusType} Content'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorScheme.secondary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome_rounded,
                        color: colorScheme.onSecondary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Generated!',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your smart ${widget.focusType.toLowerCase()} are ready.',
                          style: TextStyle(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
            const SizedBox(height: 24),

            // Notes Title
            Text(
              notes.title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 20),

            // Stats
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatChip(
                  icon: Icons.lightbulb_outline,
                  label: '${notes.keyPoints.length} Key Points',
                  color: colorScheme.tertiary,
                ),
                StatChip(
                  icon: Icons.style_outlined,
                  label: '${notes.flashcards.length} Flashcards',
                  color: colorScheme.primary,
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatChip(
                  icon: Icons.quiz_outlined,
                  label: '${notes.quizQuestions.length} Questions',
                  color: colorScheme.secondary,
                ),
                StatChip(
                  icon: Icons.book_outlined,
                  label: '${notes.definitions.length} Definitions',
                  color: colorScheme.error,
                ),
              ],
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
            const SizedBox(height: 32),

            // Summary Preview
            if (notes.summary.isNotEmpty) ...[
              _buildSectionTitle(context, 'Summary', Icons.subject_rounded),
              _buildCard(
                  context,
                  Text(
                    notes.summary,
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // Key Points
            if (notes.keyPoints.isNotEmpty) ...[
              _buildSectionTitle(
                  context, 'Key Points', Icons.format_list_bulleted_rounded),
              _buildCard(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: notes.keyPoints
                      .map((point) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.circle,
                                        size: 8, color: colorScheme.primary)
                                    .animate()
                                    .scale(delay: 200.ms),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    point,
                                    style: TextStyle(
                                        color: colorScheme.onSurface
                                            .withValues(alpha: 0.9),
                                        fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Definitions
            if (notes.definitions.isNotEmpty) ...[
              _buildSectionTitle(
                  context, 'Definitions', Icons.menu_book_rounded),
              ...notes.definitions.map((def) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildCard(
                      context,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            def['term'] ?? '',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            def['definition'] ?? '',
                            style: TextStyle(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
            ],

            // Formulas
            if (notes.formulas.isNotEmpty) ...[
              _buildSectionTitle(context, 'Formulas', Icons.functions_rounded),
              ...notes.formulas.map((formula) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildCard(
                      context,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formula['name'] ?? '',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              formula['formula'] ?? '',
                              style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (formula['description']?.isNotEmpty == true) ...[
                            const SizedBox(height: 8),
                            Text(
                              formula['description']!,
                              style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic),
                            ),
                          ]
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
            ],

            // Examples
            if (notes.examples.isNotEmpty) ...[
              _buildSectionTitle(
                  context, 'Examples', Icons.lightbulb_outline_rounded),
              ...notes.examples.map((example) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildCard(
                      context,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            example['title'] ?? 'Example',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            example['content'] ?? '',
                            style: TextStyle(
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.8),
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),
            ],

            // Flashcards
            if (notes.flashcards.isNotEmpty) ...[
              _buildSectionTitle(context, 'Flashcards', Icons.style_outlined),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: notes.flashcards.length,
                  itemBuilder: (context, index) {
                    final card = notes.flashcards[index];
                    return Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.1),
                            colorScheme.tertiary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Card ${index + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Q: ${card['front'] ?? ''}',
                            style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Divider(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.2)),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              'A: ${card['back'] ?? ''}',
                              style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                                  fontSize: 12),
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Quiz Questions
            if (notes.quizQuestions.isNotEmpty) ...[
              _buildSectionTitle(
                  context, 'Quiz Questions', Icons.quiz_outlined),
              ...notes.quizQuestions.asMap().entries.map((entry) {
                final index = entry.key;
                final q = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _buildCard(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary
                                    .withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                q['question'] ?? '',
                                style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (q['options'] != null)
                          ...List<String>.from(q['options'])
                              .map((opt) => Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 6.0, left: 36),
                                    child: Text(
                                      opt,
                                      style: TextStyle(
                                          color: colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                          fontSize: 13),
                                    ),
                                  )),
                        const SizedBox(height: 12),
                        Container(
                          margin: const EdgeInsets.only(left: 36),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Answer: ',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                TextSpan(
                                  text: q['answer'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.green, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // Export Button
            ActionButton(
              icon: Icons.picture_as_pdf_rounded,
              label: _isGeneratingPdf
                  ? 'Generating PDF...'
                  : 'Export Full Content as PDF',
              color: colorScheme.primary,
              isLoading: _isGeneratingPdf,
              onTap: _isGeneratingPdf ? null : _generateAndExportPdf,
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildCard(BuildContext context, Widget child) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
