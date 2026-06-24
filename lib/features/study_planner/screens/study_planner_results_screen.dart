import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unihub/features/study_planner/models/study_plan_model.dart';
import 'package:unihub/features/study_planner/widgets/ai_recommendations_card.dart';
import 'package:unihub/features/study_planner/widgets/study_streak_section.dart';
import 'package:unihub/features/study_planner/widgets/weekly_plan_section.dart';
import 'package:unihub/features/study_planner/widgets/key_topics_section.dart';
import 'package:unihub/features/study_planner/widgets/study_techniques_section.dart';
import 'package:unihub/features/study_planner/widgets/focus_mode_section.dart';

class StudyPlannerResults extends StatefulWidget {
  final String subject;
  final String availableTime;
  final String focusType;
  final StudyPlanModel studyPlan;

  const StudyPlannerResults({
    super.key,
    required this.subject,
    required this.availableTime,
    required this.focusType,
    required this.studyPlan,
  });

  @override
  State<StudyPlannerResults> createState() => _StudyPlannerResultsState();
}

class _StudyPlannerResultsState extends State<StudyPlannerResults>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Track expanded state for each task card
  final Map<int, bool> _expandedTasks = {};
  // Track completed topics: taskIndex -> Set of topic indices
  final Map<int, Set<int>> _completedTopics = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Initialize tracking maps
    for (int i = 0; i < widget.studyPlan.weeklyTasks.length; i++) {
      _expandedTasks[i] = false;
      _completedTopics[i] = {};
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate progress for a task
  double _getTaskProgress(int taskIndex) {
    final task = widget.studyPlan.weeklyTasks[taskIndex];
    if (task.topics.isEmpty) return 0.0;
    final completed = _completedTopics[taskIndex]?.length ?? 0;
    return completed / task.topics.length;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.15),
                    colorScheme.primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.tertiary.withOpacity(0.15),
                    colorScheme.tertiary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.secondary.withOpacity(0.15),
                    colorScheme.secondary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(colorScheme),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AIRecommendationsCard(studyPlan: widget.studyPlan),
                          const SizedBox(height: 24),
                          StudyStreakSection(
                              streakDays: widget.studyPlan.streakDays),
                          const SizedBox(height: 24),
                          WeeklyPlanSection(
                            studyPlan: widget.studyPlan,
                            expandedTasks: _expandedTasks,
                            completedTopics: _completedTopics,
                            onTaskToggle: (taskIndex) {
                              setState(() {
                                _expandedTasks[taskIndex] =
                                    !(_expandedTasks[taskIndex] ?? false);
                              });
                            },
                            onTopicToggle: (taskIndex, topicIndex) {
                              setState(() {
                                final isCompleted = _completedTopics[taskIndex]
                                        ?.contains(topicIndex) ??
                                    false;
                                if (isCompleted) {
                                  _completedTopics[taskIndex]
                                      ?.remove(topicIndex);
                                } else {
                                  _completedTopics[taskIndex]?.add(topicIndex);
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          if (widget.studyPlan.keyTopics.isNotEmpty) ...[
                            KeyTopicsSection(
                                keyTopics: widget.studyPlan.keyTopics),
                            const SizedBox(height: 24),
                          ],
                          if (widget.studyPlan.studyTechniques.isNotEmpty) ...[
                            StudyTechniquesSection(
                              techniques: widget.studyPlan.studyTechniques,
                              breakRecommendation:
                                  widget.studyPlan.breakRecommendation,
                            ),
                            const SizedBox(height: 24),
                          ],
                          FocusModeSection(
                            subject: widget.subject,
                            focusType: widget.focusType,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
          ),
          Expanded(
            child: Text(
              'AI Study Planner',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.onSurface.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: Icon(Icons.settings_outlined,
                  color: colorScheme.onSurface.withOpacity(0.7)),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
