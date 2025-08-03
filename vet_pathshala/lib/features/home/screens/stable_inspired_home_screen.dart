import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../providers/home_provider.dart';
import '../../question_bank/screens/question_bank_screen.dart';
import '../../ebooks/screens/ebooks_screen.dart';
import '../../notes/screens/short_notes_screen.dart';
import '../../gamification/screens/gamification_screen.dart';
import '../../drug_center/screens/drug_index_screen.dart';
import '../../drug_center/screens/enhanced_drug_center_screen.dart';
import '../../lecture/screens/lecture_bank_screen.dart';

class StableInspiredHomeScreen extends StatefulWidget {
  const StableInspiredHomeScreen({super.key});

  @override
  State<StableInspiredHomeScreen> createState() => _StableInspiredHomeScreenState();
}

class _StableInspiredHomeScreenState extends State<StableInspiredHomeScreen> {
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
          backgroundColor: const Color(0xFF1C2526),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => homeProvider.refresh(user.id),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, user),
                    
                    // Search Bar
                    _buildSearchBar(),
                    
                    // Banner Section
                    _buildBannerSection(),
                    
                    // Performance Section
                    _buildPerformanceSection(context, user, homeProvider),
                    
                    // Categories
                    _buildCategoriesSection(),
                    
                    // Popular Ebooks
                    _buildPopularEbooksSection(),
                    
                    // Refer & Earn
                    _buildReferEarnSection(),
                    
                    // Recent Activity
                    _buildRecentActivitySection(context, homeProvider),
                    
                    // Success Stories
                    _buildSuccessStoriesSection(),
                    
                    const SizedBox(height: 100), // Bottom padding
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2526),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B5E4A).withOpacity(0.2),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: Color(0x334B5E4A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF4B5E4A), Color(0xFF6B7A69)],
            ).createShader(bounds),
            child: const Text(
              'Good Morning 🩺',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD4D4D4),
              ),
            ),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4D4D4), Color(0xFFB0B0B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: const Color(0xFF4B5E4A),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4B5E4A).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'V',
                    style: const TextStyle(
                      color: Color(0xFF1C2526),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B5E4A), Color(0xFF6B7A69)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4B5E4A).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFFD4D4D4),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFD4D4D4).withOpacity(0.05),
          border: Border.all(
            color: const Color(0xFF4B5E4A).withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.search,
              color: Color(0xFF4B5E4A),
              size: 18,
            ),
            SizedBox(width: 16),
            Text(
              'Search veterinary resources...',
              style: TextStyle(
                color: Color(0x99D4D4D4),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C2526), Color(0xFF4B5E4A), Color(0xFF1C2526)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF4B5E4A),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4B5E4A).withOpacity(0.3),
            blurRadius: 48,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening featured veterinary course!')),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
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
                          colors: [const Color(0xFF4B5E4A), const Color(0xFF6B7A69)],
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFD4D4D4).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF4B5E4A),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '🎓 Master Veterinary Medicine',
                          style: TextStyle(
                            color: const Color(0xFF4B5E4A),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B5E4A).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Join thousands of successful veterinarians',
                          style: TextStyle(
                            color: Color(0xFFD4D4D4),
                            fontSize: 14,
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
    );
  }

  Widget _buildPerformanceSection(BuildContext context, UserModel user, HomeProvider homeProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD4D4D4).withOpacity(0.05),
            Color(0xFFD4D4D4).withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4B5E4A).withOpacity(0.2),
          width: 1,
        ),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B5E4A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Flexible(
                child: Text(
                  'View Details →',
                  style: TextStyle(
                    color: Color(0xFF4B5E4A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAnimatedCoursesStat()),
              Expanded(child: _buildAnimatedHoursStat()),
              Expanded(child: _buildAnimatedScoreStat()),
            ],
          ),
        ],
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
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF4B5E4A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(22.5),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/courses.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school,
                      color: const Color(0xFF4B5E4A),
                      size: 22,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4B5E4A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Courses',
              style: TextStyle(
                fontSize: 11,
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
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4B5E4A), width: 3),
                borderRadius: BorderRadius.circular(22.5),
                color: Color(0xFFD4D4D4),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Clock hand animation
                  Transform.rotate(
                    angle: (value / 92) * 6.28, // Full rotation based on progress
                    child: Container(
                      width: 2,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B5E4A),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  // Center dot
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B5E4A),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4B5E4A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Hours',
              style: TextStyle(
                fontSize: 11,
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
              width: 45,
              height: 45,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF4B5E4A).withOpacity(0.2),
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(22.5),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: 45,
                    height: 45,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 3,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4B5E4A)),
                    ),
                  ),
                  // Score text
                  Text(
                    '${(value * 100).round()}%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4B5E4A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4B5E4A),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Score',
              style: TextStyle(
                fontSize: 11,
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
      {'name': 'Question Bank', 'icon': '📚', 'iconImage': 'assets/images/q_bank.png', 'color': const Color(0xFF4B5E4A)},
      {'name': 'Short Notes', 'icon': '📝', 'iconImage': 'assets/images/short_notes.png', 'color': const Color(0xFF10B981)},
      {'name': 'Quiz & PYP', 'icon': '🧠', 'iconImage': 'assets/images/quiz.png', 'color': const Color(0xFF34D399)},
      {'name': 'Lectures', 'icon': '🎥', 'iconImage': 'assets/images/lecture.png', 'color': const Color(0xFF6EE7B7)},
      {'name': 'Drug Center', 'icon': '💊', 'color': const Color(0xFF3B82F6)},
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
                  color: Color(0xFFD4D4D4),
                ),
              ),
              Text(
                'Show All →',
                style: TextStyle(
                  color: const Color(0xFF4B5E4A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => _navigateToCategory(context, category['name'] as String),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFFD4D4D4),
                          borderRadius: BorderRadius.circular(30),
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
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  category['iconImage'] as String,
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      category['icon'] as String,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: category['color'] as Color,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                category['icon'] as String,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: category['color'] as Color,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
        'color': const Color(0xFF4B5E4A),
        'coverImage': 'assets/images/veterinary_anatomy.jpeg',
      },
      {
        'title': 'Small Animal Surgery',
        'author': 'Dr. Johnson',
        'genre': 'Surgery',
        'rating': '4.9',
        'reviews': '189',
        'color': const Color(0xFF10B981),
        'coverImage': 'assets/images/small_animal.jpeg',
      },
      {
        'title': 'Vet Pharmacology',
        'author': 'Dr. Williams',
        'genre': 'Pharmacology',
        'rating': '4.7',
        'reviews': '156',
        'color': const Color(0xFF34D399),
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
                  color: Color(0xFFD4D4D4),
                ),
              ),
              Text(
                'Show All →',
                style: TextStyle(
                  color: const Color(0xFF4B5E4A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
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
                    children: [
                      Container(
                        width: 140,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4B5E4A),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4B5E4A).withOpacity(0.2),
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
                      Text(
                        ebook['title'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ebook['author'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        ebook['genre'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF4B5E4A),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            ebook['rating'] as String,
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.star, color: Color(0xFFFBBF24), size: 12),
                          const SizedBox(width: 2),
                          Expanded(
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReferEarnSection() {
    return Container(
      margin: const EdgeInsets.all(20),
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
                  color: Color(0xFFD4D4D4),
                ),
              ),
              Text(
                'View All →',
                style: TextStyle(
                  color: const Color(0xFF4B5E4A),
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
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD4D4D4).withOpacity(0.05),
                Color(0xFFD4D4D4).withOpacity(0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: const Color(0xFF4B5E4A).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildActivityItem('📖', 'Completed "Canine Anatomy" quiz', '2 hours ago'),
              Divider(color: const Color(0xFF4B5E4A).withOpacity(0.2)),
              _buildActivityItem('⭐', 'Achieved 95% in Surgery module', '1 day ago'),
              Divider(color: const Color(0xFF4B5E4A).withOpacity(0.2)),
              _buildActivityItem('🎯', 'Completed weekly learning goal', '3 days ago'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B5E4A), Color(0xFF6B7A69)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4B5E4A).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4D4D4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5E4A),
                    fontWeight: FontWeight.w500,
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
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD4D4D4).withOpacity(0.1),
            Color(0xFFD4D4D4).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 48,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF4B5E4A).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [const Color(0xFF4B5E4A), const Color(0xFF6B7A69)],
            ).createShader(bounds),
            child: const Text(
              '5,247',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Color(0xFFD4D4D4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Successful Veterinarians',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD4D4D4),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Veterinarians who advanced their careers through our platform',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4B5E4A), Color(0xFF6B7A69)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(0xFFD4D4D4), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4B5E4A).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    index == 4 ? '+' : ['DR', 'VT', 'AS', 'MJ'][index],
                    style: const TextStyle(
                      color: Color(0xFFD4D4D4),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
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
        screen = const QuestionBankScreen();
        break;
      case 'Lectures':
        screen = const LectureBankScreen();
        break;
      case 'Drug Center':
        screen = const EnhancedDrugCenterScreen();
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4B5E4A),
                      const Color(0xFF6B7A69),
                      const Color(0xFF15803D),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4B5E4A).withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background coins pattern
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Transform.rotate(
                        angle: _coinRotation.value * 3.14159,
                        child: Text(
                          '🪙',
                          style: TextStyle(
                            fontSize: 35,
                            color: Color(0xFFD4D4D4).withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      left: 15,
                      child: Transform.rotate(
                        angle: -_coinRotation.value * 3.14159,
                        child: Text(
                          '💰',
                          style: TextStyle(
                            fontSize: 28,
                            color: Color(0xFFD4D4D4).withOpacity(0.1),
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
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Refer & Earn',
                              style: TextStyle(
                                color: Color(0xFFD4D4D4),
                                fontSize: 22,
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
                            const SizedBox(width: 10),
                            Transform.rotate(
                              angle: -_coinRotation.value * 3.14159,
                              child: const Text(
                                '💰',
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 14),
                        
                        // Animated reward amount
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFD4D4D4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Color(0xFFD4D4D4).withOpacity(0.3)),
                          ),
                          child: const Text(
                            '🎁 Earn ₹50 per referral!',
                            style: TextStyle(
                              color: Color(0xFFD4D4D4),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        // Description
                        const Text(
                          'Share with fellow veterinarians\nand build your earning network!',
                          style: TextStyle(
                            color: Color(0xFFD4D4D4),
                            fontSize: 14,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Animated button
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Color(0xFFD4D4D4), Colors.grey.shade100],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🚀 '),
                                        const Text('Code: '),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4B5E4A),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'VET2024',
                                            style: TextStyle(
                                              color: Color(0xFFD4D4D4),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Color(0xFFD4D4D4),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.share,
                                    color: const Color(0xFF4B5E4A),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Invite Friends Now',
                                    style: TextStyle(
                                      color: const Color(0xFF4B5E4A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    '🚀',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
              color: Color(0xFFD4D4D4),
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
            color: Color(0xFFD4D4D4),
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