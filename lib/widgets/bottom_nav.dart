import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unihub/core/routing/app_router.dart';

/// Floating bottom navigation bar used on main app screens.
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(220, 30, 30, 40),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              onTap: () => context.go(AppRoutes.home),
            ),
            _NavItem(
              icon: Icons.smart_toy_rounded,
              label: 'AI Chat',
              onTap: () => context.push(AppRoutes.chat),
            ),
            _NavItem(
              icon: Icons.camera_alt_rounded,
              label: 'Notes Scanner',
              onTap: () => context.push(AppRoutes.notesScanner),
            ),
            _NavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () => context.push('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
