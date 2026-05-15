import 'package:flutter/material.dart';

class StudyStreakSection extends StatelessWidget {
  final int streakDays;

  const StudyStreakSection({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3F).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Study Streak',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFFFF9800).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text('$streakDays days',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStreakCalendar(),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days
              .map((day) => SizedBox(
                    width: 36,
                    child: Text(day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        ...List.generate(4, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final isCurrentWeek = weekIndex == 3;
                final isPastDay =
                    isCurrentWeek ? dayIndex < currentWeekday : weekIndex < 3;
                final isToday = isCurrentWeek && dayIndex == currentWeekday - 1;
                double fillLevel = 0.0;
                if (isPastDay || isToday) {
                  final totalDays = (weekIndex * 7) + dayIndex + 1;
                  if (totalDays <= streakDays + 21) {
                    fillLevel = [0.3, 0.5, 0.7, 1.0, 0.8, 0.6, 0.9][dayIndex];
                  }
                }
                return _buildStreakCell(fillLevel: fillLevel, isToday: isToday);
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStreakCell({required double fillLevel, bool isToday = false}) {
    Color cellColor;
    if (fillLevel == 0) {
      cellColor = Colors.white.withOpacity(0.08);
    } else if (fillLevel < 0.4) {
      cellColor = const Color(0xFF7C4DFF).withOpacity(0.3);
    } else if (fillLevel < 0.7) {
      cellColor = const Color(0xFF7C4DFF).withOpacity(0.6);
    } else {
      cellColor = const Color(0xFF7C4DFF);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: cellColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: Colors.white, width: 2) : null,
        boxShadow: fillLevel > 0.7
            ? [
                BoxShadow(
                    color: const Color(0xFF7C4DFF).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
    );
  }
}
