import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unihub/core/routing/app_router.dart';
import 'package:unihub/core/theme/theme_provider.dart';
import 'package:unihub/features/auth/services/auth_service.dart';
import 'package:unihub/features/profile/repositories/user_profile_repository.dart';
import 'package:unihub/features/profile/widgets/account_settings_sheet.dart';
import 'package:unihub/features/profile/widgets/notifications_settings_sheet.dart';
import 'package:unihub/features/profile/widgets/privacy_settings_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _userProfileRepo = UserProfileRepository();
  bool _isLoading = false;
  UserProfileStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _userProfileRepo.getUserStats();
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  String get _userName {
    final user = _authService.currentUser;
    return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
  }

  String get _userEmail {
    return _authService.currentUser?.email ?? 'No email';
  }

  String? get _userPhoto {
    return _authService.currentUser?.photoURL;
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Logout',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _authService.signOut();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  void _showAccountSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccountSettingsSheet(
        userName: _userName,
        userEmail: _userEmail,
        onSave: (newName) async {
          await _userProfileRepo.updateDisplayName(newName);
          setState(() {}); // refresh name
        },
      ),
    );
  }

  void _showNotificationsSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsSettingsSheet(),
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PrivacySettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: colorScheme.onSurface),
        title: Text(
          'Profile',
          style: TextStyle(
              color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onSurface),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Edit profile coming soon!',
                      style: TextStyle(color: colorScheme.onSurface)),
                  backgroundColor: colorScheme.surface,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.9),
                    colorScheme.tertiary.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                        _userPhoto != null ? NetworkImage(_userPhoto!) : null,
                    child: _userPhoto == null
                        ? Text(
                            _userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Email
                  Text(
                    _userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                          label: 'Study Plans',
                          value: _stats?.totalStudyPlans.toString() ?? '-'),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _StatItem(
                          label: 'Reminders',
                          value: _stats?.totalReminders.toString() ?? '-'),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _StatItem(
                          label: 'Completed',
                          value: _stats?.completedReminders.toString() ?? '-'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings list
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      activeThumbColor: colorScheme.primary,
                    ),
                  ),
                  Divider(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      height: 1),
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Account Settings',
                    onTap: _showAccountSettings,
                  ),
                  Divider(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      height: 1),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: _showNotificationsSettings,
                  ),
                  Divider(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      height: 1),
                  _SettingsTile(
                    icon: Icons.security_outlined,
                    title: 'Privacy & Security',
                    onTap: _showPrivacySettings,
                  ),
                  Divider(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      height: 1),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'About UniHub',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'UniHub',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 UniHub Team',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleLogout,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(_isLoading ? 'Logging out...' : 'Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                  foregroundColor: colorScheme.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ]
              .animate(interval: 50.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
        ),
      ),
    );
  }
}

// Stats item widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Settings tile widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios,
              color: colorScheme.onSurface.withValues(alpha: 0.3), size: 16),
      onTap: onTap,
    );
  }
}
