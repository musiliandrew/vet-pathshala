import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/test_series_models.dart';

class VictoryModal extends StatefulWidget {
  final TestResultModel result;
  final VoidCallback onContinue;

  const VictoryModal({
    super.key,
    required this.result,
    required this.onContinue,
  });

  @override
  State<VictoryModal> createState() => _VictoryModalState();
}

class _VictoryModalState extends State<VictoryModal>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    UnifiedTheme.primary.withOpacity(0.1),
                    Colors.white,
                    UnifiedTheme.goldAccent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Victory Header
                    _buildVictoryHeader(),
                    
                    const SizedBox(height: 24),
                    
                    // Score Display
                    _buildScoreDisplay(),
                    
                    const SizedBox(height: 24),
                    
                    // Category Scores
                    _buildCategoryScores(),
                    
                    const SizedBox(height: 24),
                    
                    // Rewards Section
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildRewardsSection(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Continue Button
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildContinueButton(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVictoryHeader() {
    return Column(
      children: [
        // Trophy Animation
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 0.1,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      UnifiedTheme.goldAccent,
                      UnifiedTheme.goldAccent.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: UnifiedTheme.goldAccent.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Victory Text
        Text(
          'Victory!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: UnifiedTheme.primary,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Rank Display
        if (widget.result.rank <= 10)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [UnifiedTheme.goldAccent, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Rank #${widget.result.rank}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UnifiedTheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Final Score',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Animated Score Counter
          TweenAnimationBuilder<int>(
            duration: const Duration(milliseconds: 1500),
            tween: IntTween(begin: 0, end: widget.result.finalScore),
            builder: (context, value, child) {
              return Text(
                '$value',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: UnifiedTheme.primary,
                ),
              );
            },
          ),
          
          Text(
            '/ ${widget.result.totalMarks}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Percentage
          Text(
            '${widget.result.percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.result.percentage >= 60 
                  ? Colors.green[600] 
                  : Colors.orange[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScores() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 12),
          
          ...widget.result.categoryWiseScores.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: UnifiedTheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            UnifiedTheme.goldAccent.withOpacity(0.1),
            UnifiedTheme.primary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.goldAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // XP Reward
          _buildRewardItem(
            icon: '🏆',
            label: '+${widget.result.xpEarned} XP Earned',
            color: UnifiedTheme.primary,
          ),
          
          // Coins Reward
          _buildRewardItem(
            icon: '💰',
            label: '+${widget.result.coinsEarned} Coins Earned',
            color: UnifiedTheme.goldAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required String icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: UnifiedTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: UnifiedTheme.primary.withOpacity(0.3),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}