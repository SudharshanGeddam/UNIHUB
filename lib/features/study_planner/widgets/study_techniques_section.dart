import 'package:flutter/material.dart';

class StudyTechniquesSection extends StatelessWidget {
  final List<String> techniques;
  final String breakRecommendation;

  const StudyTechniquesSection({
    super.key,
    required this.techniques,
    required this.breakRecommendation,
  });

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.psychology,
                    color: Color(0xFFFF9800), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Recommended Techniques',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...techniques.asMap().entries.map((entry) {
            final index = entry.key;
            final technique = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                        shape: BoxShape.circle),
                    child: Center(
                        child: Text('${index + 1}',
                            style: const TextStyle(
                                color: Color(0xFFFFB74D),
                                fontWeight: FontWeight.bold,
                                fontSize: 13))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(technique,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14))),
                ],
              ),
            );
          }),
          Divider(height: 24, color: Colors.white.withValues(alpha: 0.1)),
          Row(
            children: [
              const Icon(Icons.coffee, color: Color(0xFFBCAAA4), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  breakRecommendation,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
