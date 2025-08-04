import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/animated_particles_background.dart';
import '../../../shared/widgets/sliding_banner_widget.dart';
import '../../../shared/widgets/enhanced_3d_card.dart';
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

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String _selectedCategory = '';
  String _selectedPerformanceTab = 'Overall';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutBack,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
      _fadeController.forward();
      _headerController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _headerController.dispose();
    super.dispose();
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
          backgroundColor: UnifiedTheme.backgroundColor,
          body: AnimatedParticlesBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => homeProvider.refresh(user.id),
                color: UnifiedTheme.primary,
                child: SingleChildScrollView(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            
                            // Enhanced Header
                            _buildModernHeader(context, user),
                            
                            // Enhanced Search Bar
                            _buildModernSearchBar(),
                            
                            // Sliding Banner Section
                            _buildSlidingBanners(),
                            
                            // Categories Grid
                            _buildModernCategoriesSection(),
                            
                            // Popular Ebooks
                            _buildModernEbooksSection(),
                            
                            // Enhanced Performance Tracking
                            _buildModernPerformanceSection(context, user, homeProvider),
                            
                            // Refer & Earn
                            _buildModernReferEarnSection(),
                            
                            // Recent Activity
                            _buildModernActivitySection(context, homeProvider),
                            
                            // Success Stories & Achievements
                            _buildModernSuccessSection(),
                            
                            // Social Media Links
                            _buildSocialMediaSection(),
                            
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Modern Header with animations
  Widget _buildModernHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting with underline animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _headerController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: UnifiedTheme.primary,
                          width: 4 * _headerController.value,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Good Morning',
                      style: TextStyle(
                        color: UnifiedTheme.dark,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 5),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Welcome back to VetPathshala',
                  style: TextStyle(
                    color: UnifiedTheme.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          
          // Header Icons
          Row(
            children: [
              // Animated Menu Icon
              _buildAnimatedMenuIcon(),
              const SizedBox(width: 15),
              
              // Notification with badge
              _buildNotificationIcon(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMenuIcon() {
    return GestureDetector(
      onTap: () {
        // Handle menu tap
      },
      child: Container(
        width: 40,
        height: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 25,
              height: 3,
              decoration: BoxDecoration(
                color: UnifiedTheme.dark,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 25,
              height: 3,
              decoration: BoxDecoration(
                color: UnifiedTheme.dark,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 25,
              height: 3,
              decoration: BoxDecoration(
                color: UnifiedTheme.dark,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Enhanced3DCard(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: UnifiedTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('You have 3 new notifications!'),
            backgroundColor: UnifiedTheme.primary,
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.notifications,
                color: UnifiedTheme.dark,
                size: 20,
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: UnifiedTheme.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: UnifiedTheme.light, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Search Bar
  Widget _buildModernSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 25),
      child: Enhanced3DCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: UnifiedTheme.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.transparent, width: 2),
          boxShadow: UnifiedTheme.cardShadow,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: UnifiedTheme.secondaryText,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search veterinary resources...',
                  hintStyle: TextStyle(
                    color: UnifiedTheme.tertiaryText,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sliding Banners
  Widget _buildSlidingBanners() {
    return SlidingBannerWidget(
      banners: DefaultBanners.vetPathshalaBanners,
      height: 150,
    );
  }

  // Modern Categories Section
  Widget _buildModernCategoriesSection() {
    return Column(
      children: [
        _buildSectionTitle('Explore Categories', 'See All'),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.3,
          children: [
            CategoryCard3D(
              icon: Icons.quiz,
              label: 'Q Bank',
              isSelected: _selectedCategory == 'Q Bank',
              onTap: () => _navigateToCategory(context, 'Q Bank'),
            ),
            CategoryCard3D(
              icon: Icons.note_alt,
              label: 'Short Notes',
              isSelected: _selectedCategory == 'Short Notes',
              onTap: () => _navigateToCategory(context, 'Short Notes'),
            ),
            CategoryCard3D(
              icon: Icons.video_library,
              label: 'Lectures',
              isSelected: _selectedCategory == 'Lectures',
              onTap: () => _navigateToCategory(context, 'Lectures'),
            ),
            CategoryCard3D(
              icon: Icons.gamepad,
              label: 'Gamification',
              isSelected: _selectedCategory == 'Gamification',
              onTap: () => _navigateToCategory(context, 'Gamification'),
            ),
            CategoryCard3D(
              icon: Icons.medication,
              label: 'Drug Centre',
              isSelected: _selectedCategory == 'Drug Centre',
              onTap: () => _navigateToCategory(context, 'Drug Centre'),
            ),
            CategoryCard3D(
              icon: Icons.quiz_outlined,
              label: 'Quiz & PYP',
              isSelected: _selectedCategory == 'Quiz & PYP',
              onTap: () => _navigateToCategory(context, 'Quiz & PYP'),
            ),
          ],
        ),
      ],
    );
  }

  // Modern Ebooks Section
  Widget _buildModernEbooksSection() {
    return Column(
      children: [
        const SizedBox(height: 30),
        _buildSectionTitle('Popular Ebooks', 'Browse All'),
        const SizedBox(height: 20),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              EbookCard3D(
                title: 'Veterinary Anatomy',
                author: 'Nikhil Kumar',
                price: '₹499',
                rating: 4.8,
                coverImage: 'assets/images/veterinary_anatomy.jpeg',
                badge: 'Bestseller',
                onTap: () => _navigateToEbooks(context),
              ),
              EbookCard3D(
                title: 'Small Animal Surgery',
                author: 'Johnson',
                price: '₹599',
                rating: 4.9,
                coverImage: 'assets/images/small_animal.jpeg',
                badge: 'New',
                onTap: () => _navigateToEbooks(context),
              ),
              EbookCard3D(
                title: 'Vet Pharmacology',
                author: 'Dr. Williams',
                price: '₹449',
                rating: 4.7,
                coverImage: 'assets/images/vet_pharma.jpeg',
                onTap: () => _navigateToEbooks(context),
              ),
              EbookCard3D(
                title: 'Master Veterinary',
                author: 'Dr. Smith',
                price: '₹599',
                rating: 4.8,
                coverImage: 'assets/images/master_veterinary.jpg',
                badge: 'Popular',
                onTap: () => _navigateToEbooks(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Enhanced Performance Section
  Widget _buildModernPerformanceSection(BuildContext context, UserModel user, HomeProvider homeProvider) {
    return Enhanced3DCard(
      margin: const EdgeInsets.symmetric(vertical: 25),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Track Your Performance',
                style: TextStyle(
                  color: UnifiedTheme.dark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: UnifiedTheme.primary,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tabs
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: UnifiedTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPerformanceTab('Overall'),
                  _buildPerformanceTab('Q Bank'),
                  _buildPerformanceTab('Lectures'),
                  _buildPerformanceTab('Notes'),
                  _buildPerformanceTab('Quiz & PYP'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: PerformanceCard3D(
                  title: 'Courses',
                  value: '18',
                  label: 'Courses',
                  color: UnifiedTheme.primary,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: PerformanceCard3D(
                  title: 'Hours',
                  value: '92',
                  label: 'Hours',
                  color: UnifiedTheme.secondary,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: PerformanceCard3D(
                  title: 'Score',
                  value: '95%',
                  label: 'Score',
                  color: UnifiedTheme.accent,
                  progress: 95,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          GestureDetector(
            onTap: () {
              // Navigate to detailed analytics
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Detailed Analytics',
                  style: TextStyle(
                    color: UnifiedTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward,
                  color: UnifiedTheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(String title) {
    final isSelected = _selectedPerformanceTab == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPerformanceTab = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? UnifiedTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: UnifiedTheme.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : UnifiedTheme.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Modern Refer & Earn Section
  Widget _buildModernReferEarnSection() {
    return Enhanced3DCard(
      margin: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        gradient: UnifiedTheme.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: UnifiedTheme.accentShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 20,
            child: Icon(
              Icons.card_giftcard,
              size: 80,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Refer & Earn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Earn ₹50 per referral!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Share with fellow veterinarians and build your earning network!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Enhanced3DCard(
                onTap: () {
                  // Handle invite action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Invite feature coming soon!'),
                      backgroundColor: UnifiedTheme.primary,
                    ),
                  );
                },
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Invite Friends Now',
                  style: TextStyle(
                    color: UnifiedTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modern Activity Section
  Widget _buildModernActivitySection(BuildContext context, HomeProvider homeProvider) {
    return Column(
      children: [
        _buildSectionTitle('Recent Activity', 'View All'),
        const SizedBox(height: 20),
        ..._buildActivityItems(),
      ],
    );
  }

  List<Widget> _buildActivityItems() {
    return [
      _buildActivityItem(
        Icons.check_circle,
        'Completed "Canine Anatomy" quiz',
        '2 hours ago',
        UnifiedTheme.primary,
      ),
      _buildActivityItem(
        Icons.emoji_events,
        'Achieved 95% in Surgery module',
        '1 day ago',
        UnifiedTheme.accent,
      ),
    ];
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return Enhanced3DCard(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 10,
                      color: UnifiedTheme.secondaryText,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: UnifiedTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Success Section
  Widget _buildModernSuccessSection() {
    return Column(
      children: [
        const SizedBox(height: 30),
        _buildSectionTitle('Success Stories', 'See All'),
        const SizedBox(height: 20),
        
        // Testimonial
        Enhanced3DCard(
          child: Column(
            children: [
              const Text(
                '"VetPathshala helped me pass my exams with flying colors. The Q Bank and lectures were incredibly helpful for my preparation."',
                style: TextStyle(
                  fontSize: 14,
                  color: UnifiedTheme.dark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: UnifiedTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'DR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Rajesh Kumar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'BVSc, MVSc',
                        style: TextStyle(
                          fontSize: 12,
                          color: UnifiedTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Achievement Stats
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: [
            _buildAchievementCard(Icons.people, '5,247+', 'Veterinarians'),
            _buildAchievementCard(Icons.book, '120+', 'Courses'),
            _buildAchievementCard(Icons.star, '4.9/5', 'Rating'),
            _buildAchievementCard(Icons.school, '92%', 'Success Rate'),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard(IconData icon, String value, String label) {
    return Enhanced3DCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: UnifiedTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: UnifiedTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: UnifiedTheme.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: UnifiedTheme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: UnifiedTheme.primary,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.dark,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Handle see all tap
          },
          child: Row(
            children: [
              Text(
                actionText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: UnifiedTheme.secondary,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right,
                color: UnifiedTheme.secondary,
                size: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    setState(() {
      _selectedCategory = category;
    });

    switch (category) {
      case 'Q Bank':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuestionBankScreen()),
        );
        break;
      case 'Short Notes':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ShortNotesScreen()),
        );
        break;
      case 'Lectures':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LectureBankScreen()),
        );
        break;
      case 'Gamification':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GamificationScreen()),
        );
        break;
      case 'Drug Centre':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DrugIndexScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$category feature coming soon!'),
            backgroundColor: UnifiedTheme.primary,
          ),
        );
    }
  }

  Widget _buildSocialMediaSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildSectionTitle('Connect With Us', ''),
        const SizedBox(height: 20),
        Enhanced3DCard(
          child: Column(
            children: [
              const Text(
                'Follow us on social media for updates, tips, and veterinary content!',
                style: TextStyle(
                  fontSize: 14,
                  color: UnifiedTheme.secondaryText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 15,
                runSpacing: 15,
                children: [
                  _buildSocialMediaButton(
                    Icons.facebook,
                    'Facebook',
                    const Color(0xFF4267B2),
                    () {
                      _showSocialMediaSnackBar('Facebook');
                    },
                  ),
                  _buildSocialMediaButton(
                    Icons.alternate_email,
                    'Twitter',
                    const Color(0xFF1DA1F2),
                    () {
                      _showSocialMediaSnackBar('Twitter');
                    },
                  ),
                  _buildSocialMediaButton(
                    Icons.video_library,
                    'YouTube',
                    const Color(0xFFFF0000),
                    () {
                      _showSocialMediaSnackBar('YouTube');
                    },
                  ),
                  _buildSocialMediaButton(
                    Icons.camera_alt,
                    'Instagram',
                    const Color(0xFFE4405F),
                    () {
                      _showSocialMediaSnackBar('Instagram');
                    },
                  ),
                  _buildSocialMediaButton(
                    Icons.business,
                    'LinkedIn',
                    const Color(0xFF0077B5),
                    () {
                      _showSocialMediaSnackBar('LinkedIn');
                    },
                  ),
                  _buildSocialMediaButton(
                    Icons.telegram,
                    'Telegram',
                    const Color(0xFF0088CC),
                    () {
                      _showSocialMediaSnackBar('Telegram');
                    },
                  ),
                  _buildSocialMediaButton(
                    Icons.chat,
                    'WhatsApp',
                    const Color(0xFF25D366),
                    () {
                      _showSocialMediaSnackBar('WhatsApp');
                    },
                  ),
                  _buildSocialMediaButton(
                    Icons.email,
                    'Email',
                    UnifiedTheme.secondary,
                    () {
                      _showSocialMediaSnackBar('Email');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: UnifiedTheme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSocialMediaSnackBar(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $platform...'),
        backgroundColor: UnifiedTheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToEbooks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EbooksScreen()),
    );
  }
}