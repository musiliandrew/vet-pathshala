import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/question_provider.dart';
import '../../coins/providers/coin_provider.dart';
import '../../auth/providers/auth_provider.dart';

class PracticeModeScreen extends StatefulWidget {
  final String userRole;

  const PracticeModeScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<PracticeModeScreen> createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen> {
  String? _selectedCategory;
  String? _selectedDifficulty;
  int _questionCount = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Practice Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.getRoleGradient(widget.userRole),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Practice Session',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Test your knowledge with random questions',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Settings
              Text(
                'Practice Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Category Selection
              _buildSettingCard(
                'Category',
                'Select a specific category or leave blank for all',
                Consumer<QuestionProvider>(
                  builder: (context, questionProvider, child) {
                    return DropdownButton<String?>(
                      value: _selectedCategory,
                      hint: const Text('All Categories'),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...questionProvider.categories.map((category) =>
                          DropdownMenuItem<String?>(
                            value: category,
                            child: Text(_formatCategoryName(category)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    );
                  },
                ),
              ),

              // Difficulty Selection
              _buildSettingCard(
                'Difficulty',
                'Choose difficulty level or leave blank for mixed',
                DropdownButton<String?>(
                  value: _selectedDifficulty,
                  hint: const Text('All Difficulties'),
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Difficulties'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'beginner',
                      child: Text('Beginner'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'intermediate',
                      child: Text('Intermediate'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'advanced',
                      child: Text('Advanced'),
                    ),
                    DropdownMenuItem<String?>(
                      value: 'expert',
                      child: Text('Expert'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  },
                ),
              ),

              // Question Count
              _buildSettingCard(
                'Number of Questions',
                'How many questions do you want to practice?',
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _questionCount.toDouble(),
                        min: 5,
                        max: 50,
                        divisions: 9,
                        label: _questionCount.toString(),
                        onChanged: (value) {
                          setState(() {
                            _questionCount = value.round();
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _questionCount.toString(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Start Practice Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startPractice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getRoleColor(widget.userRole),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Practice Session',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(String title, String description, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _formatCategoryName(String category) {
    return category
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  void _startPractice() {
    // TODO: Navigate to actual practice session
    // For now, simulate quiz completion and award coins
    _simulateQuizCompletion();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Starting practice with $_questionCount questions'
          '${_selectedCategory != null ? ' in ${_formatCategoryName(_selectedCategory!)}' : ''}'
          '${_selectedDifficulty != null ? ' (${_selectedDifficulty!} level)' : ''}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _simulateQuizCompletion() {
    // Simulate quiz completion with random results
    final authProvider = context.read<AuthProvider>();
    final coinProvider = context.read<CoinProvider>();
    
    if (authProvider.currentUser != null) {
      // Simulate random quiz performance (70-95% correct)
      final correctAnswers = (_questionCount * (0.7 + (0.25 * (DateTime.now().millisecond / 1000)))).round();
      
      // Award coins for quiz completion
      coinProvider.awardQuizCompletionCoins(
        userId: authProvider.currentUser!.id,
        questionsCorrect: correctAnswers,
        totalQuestions: _questionCount,
      );
      
      // Show completion message with coins earned
      final baseCoins = coinProvider.getCoinEarningRates()['quiz_complete'] ?? 10;
      final percentage = correctAnswers / _questionCount;
      final coinsEarned = (baseCoins * percentage).round();
      
      if (coinsEarned > 0) {
        Future.delayed(const Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Quiz completed! You got $correctAnswers/$_questionCount correct and earned $coinsEarned coins! 🪙',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        });
      }
    }
  }
}