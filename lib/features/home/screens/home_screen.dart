import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unihub/core/routing/app_router.dart';
import 'package:unihub/core/theme/app_colors.dart';
import 'package:unihub/widgets/bottom_nav.dart';
import 'package:unihub/features/auth/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ─── Feature card data model ─────────────────────────────────────────────────

class _Feature {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final VoidCallback Function(BuildContext context) onTapBuilder;

  const _Feature({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.onTapBuilder,
  });

  bool matchesQuery(String query) {
    final lower = query.toLowerCase();
    return title.toLowerCase().contains(lower) ||
        description.toLowerCase().contains(lower);
  }
}

// ─── Screen state ─────────────────────────────────────────────────────────────

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  late final List<_Feature> _allFeatures = [
    _Feature(
      title: 'AI Study Planner',
      description: 'Create personalized study schedules with AI.',
      imagePath: 'assets/images/grid_1.png',
      icon: Icons.calendar_month,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.studyPlanner),
    ),
    _Feature(
      title: 'AI Chat Assistant',
      description: 'Get instant help with any academic question.',
      imagePath: 'assets/images/grid_2.png',
      icon: Icons.smart_toy,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.chat),
    ),
    _Feature(
      title: 'Smart Reminders',
      description: 'Never miss deadlines with smart notifications.',
      imagePath: 'assets/images/grid_3.png',
      icon: Icons.notifications_active,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.reminders),
    ),
    _Feature(
      title: 'Exam Analyzer',
      description: 'Predict important topics for your exams.',
      imagePath: 'assets/images/grid_4.png',
      icon: Icons.analytics,
      onTapBuilder: (ctx) => () {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Coming soon! 🚀')),
        );
      },
    ),
    _Feature(
      title: 'Notes Scanner',
      description: 'Transcribe handwritten notes with AI.',
      imagePath: 'assets/images/grid_1.png',
      icon: Icons.camera_alt_rounded,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.notesScanner),
    ),
    _Feature(
      title: 'Community',
      description: 'Connect with fellow students.',
      imagePath: 'assets/images/grid_2.png',
      icon: Icons.people_rounded,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.community),
    ),
  ];

  List<_Feature> get _filteredFeatures {
    if (_searchQuery.isEmpty) return _allFeatures;
    return _allFeatures.where((f) => f.matchesQuery(_searchQuery)).toList();
  }

  String get _userName {
    final user = _authService.currentUser;
    return user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
  }

  String? get _userPhoto => _authService.currentUser?.photoURL;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFeatures;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background.withOpacity(0.74),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: AppColors.primary,
                    radius: 28,
                    backgroundImage:
                        _userPhoto != null ? NetworkImage(_userPhoto!) : null,
                    child: _userPhoto == null
                        ? Text(
                            _userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          _userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(100, 255, 255, 255),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => context.push(AppRoutes.chat),
                      icon: const Icon(Icons.smart_toy_outlined,
                          size: 28, color: Colors.white),
                      tooltip: 'Chat with AI',
                    ),
                  ),
                ],
              ),
            ),

            // ── Working search bar ─────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  fillColor: AppColors.inputFillTranslucent,
                  filled: true,
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textHint),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textHint, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  hintText: 'Search features...',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                ),
              ),
            ),

            // Features grid
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              color: AppColors.textHint, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'No features match your search',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      childAspectRatio: 0.85,
                      children: filtered
                          .map((feature) => _FeatureCard(
                                title: feature.title,
                                description: feature.description,
                                imagePath: feature.imagePath,
                                icon: feature.icon,
                                onTap: feature.onTapBuilder(context),
                              ))
                          .toList(),
                    ),
            ),

            // Community banner
            if (_searchQuery.isEmpty)
              GestureDetector(
                onTap: () => context.push(AppRoutes.community),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.69),
                    borderRadius: BorderRadius.circular(35.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface.withOpacity(0.8),
              AppColors.surfaceTinted.withOpacity(0.8),
            ],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white70, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
