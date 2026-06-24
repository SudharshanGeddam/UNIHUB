import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unihub/core/routing/app_router.dart';

class FocusModeSection extends StatelessWidget {
  final String subject;
  final String focusType;

  const FocusModeSection({
    super.key,
    required this.subject,
    required this.focusType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1E3F).withValues(alpha: 0.9),
            const Color(0xFF2D1B4E).withValues(alpha: 0.9)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
              blurRadius: 25,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                const Color(0xFF9C7CFF).withValues(alpha: 0.2)
              ]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5)
              ],
            ),
            child: const Icon(Icons.center_focus_strong,
                color: Colors.white, size: 44),
          ),
          const SizedBox(height: 20),
          const Text('Focus Mode',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Block distractions and study with AI guidance',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  AppRoutes.focusSession,
                  extra: {'subject': subject, 'focusType': focusType},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: const Color(0xFF7C4DFF).withValues(alpha: 0.5),
              ),
              child: const Text('Start Focus Session',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}
