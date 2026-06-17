import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unihub/features/community/models/community_post.dart';
import 'package:unihub/features/community/widgets/post_card.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Academics', 'Events', 'Lost & Found'];

  final List<CommunityPost> _allPosts = [
    CommunityPost(
      id: '1',
      authorName: 'Computer Science Club',
      authorAvatar: 'CS',
      avatarColor: const Color(0xFF7C4DFF),
      timeAgo: '2 hours ago',
      category: 'Events',
      title: 'AI & Machine Learning Workshop',
      description:
          'Join us for an exciting hands-on workshop on AI fundamentals. Learn about neural networks, deep learning, and practical applications!',
      scheduledTime: 'Tomorrow, 3:00 PM',
      scheduledLocation: 'Auditorium A',
      imageUrl: 'tech_festival',
      likes: 24,
      comments: 8,
      actionText: 'Register',
      actionColor: const Color(0xFF7C4DFF),
    ),
    CommunityPost(
      id: '2',
      authorName: 'Academic Office',
      authorAvatar: 'AO',
      avatarColor: const Color(0xFF2196F3),
      timeAgo: '5 hours ago',
      category: 'Academics',
      title: 'Mid-term Exam Schedule Released',
      description:
          'The mid-term examination schedule for all departments has been published. Please check your student portal for detailed timings and venues.',
      likes: 45,
      comments: 12,
      actionText: 'View Details',
      actionColor: const Color(0xFF2196F3),
    ),
    CommunityPost(
      id: '3',
      authorName: 'Alex Kumar',
      authorAvatar: 'AK',
      avatarColor: const Color(0xFFFF7043),
      timeAgo: '1 day ago',
      category: 'Lost & Found',
      title: 'Lost: Blue Notebook',
      description:
          'Lost my Data Structures notebook near the library. It has my name on the cover. Please contact me if found!',
      likes: 3,
      comments: 5,
      actionText: 'Help Find',
      actionColor: const Color(0xFFFF7043),
    ),
    CommunityPost(
      id: '4',
      authorName: 'Sports Committee',
      authorAvatar: 'SC',
      avatarColor: const Color(0xFF4CAF50),
      timeAgo: '3 hours ago',
      category: 'Events',
      title: 'Annual Sports Day Registration',
      description:
          'Register now for the annual sports day! Events include cricket, football, basketball, athletics, and more. Limited slots available.',
      scheduledTime: 'Next Monday, 8:00 AM',
      scheduledLocation: 'Main Ground',
      likes: 67,
      comments: 23,
      actionText: 'Register',
      actionColor: const Color(0xFF4CAF50),
    ),
    CommunityPost(
      id: '5',
      authorName: 'Library Admin',
      authorAvatar: 'LA',
      avatarColor: const Color(0xFF9C27B0),
      timeAgo: '6 hours ago',
      category: 'Academics',
      title: 'Extended Library Hours',
      description:
          'During exam season, the library will remain open until 11 PM. Additional study rooms are also available for booking.',
      likes: 89,
      comments: 15,
      actionText: 'View Details',
      actionColor: const Color(0xFF9C27B0),
    ),
    CommunityPost(
      id: '6',
      authorName: 'Priya Sharma',
      authorAvatar: 'PS',
      avatarColor: const Color(0xFFE91E63),
      timeAgo: '2 days ago',
      category: 'Lost & Found',
      title: 'Found: Student ID Card',
      description:
          'Found a student ID card near the cafeteria. Name starts with "R". Contact me to claim it.',
      likes: 12,
      comments: 8,
      actionText: 'Help Find',
      actionColor: const Color(0xFFE91E63),
    ),
  ];

  List<CommunityPost> get _filteredPosts {
    if (_selectedTabIndex == 0) return _allPosts;
    final category = _tabs[_selectedTabIndex];
    return _allPosts.where((post) => post.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colorScheme),
            _buildFilterTabs(colorScheme),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: _filteredPosts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: _filteredPosts[index])
                      .animate()
                      .fadeIn(duration: 350.ms, delay: (index * 80).ms)
                      .slideY(begin: 0.1, end: 0, duration: 350.ms, delay: (index * 80).ms);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Create post coming soon!', style: TextStyle(color: colorScheme.onPrimary)),
              backgroundColor: colorScheme.primary,
            ),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Create Post',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ).animate().scale(delay: 400.ms),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: colorScheme.onBackground,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onBackground,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connect with your campus',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.search_rounded,
              color: colorScheme.onBackground,
              size: 20,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildFilterTabs(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            _tabs.length,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: _selectedTabIndex == index
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedTabIndex == index
                          ? Colors.transparent
                          : colorScheme.onSurface.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: _selectedTabIndex == index
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: _selectedTabIndex == index
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: _selectedTabIndex == index
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (100 + index * 50).ms).slideX(begin: 0.2, end: 0),
            ),
          ),
        ),
      ),
    );
  }
}
