import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unihub/core/theme/app_colors.dart';
import 'package:unihub/features/reminders/models/reminder_model.dart';
import 'package:unihub/features/reminders/widgets/reminder_card.dart';
import 'package:unihub/features/reminders/widgets/add_reminder_sheet.dart';

class SmartRemindersScreen extends StatefulWidget {
  const SmartRemindersScreen({super.key});

  @override
  State<SmartRemindersScreen> createState() => _SmartRemindersScreenState();
}

class _SmartRemindersScreenState extends State<SmartRemindersScreen> {
  ReminderCategory _selectedCategory = ReminderCategory.all;

  final List<Reminder> _reminders = [
    Reminder(
      id: '1',
      title: 'Class Reminder',
      description: 'Data Structures class starts in 10 minutes - Room 301',
      type: ReminderType.classReminder,
      category: ReminderCategory.academic,
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    Reminder(
      id: '2',
      title: 'Study Session Reminder',
      description:
          'Perfect time to review Neural Networks - you have 2 hours free',
      type: ReminderType.studySession,
      category: ReminderCategory.academic,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      isAiSuggestion: true,
    ),
    Reminder(
      id: '3',
      title: 'Lab Schedule',
      description: 'Tomorrow: Machine Learning Lab at 2 PM - Lab 2',
      type: ReminderType.labSchedule,
      category: ReminderCategory.academic,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Reminder(
      id: '4',
      title: 'Assignment Due',
      description: 'Neural Networks assignment due in 2 days',
      type: ReminderType.assignmentDue,
      category: ReminderCategory.exams,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<Reminder> get _filteredReminders {
    if (_selectedCategory == ReminderCategory.all) {
      return _reminders;
    }
    return _reminders.where((r) => r.category == _selectedCategory).toList();
  }

  void _addReminder(Reminder reminder) {
    setState(() {
      _reminders.insert(0, reminder);
    });
  }

  void _deleteReminder(String id) {
    setState(() {
      _reminders.removeWhere((r) => r.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            _buildFilterTabs(colorScheme),
            Expanded(
              child: _filteredReminders.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : _buildRemindersList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderSheet(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Reminder',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: colorScheme.onBackground,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Notifications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Never miss an important update',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: colorScheme.onBackground,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildFilterTabs(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: ReminderCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : colorScheme.onSurface.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _getCategoryLabel(category),
                    style: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withOpacity(0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (100 + ReminderCategory.values.indexOf(category) * 50).ms).slideX(begin: 0.2, end: 0),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: _filteredReminders.length,
      itemBuilder: (context, index) {
        return ReminderCard(
          reminder: _filteredReminders[index],
          onDelete: () => _deleteReminder(_filteredReminders[index].id),
        )
            .animate()
            .fadeIn(duration: 350.ms, delay: (index * 80).ms)
            .slideY(begin: 0.1, end: 0, duration: 350.ms, delay: (index * 80).ms);
      },
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onBackground,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first reminder',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onBackground.withOpacity(0.5),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  String _getCategoryLabel(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.all:
        return 'All';
      case ReminderCategory.academic:
        return 'Academic';
      case ReminderCategory.community:
        return 'Community';
      case ReminderCategory.exams:
        return 'Exams';
    }
  }

  void _showAddReminderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReminderSheet(
        onAdd: _addReminder,
      ),
    );
  }
}
