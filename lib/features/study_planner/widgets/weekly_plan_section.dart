import 'package:flutter/material.dart';
import 'package:unihub/features/study_planner/models/study_plan_model.dart';
import 'package:unihub/features/study_planner/widgets/study_task_extensions.dart';

class WeeklyPlanSection extends StatelessWidget {
  final StudyPlanModel studyPlan;
  final Map<int, bool> expandedTasks;
  final Map<int, Set<int>> completedTopics;
  final Function(int) onTaskToggle;
  final Function(int, int) onTopicToggle;

  const WeeklyPlanSection({
    super.key,
    required this.studyPlan,
    required this.expandedTasks,
    required this.completedTopics,
    required this.onTaskToggle,
    required this.onTopicToggle,
  });

  double _getTaskProgress(int taskIndex) {
    final task = studyPlan.weeklyTasks[taskIndex];
    if (task.topics.isEmpty) return 0.0;
    final completed = completedTopics[taskIndex]?.length ?? 0;
    return completed / task.topics.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3F).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("This Week's Plan",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (studyPlan.weeklyTasks.isEmpty)
            _buildEmptyTasksPlaceholder()
          else
            ...List.generate(studyPlan.weeklyTasks.length, (index) {
              final task = studyPlan.weeklyTasks[index];
              return _buildExpandableTaskItem(task, index,
                  isLast: index == studyPlan.weeklyTasks.length - 1);
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12)),
      child: Center(
          child: Text('No tasks generated. Try regenerating the plan.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
    );
  }

  Widget _buildExpandableTaskItem(StudyTaskModel task, int taskIndex,
      {bool isLast = false}) {
    final isExpanded = expandedTasks[taskIndex] ?? false;
    final progress = _getTaskProgress(taskIndex);
    final completedCount = completedTopics[taskIndex]?.length ?? 0;
    final totalTopics = task.topics.length;

    // Create topics preview string for subtitle
    final topicsPreview = task.topics.isNotEmpty
        ? task.topics.map((t) => t.name).join(', ')
        : task.subtitle;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? task.color.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header (clickable to expand/collapse)
          InkWell(
            onTap: () => onTaskToggle(taskIndex),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon container
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: task.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(task.icon, color: task.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          topicsPreview,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Time badge and arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: task.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${task.hoursLeft}h left',
                          style: TextStyle(
                            color: task.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expandable content with progress and topics
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                // Progress bar inside expanded area
                if (totalTopics > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(task.color),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completedCount/$totalTopics',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildTopicsList(task, taskIndex),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsList(StudyTaskModel task, int taskIndex) {
    if (task.topics.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Text(
          'No specific topics available',
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 13,
              fontStyle: FontStyle.italic),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(task.topics.length, (topicIndex) {
            final topic = task.topics[topicIndex];
            final isCompleted =
                completedTopics[taskIndex]?.contains(topicIndex) ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onTopicToggle(taskIndex, topicIndex),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? task.color.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCompleted
                          ? task.color.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Custom checkbox - circular style
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isCompleted ? task.color : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? task.color
                                : Colors.white.withValues(alpha: 0.25),
                            width: 2,
                          ),
                          boxShadow: isCompleted
                              ? [
                                  BoxShadow(
                                    color: task.color.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.name,
                              style: TextStyle(
                                color: isCompleted
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.95),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor:
                                    Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            if (topic.description.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                topic.description,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  fontSize: 12,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor:
                                      Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
