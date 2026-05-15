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
              child: Image.asset('assets/images/flash.png', fit: BoxFit.cover),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                final int n = 7;
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
                          // ---- parameters (copy the same ones you used in LayoutBuilder) ----
                          final int count = n; // number of avatars
                          final double startA =
                              startAngle; // e.g. math.pi + 0.6
                          final double endA = endAngle; // e.g. 2*math.pi - 0.6
                          final double span = endA - startA;
                          final double cx = centerX;
                          final double cy = centerY;
                          final double r = radius;
                          final double baseSizeLocal =
                              size; // avatar base diameter

                          // ---- progress drives motion: 0..1 ----
                          final double progress =
                              controller.value; // 0..1 repeatedly
                          // move speed: how many loops across all avatars per controller cycle
                          // keep 1.0 so one full controller cycle moves each avatar across arc once
                          final double speed = 0.35;

                          // For avatar i:
                          // t = i/count  (initial normalized position along arc)
                          // add progress*speed so the value slides; then wrap to 0..1
                          double t = (i / count + progress * speed) % 1.0;

                          // Map t to angle along arc (right side corresponds to t close to 0 or 1
                          // depending on start/end mapping). We assume t==0 at right-most and t==0.5 center.
                          final double angle = startA + t * span;
                          final double x = cx + r * math.cos(angle);
                          final double y = cy + r * math.sin(angle);

                          // Determine scale by proximity to centerX: closer -> bigger
                          final double dx = (x - cx).abs();
                          // maxDistance for normalization: use radius (or span half-width), but make sure not 0
                          final double maxDx = r;
                          final double closeness = (1.0 - (dx / maxDx)).clamp(
                            0.0,
                            1.0,
                          );

                          // scale range: when center -> 1.18, far -> 0.85 (tune these)
                          final double minScale = 0.85;
                          final double maxScale = 1.18;
                          final double scale =
                              minScale + (maxScale - minScale) * closeness;

                          // optional opacity change (center more opaque)
                          final double minOp = 0.65;
                          final double maxOp = 1.0;
                          final double opacity =
                              minOp + (maxOp - minOp) * closeness;

                          // vertical lift tiny based on closeness to emphasize center slightly
                          final double lift = -12.0 *
                              math.pow(
                                closeness,
                                0.9,
                              ); // closeness^0.9 for smoother falloff

                          // Place and transform: use Positioned based on computed x,y but animate with transforms
                          final double half = baseSizeLocal / 2;
                          return Positioned(
                            left: x - half,
                            top: y - half,
                            child: Transform.translate(
                              offset: Offset(0, lift),
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(opacity: opacity, child: child),
                              ),
                            ),
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
