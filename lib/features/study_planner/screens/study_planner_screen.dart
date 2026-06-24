import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unihub/core/routing/app_router.dart';
import 'package:unihub/features/study_planner/services/study_plan_service.dart';
import 'package:unihub/features/study_planner/models/study_plan_model.dart';
import 'package:unihub/features/notes_scanner/models/structured_notes.dart';
import 'package:unihub/core/services/ai_client.dart';
import 'package:unihub/core/widgets/api_key_missing_banner.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StudyPlanner extends StatefulWidget {
  const StudyPlanner({super.key});

  @override
  State<StudyPlanner> createState() => _StudyPlannerState();
}

class _StudyPlannerState extends State<StudyPlanner> {
  final _subjectController = TextEditingController();
  final _timeController = TextEditingController();
  final _studyPlanService = StudyPlanService();

  String _selectedFocusType = 'Deep Work';
  bool _isGenerating = false;

  final List<String> _focusTypes = [
    'Deep Work',
    'Notes',
    'Revision',
    'Exam Prep',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _generateSchedule() async {
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter what you want to study'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your available time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      if (_selectedFocusType == 'Deep Work') {
        final plan = await _studyPlanService.generateStudyPlan(
          subject: _subjectController.text,
          availableTime: _timeController.text,
          focusType: _selectedFocusType,
        );

        // Parse the JSON response
        StudyPlanModel? parsedPlan = StudyPlanModel.parseFromResponse(plan);

        // If parsing failed, create a default plan
        parsedPlan ??= StudyPlanModel.createDefault(
          subject: _subjectController.text,
          availableTime: _timeController.text,
          focusType: _selectedFocusType,
        );

        setState(() => _isGenerating = false);

        // Navigate to results screen with parsed data
        if (mounted) {
          context.push(
            AppRoutes.studyPlannerResults,
            extra: {
              'subject': _subjectController.text,
              'availableTime': _timeController.text,
              'focusType': _selectedFocusType,
              'studyPlan': parsedPlan,
            },
          );
        }
      } else {
        // Topic Content generation for Notes, Revision, Exam Prep
        final content = await _studyPlanService.generateTopicContent(
          _subjectController.text,
          _selectedFocusType,
        );

        StructuredNotes? parsedNotes;
        try {
          final jsonRegex = RegExp(r'\{[\s\S]*\}');
          final match = jsonRegex.firstMatch(content);
          if (match != null) {
            final jsonStr = match.group(0)!;
            final decoded = jsonDecode(jsonStr);
            parsedNotes = StructuredNotes.fromJson(decoded);
          } else {
            final decoded = jsonDecode(content);
            parsedNotes = StructuredNotes.fromJson(decoded);
          }
        } catch (e) {
          debugPrint('Failed to parse topic content: $e');
        }

        if (parsedNotes == null) {
          throw Exception(
              'Failed to generate structured content. Please try again.');
        }

        setState(() => _isGenerating = false);

        if (mounted) {
          context.push(
            '/study-planner/generated-notes',
            extra: {
              'structuredNotes': parsedNotes,
              'focusType': _selectedFocusType,
            },
          );
        }
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AIClient.tryGetInstance() == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          title: const Text('Study Planner',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
        body: const Center(
            child: ApiKeyMissingBanner(featureName: 'Study Planner')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Column(
          children: [
            Text(
              'Study Planner',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'AI-powered study schedule',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
        toolbarHeight: 70,
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined, color: Colors.white),
            onPressed: () => context.push(AppRoutes.savedStudyPlans),
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
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What do you want to study?',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _subjectController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 85, 86, 91)
                          .withValues(alpha: 0.5),
                      hintText: 'E.g: Data Structures, Calculus...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.book, color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ).animate().fadeIn(delay: 50.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const Text(
                    'Available Time',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _timeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 85, 86, 91)
                          .withValues(alpha: 0.5),
                      hintText: 'E.g: 2 hours/day for 1 week',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon:
                          const Icon(Icons.schedule, color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  const Text(
                    'Focus Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _focusTypes.map((type) {
                      final isSelected = _selectedFocusType == type;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedFocusType = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : const Color.fromARGB(255, 85, 86, 91)
                                    .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(25),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isGenerating ? null : _generateSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isGenerating
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Generate Study Plan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
