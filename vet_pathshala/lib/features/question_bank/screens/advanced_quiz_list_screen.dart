import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/quiz_models.dart';
import '../../../shared/models/user_model.dart';
import '../providers/advanced_quiz_provider.dart';
import '../widgets/quiz_card_widget.dart';
import 'timed_quiz_screen.dart';

class AdvancedQuizListScreen extends StatefulWidget {
  final UserModel user;

  const AdvancedQuizListScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdvancedQuizListScreen> createState() => _AdvancedQuizListScreenState();
}

class _AdvancedQuizListScreenState extends State<AdvancedQuizListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategory;
  DifficultyLevel? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuizzes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadQuizzes() {
    final provider = context.read<AdvancedQuizProvider>();
    provider.loadQuizzes(
      userRole: widget.user.userRole,
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Advanced Quizzes',
          style: UnifiedTheme.headingStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: UnifiedTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Practice'),
            Tab(text: 'Timed'),
            Tab(text: 'Battles'),
            Tab(text: 'Mock Exams'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_selectedCategory != null || _selectedDifficulty != null)
            _buildFilterChips(),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuizList(QuizType.practice),
                _buildQuizList(QuizType.timed),
                _buildBattlesList(),
                _buildQuizList(QuizType.mock_exam),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateBattleDialog,
        backgroundColor: UnifiedTheme.primaryColor,
        icon: const Icon(Icons.battle),
        label: const Text('Challenge'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedCategory != null)
            Chip(
              label: Text('Category: $_selectedCategory'),
              onDeleted: () {
                setState(() {
                  _selectedCategory = null;
                });
                _loadQuizzes();
              },
            ),
          if (_selectedDifficulty != null)
            Chip(
              label: Text('Difficulty: ${_selectedDifficulty!.name}'),
              onDeleted: () {
                setState(() {
                  _selectedDifficulty = null;
                });
                _loadQuizzes();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuizList(QuizType type) {
    return Consumer<AdvancedQuizProvider>(
      builder: (context, provider, child) {
        final quizzes = provider.availableQuizzes
            .where((quiz) => quiz.type == type)
            .toList();

        if (quizzes.isEmpty) {
          return _buildEmptyState(type);
        }

        return RefreshIndicator(
          onRefresh: () async => _loadQuizzes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return QuizCardWidget(
                quiz: quiz,
                user: widget.user,
                onTap: () => _startQuiz(quiz),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBattlesList() {
    return Consumer<AdvancedQuizProvider>(
      builder: (context, provider, child) {
        final battles = provider.availableBattles;

        if (battles.isEmpty) {
          return _buildEmptyBattlesState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadAvailableBattles(
              userId: widget.user.id,
              category: _selectedCategory,
            );
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: battles.length,
            itemBuilder: (context, index) {
              final battle = battles[index];
              return _buildBattleCard(battle);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(QuizType type) {
    String title;
    String subtitle;
    IconData icon;

    switch (type) {
      case QuizType.practice:
        title = 'No Practice Quizzes';
        subtitle = 'Practice quizzes will appear here when available';
        icon = Icons.quiz_outlined;
        break;
      case QuizType.timed:
        title = 'No Timed Quizzes';
        subtitle = 'Challenge yourself with time-based quizzes';
        icon = Icons.timer;
        break;
      case QuizType.mock_exam:
        title = 'No Mock Exams';
        subtitle = 'Full-length practice exams coming soon';
        icon = Icons.school;
        break;
      default:
        title = 'No Quizzes Available';
        subtitle = 'Check back later for new content';
        icon = Icons.quiz;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: UnifiedTheme.headingStyle),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: UnifiedTheme.bodyStyle.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBattlesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_martial_arts, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No Active Battles', style: UnifiedTheme.headingStyle),
          const SizedBox(height: 8),
          Text(
            'Create a challenge or wait for others to challenge you',
            style: UnifiedTheme.bodyStyle.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateBattleDialog,
            icon: const Icon(Icons.add_circle),
            label: const Text('Create Challenge'),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleCard(QuizBattleModel battle) {
    final isChallenger = battle.challengerId == widget.user.id;
    final hasOpponent = battle.opponentId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_martial_arts,
                  color: UnifiedTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isChallenger ? 'Your Challenge' : 'Open Challenge',
                    style: UnifiedTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${battle.coinReward} coins',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              'Category: ${battle.category}',
              style: UnifiedTheme.bodyStyle,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              hasOpponent ? 'Battle in progress' : 'Waiting for opponent',
              style: UnifiedTheme.captionStyle.copyWith(
                color: hasOpponent ? Colors.green : Colors.orange,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (!isChallenger && !hasOpponent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _joinBattle(battle),
                  child: const Text('Accept Challenge'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(QuizModel quiz) {
    // Check if user can afford premium quiz
    if (quiz.isPremium && widget.user.coins < quiz.coinCost) {
      _showInsufficientCoinsDialog(quiz);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimedQuizScreen(
          quiz: quiz,
          user: widget.user,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(
        selectedCategory: _selectedCategory,
        selectedDifficulty: _selectedDifficulty,
        onApply: (category, difficulty) {
          setState(() {
            _selectedCategory = category;
            _selectedDifficulty = difficulty;
          });
          _loadQuizzes();
        },
      ),
    );
  }

  void _showCreateBattleDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateBattleDialog(
        user: widget.user,
        onCreateBattle: (category, coinReward) async {
          try {
            final provider = context.read<AdvancedQuizProvider>();
            await provider.createQuizBattle(
              challengerId: widget.user.id,
              category: category,
              coinReward: coinReward,
            );
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Challenge created successfully!'),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _joinBattle(QuizBattleModel battle) async {
    try {
      final provider = context.read<AdvancedQuizProvider>();
      await provider.joinQuizBattle(
        battleId: battle.id,
        userId: widget.user.id,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined battle successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showInsufficientCoinsDialog(QuizModel quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Coins'),
        content: Text(
          'This quiz requires ${quiz.coinCost} coins. You have ${widget.user.coins} coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to coins purchase screen
            },
            child: const Text('Buy Coins'),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String? selectedCategory;
  final DifficultyLevel? selectedDifficulty;
  final Function(String?, DifficultyLevel?) onApply;

  const _FilterSheet({
    this.selectedCategory,
    this.selectedDifficulty,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _category;
  DifficultyLevel? _difficulty;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _difficulty = widget.selectedDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter Quizzes', style: UnifiedTheme.headingStyle),
          const SizedBox(height: 24),
          
          // Category filter
          Text('Category', style: UnifiedTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              'Anatomy', 'Physiology', 'Pathology', 'Pharmacology', 'Surgery'
            ].map((category) => FilterChip(
              label: Text(category),
              selected: _category == category,
              onSelected: (selected) {
                setState(() {
                  _category = selected ? category : null;
                });
              },
            )).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Difficulty filter
          Text('Difficulty', style: UnifiedTheme.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: DifficultyLevel.values.map((difficulty) => FilterChip(
              label: Text(difficulty.name),
              selected: _difficulty == difficulty,
              onSelected: (selected) {
                setState(() {
                  _difficulty = selected ? difficulty : null;
                });
              },
            )).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _category = null;
                      _difficulty = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_category, _difficulty);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateBattleDialog extends StatefulWidget {
  final UserModel user;
  final Function(String, int) onCreateBattle;

  const _CreateBattleDialog({
    required this.user,
    required this.onCreateBattle,
  });

  @override
  State<_CreateBattleDialog> createState() => _CreateBattleDialogState();
}

class _CreateBattleDialogState extends State<_CreateBattleDialog> {
  String _selectedCategory = 'Anatomy';
  int _coinReward = 10;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Quiz Battle'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: ['Anatomy', 'Physiology', 'Pathology', 'Pharmacology', 'Surgery']
                .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              const Text('Coin Reward: '),
              Expanded(
                child: Slider(
                  value: _coinReward.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: '$_coinReward coins',
                  onChanged: (value) {
                    setState(() {
                      _coinReward = value.toInt();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCreateBattle(_selectedCategory, _coinReward);
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}