import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unihub/core/routing/app_router.dart';
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
  final IconData icon;
  final VoidCallback Function(BuildContext context) onTapBuilder;

  const _Feature({
    required this.title,
    required this.description,
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
      icon: Icons.calendar_month_rounded,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.studyPlanner),
    ),
    _Feature(
      title: 'AI Chat Assistant',
      description: 'Get instant help with any academic question.',
      icon: Icons.auto_awesome_rounded,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.chat),
    ),
    _Feature(
      title: 'Smart Reminders',
      description: 'Never miss deadlines with smart notifications.',
      icon: Icons.notifications_active_rounded,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.reminders),
    ),
    _Feature(
      title: 'Notes Scanner',
      description: 'Transcribe handwritten notes with AI.',
      icon: Icons.document_scanner_rounded,
      onTapBuilder: (ctx) => () => ctx.push(AppRoutes.notesScanner),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    backgroundColor: colorScheme.primary.withOpacity(0.2),
                    radius: 28,
                    backgroundImage:
                        _userPhoto != null ? NetworkImage(_userPhoto!) : null,
                    child: _userPhoto == null
                        ? Text(
                            _userName[0].toUpperCase(),
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back,',
                          style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.6),
                              fontSize: 13),
                        ),
                        Text(
                          _userName,
                          style: TextStyle(
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => context.push(AppRoutes.chat),
                      icon: Icon(Icons.auto_awesome_rounded,
                          size: 26, color: colorScheme.primary),
                      tooltip: 'Chat with AI',
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  fillColor: colorScheme.surface,
                  filled: true,
                  prefixIcon: Icon(Icons.search_rounded,
                      color: colorScheme.onSurface.withOpacity(0.4)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: colorScheme.onSurface.withOpacity(0.4),
                              size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  hintText: 'Search features...',
                  hintStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            ),
            const SizedBox(height: 16),

            // Features grid
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              color: colorScheme.onBackground.withOpacity(0.2),
                              size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'No features match your search',
                            style: TextStyle(
                                color:
                                    colorScheme.onBackground.withOpacity(0.5),
                                fontSize: 16),
                          ),
                        ],
                      ).animate().fadeIn(),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final feature = filtered[index];
                        return _FeatureCard(
                          title: feature.title,
                          description: feature.description,
                          icon: feature.icon,
                          onTap: feature.onTapBuilder(context),
                        )
                            .animate()
                            .fadeIn(delay: (100 * index).ms)
                            .slideY(begin: 0.2, end: 0);
                      },
                    ),
            ),

            // Community banner
            if (_searchQuery.isEmpty)
              GestureDetector(
                onTap: () => context.push(AppRoutes.community),
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.tertiary.withOpacity(0.8),
                        colorScheme.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Join Community',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5, end: 0),

            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

// ─── Feature Card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? colorScheme.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.04),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
            border: Border.all(
              color: _isHovered
                  ? colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      Icon(widget.icon, color: colorScheme.primary, size: 28),
                ),
                const Spacer(),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
