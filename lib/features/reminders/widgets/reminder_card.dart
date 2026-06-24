import 'package:flutter/material.dart';
import 'package:unihub/features/reminders/models/reminder_model.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getIconConfig();

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF5252).withValues(alpha: 0.8),
              const Color(0xFFFF1744).withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E3F).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: config.iconColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        config.iconColor,
                        config.iconColor.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIcon(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reminder.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              if (reminder.isAiSuggestion) _buildAiTag(),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            reminder.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.65),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reminder.timeAgo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final config = _getIconConfig();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.iconColor.withValues(alpha: 0.25),
            config.iconColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: config.iconColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: config.iconColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        config.icon,
        color: config.iconColor,
        size: 22,
      ),
    );
  }

  Widget _buildAiTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7C4DFF).withValues(alpha: 0.3),
            const Color(0xFF9C6AFF).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 12,
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.9),
          ),
          const SizedBox(width: 4),
          const Text(
            'AI Suggestion',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB794FF),
            ),
          ),
        ],
      ),
    );
  }

  _IconConfig _getIconConfig() {
    switch (reminder.type) {
      case ReminderType.classReminder:
        return _IconConfig(
          icon: Icons.school_rounded,
          iconColor: const Color(0xFF7C4DFF),
          backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
        );
      case ReminderType.studySession:
        return _IconConfig(
          icon: Icons.auto_stories_rounded,
          iconColor: const Color(0xFFB794FF),
          backgroundColor: const Color(0xFFB794FF).withValues(alpha: 0.15),
        );
      case ReminderType.labSchedule:
        return _IconConfig(
          icon: Icons.science_rounded,
          iconColor: const Color(0xFFFFB74D),
          backgroundColor: const Color(0xFFFFB74D).withValues(alpha: 0.15),
        );
      case ReminderType.assignmentDue:
        return _IconConfig(
          icon: Icons.assignment_rounded,
          iconColor: const Color(0xFFFF7043),
          backgroundColor: const Color(0xFFFF7043).withValues(alpha: 0.15),
        );
    }
  }
}

class _IconConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  _IconConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
