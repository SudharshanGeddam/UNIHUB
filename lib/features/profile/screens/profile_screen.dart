import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unihub/core/routing/app_router.dart';
import 'package:unihub/features/auth/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

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
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(10, 2, 46, 1),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/agent_home.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // Content
          SingleChildScrollView(
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
                        const Color.fromARGB(200, 43, 52, 227),
                        const Color.fromARGB(200, 10, 2, 46),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white24,
                        backgroundImage: _userPhoto != null
                            ? NetworkImage(_userPhoto!)
                            : null,
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
                      const SizedBox(height: 16),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(label: 'Study Plans', value: '3'),
                          _StatItem(label: 'Chat Sessions', value: '12'),
                          _StatItem(label: 'Days Active', value: '7'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Settings list
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(200, 88, 87, 106),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Account Settings',
                        onTap: () {},
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {},
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _SettingsTile(
                        icon: Icons.security_outlined,
                        title: 'Privacy & Security',
                        onTap: () {},
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _SettingsTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        onTap: () {},
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'About UniHub',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'UniHub',
                            applicationVersion: '1.0.0',
                            applicationLegalese: '© 2024 UniHub Team',
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                'Your AI-Powered Smart Campus Companion',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 50,
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
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
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
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
          const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }
}
