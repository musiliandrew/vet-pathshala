import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../../coins/screens/coin_store_screen.dart';
import '../providers/home_provider.dart';
import '../../question_bank/screens/question_bank_screen.dart';
import '../../ebooks/screens/ebooks_screen.dart';
import '../../notes/screens/short_notes_screen.dart';
import '../../gamification/screens/gamification_screen.dart';
import '../../drug_center/screens/drug_index_screen.dart';
import '../../drug_center/screens/enhanced_drug_center_screen.dart';
import '../../lecture/screens/lecture_bank_screen.dart';

class InspiredHomeScreen extends StatefulWidget {
  const InspiredHomeScreen({super.key});

  @override
  State<InspiredHomeScreen> createState() => _InspiredHomeScreenState();
}

class _InspiredHomeScreenState extends State<InspiredHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final authProvider = context.read<AuthProvider>();
    final homeProvider = context.read<HomeProvider>();
    final user = authProvider.currentUser;
    
    if (user != null) {
      homeProvider.loadUserStatistics(user.id);
      homeProvider.loadRecentActivities(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HomeProvider>(
      builder: (context, authProvider, homeProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FFFE),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => homeProvider.refresh(user.id),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with greeting and actions (inspired by homepage.html)
                    _buildHeader(context, user),
                    
                    // Search Bar (inspired by homepage.html)
                    _buildSearchBar(),
                    
                    // Banner/Ad Section (inspired by homepage.html)
                    _buildBannerSection(),
                    
                    // Track Performance (inspired by homepage.html)
                    _buildPerformanceSection(context, user, homeProvider),
                    
                    // Categories (inspired by homepage.html)
                    _buildCategoriesSection(),
                    
                    // Popular Ebooks (inspired by ebook-library.html)
                    _buildPopularEbooksSection(),
                    
                    // Refer & Earn (inspired by homepage.html)
                    _buildReferEarnSection(),
                    
                    // Recent Activity (inspired by homepage.html)
                    _buildRecentActivitySection(context, homeProvider),
                    
                    // Success Stories (inspired by success_story.html)
                    _buildSuccessStoriesSection(),
                    
                    const SizedBox(height: 100), // Bottom padding for navigation
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Text(
                'Good Morning',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
              const SizedBox(width: 8),
              const Text('☀️', style: TextStyle(fontSize: 20)),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _buildHeaderButton(Icons.notifications_outlined, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You have 2 new notifications!')),
                );
              }),
              const SizedBox(width: 12),
              _buildHeaderButton(Icons.flash_on_outlined, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quick actions menu')),
                );
              }),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF16A34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'V',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FFFE),
          border: Border.all(color: const Color(0xFFE8F5E8), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Search veterinary resources...',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening featured veterinary course!')),
          );
        },
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13), // Slightly smaller to account for border
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/master_veterinary.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to gradient if image fails
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, Color(0xFF16A34A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Dark overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '🎓 Master Veterinary Medicine',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Join thousands of successful veterinarians',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context, UserModel user, HomeProvider homeProvider) {
    final stats = homeProvider.userStats;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20), // Reduced horizontal padding
      child: Container(
        padding: const EdgeInsets.all(16), // Reduced internal padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFE8F5E8)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Track Your Performance',
                    style: TextStyle(
                      fontSize: 18, // Slightly smaller
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15803D),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'View Details →',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13, // Smaller font
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnimatedCoursesStat(),
                ),
                Expanded(
                  child: _buildAnimatedHoursStat(),
                ),
                Expanded(
                  child: _buildAnimatedScoreStat(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCoursesStat() {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: 18),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/courses.png',
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school,
                      color: AppColors.primary,
                      size: 24,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Courses',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedHoursStat() {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: 92),
      duration: const Duration(seconds: 3),
      builder: (context, value, child) {
        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Clock hand animation
                  Transform.rotate(
                    angle: (value / 92) * 6.28, // Full rotation based on progress
                    child: Container(
                      width: 2,
                      height: 15,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  // Center dot
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Hours',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedScoreStat() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 0.95),
      duration: const Duration(seconds: 2, milliseconds: 500),
      builder: (context, value, child) {
        return Column(
          children: [
            Container(
              width: 50,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  // Score text
                  Text(
                    '${(value * 100).round()}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Score',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'name': 'Question Bank', 'icon': '📚', 'iconImage': 'assets/images/q_bank.png', 'color': AppColors.primary},
      {'name': 'Short Notes', 'icon': '📝', 'iconImage': 'assets/images/short_notes.png', 'color': Color(0xFF10B981)},
      {'name': 'Quiz & PYP', 'icon': '🧠', 'iconImage': 'assets/images/quiz.png', 'color': Color(0xFF34D399)},
      {'name': 'Lectures', 'icon': '🎥', 'iconImage': 'assets/images/lecture.png', 'color': Color(0xFF6EE7B7)},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
              Text(
                'Show All →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130, // Increased height to accommodate text
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 90, // Fixed width to prevent overflow
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _navigateToCategory(context, category['name'] as String),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(
                            color: category['color'] as Color,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (category['color'] as Color).withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: category['iconImage'] != null 
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  category['iconImage'] as String,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      category['icon'] as String,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: category['color'] as Color,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                category['icon'] as String,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: category['color'] as Color,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Text(
                          category['name'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularEbooksSection() {
    final ebooks = [
      {
        'title': 'Veterinary Anatomy',
        'author': 'Dr. Smith',
        'genre': 'Anatomy',
        'rating': '4.8',
        'reviews': '234',
        'color': AppColors.primary,
        'coverImage': 'assets/images/veterinary_anatomy.jpeg',
      },
      {
        'title': 'Small Animal Surgery',
        'author': 'Dr. Johnson',
        'genre': 'Surgery',
        'rating': '4.9',
        'reviews': '189',
        'color': Color(0xFF10B981),
        'coverImage': 'assets/images/small_animal.jpeg',
      },
      {
        'title': 'Vet Pharmacology',
        'author': 'Dr. Williams',
        'genre': 'Pharmacology',
        'rating': '4.7',
        'reviews': '156',
        'color': Color(0xFF34D399),
        'coverImage': 'assets/images/vet_pharma.jpeg',
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Ebooks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
              Text(
                'Show All →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320, // Increased height to prevent overflow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: ebooks.length,
            itemBuilder: (context, index) {
              final ebook = ebooks[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${ebook['title']} ebook')),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 140,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Slightly smaller to account for border
                          child: ebook['coverImage'] != null
                              ? Image.asset(
                                  ebook['coverImage'] as String,
                                  width: 140,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildFallbackCover(ebook);
                                  },
                                )
                              : _buildFallbackCover(ebook),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ebook['title'] as String,
                              style: const TextStyle(
                                fontSize: 13, // Slightly smaller
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF374151),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ebook['author'] as String,
                              style: const TextStyle(
                                fontSize: 11, // Smaller text
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ebook['genre'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  ebook['rating'] as String,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(width: 2),
                                const Text('★★★★★', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 10)),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    '(${ebook['reviews']})',
                                    style: const TextStyle(fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReferEarnSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: _AnimatedReferEarnCard(),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, HomeProvider homeProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
              Text(
                'View All →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFE8F5E8)),
          ),
          child: Column(
            children: [
              _buildActivityItem('📖', 'Completed "Canine Anatomy" quiz', '2 hours ago'),
              const Divider(color: Color(0xFFE8F5E8)),
              _buildActivityItem('⭐', 'Achieved 95% in Surgery module', '1 day ago'),
              const Divider(color: Color(0xFFE8F5E8)),
              _buildActivityItem('🎯', 'Completed weekly learning goal', '3 days ago'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStoriesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFE8F5E8)),
        ),
        child: Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [AppColors.primary, Color(0xFF16A34A)],
              ).createShader(bounds),
              child: const Text(
                '5,247',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Successful Veterinarians',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Veterinarians who advanced their careers through our platform',
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 136, // Exact width: 4 avatars * 24 spacing + 40 width = 136
                height: 40,
                child: Stack(
                  children: List.generate(5, (index) {
                    return Positioned(
                      left: index * 24.0, // 24 pixels spacing between centers
                      child: Container(
                        width: 32, // Smaller avatars to prevent overflow
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, Color(0xFF16A34A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            index == 4 ? '+' : ['DR', 'VT', 'AS', 'MJ'][index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8, // Smaller font for smaller avatar
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    Widget screen;
    switch (categoryName) {
      case 'Question Bank':
        screen = const QuestionBankScreen();
        break;
      case 'Short Notes':
        screen = const ShortNotesScreen();
        break;
      case 'Quiz & PYP':
        screen = const QuestionBankScreen(); // Could be a specific quiz screen
        break;
      case 'Lectures':
        screen = const LectureBankScreen();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$categoryName - Coming Soon!')),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class _FloatingPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw floating circles
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 8, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 12, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

extension StringExtension on String {
  bool get isBase64 => startsWith('data:image');
}

class _AnimatedReferEarnCard extends StatefulWidget {
  @override
  _AnimatedReferEarnCardState createState() => _AnimatedReferEarnCardState();
}

class _AnimatedReferEarnCardState extends State<_AnimatedReferEarnCard>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _coinController;
  late AnimationController _pulseController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _coinRotation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _coinController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Interval(0.0, 0.8, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.elasticOut,
    ));

    _coinRotation = Tween<double>(
      begin: 0.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _coinController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticInOut,
    ));

    // Start animations
    _mainController.forward();
    _coinController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _coinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _coinController, _pulseController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      Color(0xFF16A34A),
                      Color(0xFF15803D),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background coins pattern
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Transform.rotate(
                        angle: _coinRotation.value * 3.14159,
                        child: Text(
                          '🪙',
                          style: TextStyle(
                            fontSize: 40,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      left: 20,
                      child: Transform.rotate(
                        angle: -_coinRotation.value * 3.14159,
                        child: Text(
                          '💰',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    
                    // Main content
                    Column(
                      children: [
                        // Header with animated coin
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: _coinRotation.value * 3.14159,
                              child: const Text(
                                '🪙',
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Refer & Earn',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Transform.rotate(
                              angle: -_coinRotation.value * 3.14159,
                              child: const Text(
                                '💰',
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Animated reward amount
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: const Text(
                            '🎁 Earn ₹50 per referral!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        const Text(\n                          'Share with fellow veterinarians\\nand build your earning network!',\n                          style: TextStyle(\n                            color: Colors.white,\n                            fontSize: 16,\n                            height: 1.4,\n                          ),\n                          textAlign: TextAlign.center,\n                        ),\n                        \n                        const SizedBox(height: 20),\n                        \n                        // Animated button\n                        Transform.scale(\n                          scale: _pulseAnimation.value,\n                          child: Container(\n                            width: double.infinity,\n                            decoration: BoxDecoration(\n                              borderRadius: BorderRadius.circular(15),\n                              gradient: LinearGradient(\n                                colors: [Colors.white, Colors.grey.shade100],\n                                begin: Alignment.topCenter,\n                                end: Alignment.bottomCenter,\n                              ),\n                              boxShadow: [\n                                BoxShadow(\n                                  color: Colors.black.withOpacity(0.2),\n                                  blurRadius: 10,\n                                  offset: const Offset(0, 5),\n                                ),\n                              ],\n                            ),\n                            child: ElevatedButton(\n                              onPressed: () {\n                                // Add haptic feedback\n                                ScaffoldMessenger.of(context).showSnackBar(\n                                  SnackBar(\n                                    content: Row(\n                                      children: [\n                                        const Text('🚀 '),\n                                        const Text('Share your referral code: '),\n                                        Container(\n                                          padding: const EdgeInsets.symmetric(\n                                            horizontal: 8,\n                                            vertical: 2,\n                                          ),\n                                          decoration: BoxDecoration(\n                                            color: AppColors.primary,\n                                            borderRadius: BorderRadius.circular(4),\n                                          ),\n                                          child: const Text(\n                                            'VET2024',\n                                            style: TextStyle(\n                                              color: Colors.white,\n                                              fontWeight: FontWeight.bold,\n                                            ),\n                                          ),\n                                        ),\n                                      ],\n                                    ),\n                                    backgroundColor: Colors.white,\n                                    behavior: SnackBarBehavior.floating,\n                                    shape: RoundedRectangleBorder(\n                                      borderRadius: BorderRadius.circular(10),\n                                    ),\n                                  ),\n                                );\n                              },\n                              style: ElevatedButton.styleFrom(\n                                backgroundColor: Colors.transparent,\n                                shadowColor: Colors.transparent,\n                                padding: const EdgeInsets.symmetric(vertical: 16),\n                                shape: RoundedRectangleBorder(\n                                  borderRadius: BorderRadius.circular(15),\n                                ),\n                              ),\n                              child: Row(\n                                mainAxisAlignment: MainAxisAlignment.center,\n                                children: [\n                                  Icon(\n                                    Icons.share,\n                                    color: AppColors.primary,\n                                    size: 24,\n                                  ),\n                                  const SizedBox(width: 8),\n                                  Text(\n                                    'Invite Friends Now',\n                                    style: TextStyle(\n                                      color: AppColors.primary,\n                                      fontSize: 18,\n                                      fontWeight: FontWeight.bold,\n                                    ),\n                                  ),\n                                  const SizedBox(width: 8),\n                                  const Text(\n                                    '🚀',\n                                    style: TextStyle(fontSize: 20),\n                                  ),\n                                ],\n                              ),\n                            ),\n                          ),\n                        ),\n                      ],\n                    ),\n                  ],\n                ),\n              ),\n            ),\n          ),\n        );\n      },\n    );\n  }\n}

Widget _buildEbookCover(Map<String, dynamic> ebook) {
  final coverUrl = ebook['coverUrl'] as String;
  
  if (coverUrl.isBase64) {
    // Handle base64 images
    try {
      final base64Data = coverUrl.split(',')[1];
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        width: 140,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackCover(ebook);
        },
      );
    } catch (e) {
      return _buildFallbackCover(ebook);
    }
  } else {
    // Handle network URLs
    return Image.network(
      coverUrl,
      width: 140,
      height: 180,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 140,
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ebook['color'] as Color,
                (ebook['color'] as Color).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackCover(ebook);
      },
    );
  }
}

Widget _buildFallbackCover(Map<String, dynamic> ebook) {
  return Container(
    width: 140,
    height: 180,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ebook['color'] as Color,
          (ebook['color'] as Color).withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          ebook['title'] as String,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}