import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unihub/core/routing/app_router.dart';
import 'package:unihub/features/study_planner/repositories/study_plan_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SavedStudyPlansScreen extends StatefulWidget {
  const SavedStudyPlansScreen({super.key});

  @override
  State<SavedStudyPlansScreen> createState() => _SavedStudyPlansScreenState();
}

class _SavedStudyPlansScreenState extends State<SavedStudyPlansScreen> {
  final _repository = StudyPlanRepository();

  void _deletePlan(String planId) async {
    try {
      await _repository.deleteStudyPlan(planId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete plan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        leading: BackButton(color: colorScheme.onSurface),
        title: Text(
          'Saved Study Plans',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<SavedStudyPlan>>(
        stream: _repository.getStudyPlans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading plans: ${snapshot.error}',
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          final plans = snapshot.data ?? [];

          if (plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded,
                      size: 64,
                      color: colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No saved plans yet',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate a new study plan and save it.',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.1),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final savedPlan = plans[index];
              return Card(
                color: colorScheme.surface,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                    child: Icon(Icons.school, color: colorScheme.primary),
                  ),
                  title: Text(
                    savedPlan.title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${savedPlan.plan.weeklyTasks.length} tasks • ${savedPlan.focusType}',
                    style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    onPressed: () => _deletePlan(savedPlan.id),
                  ),
                  onTap: () {
                    context.push(
                      AppRoutes.studyPlannerResults,
                      extra: {
                        'subject': savedPlan.subject,
                        'availableTime': savedPlan.availableTime,
                        'focusType': savedPlan.focusType,
                        'studyPlan': savedPlan.plan,
                      },
                    );
                  },
                ),
              ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
            },
          );
        },
      ),
    );
  }
}
