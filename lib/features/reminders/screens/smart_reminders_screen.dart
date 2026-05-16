import 'package:flutter/material.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
            AppColors.background,
            AppColors.surfaceTinted,
            const Color(0xFF2D1B4E),
          ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Floating decorative circles
            ..._buildFloatingOrbs(),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildFilterTabs(),
                  Expanded(
                    child: _filteredReminders.isEmpty
                        ? _buildEmptyState()
                        : _buildRemindersList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFF9C6AFF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C4DFF).withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddReminderSheet(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Add Reminder',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingOrbs() {
    return [
      // Top right purple orb
      Positioned(
        top: -50,
        right: -30,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF7C4DFF).withOpacity(0.4),
                const Color(0xFF7C4DFF).withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      // Bottom left orange orb
      Positioned(
        bottom: 150,
        left: -60,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFF9800).withOpacity(0.25),
                const Color(0xFFFF9800).withOpacity(0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      // Middle right small orb
      Positioned(
        top: 300,
        right: -40,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF9C27B0).withOpacity(0.3),
                const Color(0xFF9C27B0).withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Notifications',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Never miss an important update',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
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
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF9C6AFF)],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : const Color(0xFF1E1E3F).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7C4DFF).withOpacity(0.4),
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
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
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
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 350 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: ReminderCard(
            reminder: _filteredReminders[index],
            onDelete: () => _deleteReminder(_filteredReminders[index].id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7C4DFF).withOpacity(0.2),
                  const Color(0xFF7C4DFF).withOpacity(0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: Color(0xFF7C4DFF),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first reminder',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
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

