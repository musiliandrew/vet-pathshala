import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../providers/gamification_provider.dart';
import 'battle_screen.dart';
import 'subscription_required_screen.dart';

class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedBattleType = ''; // '1v1' or 'group'
  String _selectedSubject = '';
  
  // Sample subjects data
  final List<Map<String, dynamic>> subjects = [
    {
      'id': '1',
      'title': 'Veterinary Anatomy',
      'icon': Icons.pets,
      'color': const Color(0xFF667eea),
      'questionsCount': 2156,
    },
    {
      'id': '2',
      'title': 'Animal Physiology',
      'icon': Icons.favorite,
      'color': const Color(0xFFf093fb),
      'questionsCount': 1854,
    },
    {
      'id': '3',
      'title': 'Pathology & Diseases',
      'icon': Icons.healing,
      'color': const Color(0xFF4facfe),
      'questionsCount': 2847,
    },
    {
      'id': '4',
      'title': 'Pharmacology',
      'icon': Icons.medication,
      'color': const Color(0xFF43e97b),
      'questionsCount': 1534,
    },
    {
      'id': '5',
      'title': 'Clinical Veterinary',
      'icon': Icons.local_hospital,
      'color': const Color(0xFFfa709a),
      'questionsCount': 1987,
    },
    {
      'id': '6',
      'title': 'Animal Nutrition',
      'icon': Icons.restaurant,
      'color': const Color(0xFFa8edea),
      'questionsCount': 1245,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        return Consumer<GamificationProvider>(
          builder: (context, gamificationProvider, child) {
            // Check if user has active subscription for gamification
            if (!gamificationProvider.canAccessGamification) {
              return const SubscriptionRequiredScreen(
                featureName: 'Gamification',
                description: 'Access battles, achievements, leaderboards, and daily challenges',
                icon: Icons.sports_esports,
              );
            }

            return Consumer<CoinProvider>(
              builder: (context, coinProvider, child) {
            return Scaffold(
              backgroundColor: UnifiedTheme.backgroundColor,
              body: SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header with Rank, Score, and Coins
                      _buildHeaderSection(context, user, coinProvider),
                      
                      // Main content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Step 1: Select Battle Type
                              _buildBattleSelection(),
                              
                              if (_selectedBattleType.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                // Step 2: Select Subject
                                _buildSubjectSelection(),
                              ],
                              
                              if (_selectedBattleType.isNotEmpty && _selectedSubject.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                // Step 3: Play Options
                                _buildPlayOptions(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
              },
            );
          },
        );
      },
    );
  }

  // Step 1: Header with Rank, Score, and Coins
  Widget _buildHeaderSection(BuildContext context, user, coinProvider) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1F2937),
            size: 18,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color(0xFFf093fb),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              
              // Content
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Battle Arena',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Rank, Score, and Coins Row
                    Row(
                      children: [
                        _buildStatCard('Rank', '15', Icons.emoji_events, const Color(0xFFFFD700)),
                        const SizedBox(width: 12),
                        _buildStatCard('Score', '1650', Icons.star, const Color(0xFF4facfe)),
                        const SizedBox(width: 12),
                        _buildStatCard('Coins', '${coinProvider.currentBalance}', Icons.monetization_on, const Color(0xFF43e97b)),
                      ],
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Battle Selection (1v1 or Group Battle)
  Widget _buildBattleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sports_mma, color: UnifiedTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Select Battle Type',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            // 1v1 Battle
            Expanded(
              child: _buildBattleTypeCard(
                '1v1 Battle',
                'Challenge a single opponent',
                Icons.person_outline,
                '1v1',
                const Color(0xFFf093fb),
              ),
            ),
            const SizedBox(width: 12),
            // Group Battle
            Expanded(
              child: _buildBattleTypeCard(
                'Group Battle',
                'Join a group challenge',
                Icons.groups,
                'group',
                const Color(0xFF43e97b),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBattleTypeCard(String title, String subtitle, IconData icon, String type, Color color) {
    final isSelected = _selectedBattleType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBattleType = type;
          _selectedSubject = ''; // Reset subject selection
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : UnifiedTheme.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? color : UnifiedTheme.tertiaryText,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : UnifiedTheme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: UnifiedTheme.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Subject Selection
  Widget _buildSubjectSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: UnifiedTheme.blueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: UnifiedTheme.blueAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Choose Your Subject',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final subject = subjects[index];
            return _buildSubjectCard(subject);
          },
        ),
      ],
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final isSelected = _selectedSubject == subject['id'];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubject = subject['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              subject['color'],
              subject['color'].withOpacity(0.8),
            ],
          ),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: subject['color'].withOpacity(0.3),
              blurRadius: isSelected ? 16 : 8,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      subject['icon'],
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Title
                  Text(
                    subject['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Question count
                  Text(
                    '${subject['questionsCount']} questions',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: UnifiedTheme.primaryGreen,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Step 4: Play Options
  Widget _buildPlayOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: UnifiedTheme.goldAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_arrow, color: UnifiedTheme.goldAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Ready to Play?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: UnifiedTheme.primaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Play with Computer (AI) - Perfect for offline play
        _buildPlayOptionCard(
          'Play with Computer',
          'Challenge our AI anytime, perfect when no friends are online',
          Icons.computer,
          const Color(0xFF667eea),
          () => _playWithComputer(),
        ),
        
        const SizedBox(height: 12),
        
        // Play with Friends
        _buildPlayOptionCard(
          'Play with Friends',
          'Invite friends to join the battle',
          Icons.group_add,
          const Color(0xFFf093fb),
          () => _playWithFriends(),
        ),
        
        const SizedBox(height: 12),
        
        // Let's Play (Random match)
        _buildPlayOptionCard(
          "Let's Play",
          'Find random opponent and start battle',
          Icons.flash_on,
          const Color(0xFF43e97b),
          () => _letsPlay(),
        ),
      ],
    );
  }

  Widget _buildPlayOptionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _playWithComputer() {
    final selectedSubjectTitle = subjects.firstWhere((s) => s['id'] == _selectedSubject)['title'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.computer, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text('Play with Computer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Battle Type: ${_selectedBattleType.toUpperCase()}'),
            Text('Subject: $selectedSubjectTitle'),
            const SizedBox(height: 16),
            const Text(
              '🤖 Choose AI difficulty level (Always available):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDifficultyButton('Easy', '🟢 Great for beginners', Colors.green),
            const SizedBox(height: 8),
            _buildDifficultyButton('Medium', '🟡 Balanced challenge', Colors.orange),
            const SizedBox(height: 8),
            _buildDifficultyButton('Hard', '🔴 Expert level', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(String level, String description, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          _startComputerBattle(level);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(level, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _startComputerBattle(String difficulty) {
    final selectedSubjectTitle = subjects.firstWhere((s) => s['id'] == _selectedSubject)['title'];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🤖 Starting $difficulty AI battle in $selectedSubjectTitle (Always available offline!)'),
        backgroundColor: const Color(0xFF667eea),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Start',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to battle screen
            _navigateToBattleScreen('computer', difficulty);
          },
        ),
      ),
    );
  }

  void _playWithFriends() {
    final selectedSubjectTitle = subjects.firstWhere((s) => s['id'] == _selectedSubject)['title'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.group_add, color: UnifiedTheme.primaryGreen),
            SizedBox(width: 8),
            Text('Play with Friends'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Battle Type: ${_selectedBattleType.toUpperCase()}'),
            Text('Subject: $selectedSubjectTitle'),
            const SizedBox(height: 16),
            const Text(
              'Choose how to invite friends:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInviteButton('📧 Send Email Invite', 'Invite via email', Colors.blue),
            const SizedBox(height: 8),
            _buildInviteButton('📱 Share Invite Link', 'Share battle link', Colors.green),
            const SizedBox(height: 8),
            _buildInviteButton('📋 Copy Battle Code', 'Share battle code', Colors.orange),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton(String title, String subtitle, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          _sendFriendInvite(title);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _sendFriendInvite(String method) {
    final selectedSubjectTitle = subjects.firstWhere((s) => s['id'] == _selectedSubject)['title'];
    final battleCode = 'VET${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$method sent! Battle Code: $battleCode'),
        backgroundColor: const Color(0xFFf093fb),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Copy Code',
          textColor: Colors.white,
          onPressed: () {
            // Copy battle code to clipboard
            _navigateToBattleScreen('friends', battleCode);
          },
        ),
      ),
    );
  }

  void _letsPlay() {
    final selectedSubjectTitle = subjects.firstWhere((s) => s['id'] == _selectedSubject)['title'];
    
    // Show searching animation dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.flash_on, color: Color(0xFF43e97b)),
            SizedBox(width: 8),
            Text('Finding Opponent...'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF43e97b)),
            ),
            const SizedBox(height: 16),
            Text('Searching for players in $_selectedBattleType battle...'),
            Text('Subject: $selectedSubjectTitle'),
            const SizedBox(height: 16),
            const Text(
              '⚡ Average wait time: 30 seconds',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    
    // Simulate finding opponent after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // Close search dialog
        _showOpponentFound();
      }
    });
  }

  void _showOpponentFound() {
    final opponents = ['Dr. Sarah Wilson', 'Dr. Mike Johnson', 'Dr. Emily Chen', 'Dr. Alex Kumar'];
    final randomOpponent = opponents[DateTime.now().millisecond % opponents.length];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: UnifiedTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF43e97b)),
            SizedBox(width: 8),
            Text('Opponent Found!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, size: 60, color: Color(0xFF43e97b)),
            const SizedBox(height: 16),
            Text(
              randomOpponent,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Ready to battle!'),
            const SizedBox(height: 16),
            const Text(
              '🏆 Current Rank: Expert\n⚡ Win Rate: 85%',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToBattleScreen('random', randomOpponent);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF43e97b)),
            child: const Text('Start Battle!', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToBattleScreen(String battleType, String opponent) {
    final selectedSubjectTitle = subjects.firstWhere((s) => s['id'] == _selectedSubject)['title'];
    
    // Navigate directly to battle screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattleScreen(
          battleType: battleType,
          opponent: opponent,
          subject: selectedSubjectTitle,
          difficulty: battleType == 'computer' ? opponent : 'Medium', // opponent contains difficulty for computer battles
        ),
      ),
    );
  }
}