import 'dart:math' as math;

import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Offset> computeArcPositions({
    required int count,
    required double centerX,
    required double centerY,
    required double radius,
    required double startAngle,
    required double endAngle,
  }) {
    return List<Offset>.generate(count, (i) {
      final t = (count == 1) ? 0.5 : i / (count - 1);
      final angle = startAngle + t * (endAngle - startAngle);
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);
      return Offset(x, y);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/flash.png',
                fit: BoxFit.cover,
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                final int n = 5;
                final double centerX = w / 2;
                final double offsetFromBottom = 110.0;
                final double centerY = h - offsetFromBottom;
                final double radius = w * 0.40;
                final double startAngle = math.pi + 0.6;
                final double endAngle = 2 * math.pi - 0.6;

                final positions = computeArcPositions(
                  count: n,
                  centerX: centerX,
                  centerY: centerY,
                  radius: radius,
                  startAngle: startAngle,
                  endAngle: endAngle,
                );

                const double size = 84;

                return Stack(
                  children: List.generate(n, (i) {
                    final pos = positions[i];
                    return Positioned(
                      left: pos.dx - size / 2,
                      top: pos.dy - size / 2,
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (context, child) {
                          double delay = i * 0.15;
                          double t = (controller.value + delay) % 1.0;
                          double lift = -10 * math.sin(t * math.pi);
                          return Transform.translate(
                            offset: Offset(0, lift),
                            child: child,
                          );
                        },
                        child: Container(
                          width: size,
                          height: size,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}