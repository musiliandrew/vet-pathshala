import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../auth/providers/auth_provider.dart';

class DetailedPerformanceScreen extends StatefulWidget {
  const DetailedPerformanceScreen({super.key});

  @override
  State<DetailedPerformanceScreen> createState() => _DetailedPerformanceScreenState();
}

class _DetailedPerformanceScreenState extends State<DetailedPerformanceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'This Week';
  final List<String> _timeframes = ['Today', 'This Week', 'This Month', 'All Time'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Performance Analysis'),
        backgroundColor: UnifiedTheme.backgroundColor,
        foregroundColor: UnifiedTheme.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (value) {
              setState(() {
                _selectedTimeframe = value;
              });
            },
            itemBuilder: (context) => _timeframes.map((timeframe) {
              return PopupMenuItem(
                value: timeframe,
                child: Text(timeframe),
              );
            }).toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: UnifiedTheme.primaryGreen,
          labelColor: UnifiedTheme.primaryGreen,
          unselectedLabelColor: UnifiedTheme.tertiaryText,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Quizzes'),
            Tab(text: 'Learning'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(child: Text('Please sign in to view performance'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildQuizzesTab(),
              _buildLearningTab(),
              _buildProgressTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Quiz Accuracy',
                  '87%',
                  Icons.track_changes,
                  UnifiedTheme.primaryGreen,
                  '+5% from last week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Study Streak',
                  '12 days',
                  Icons.local_fire_department,
                  Colors.orange,
                  'Personal best!',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Points',
                  '2,450',
                  Icons.star,
                  UnifiedTheme.goldAccent,
                  '+150 this week',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Rank',
                  '#23',
                  Icons.leaderboard,
                  UnifiedTheme.blueAccent,
                  'Out of 1,247',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Weekly Activity Chart
          _buildActivityChart(),

          const SizedBox(height: 24),

          // Recent Achievements
          _buildRecentAchievements(),
        ],
      ),
    );
  }

  Widget _buildQuizzesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz Performance Stats
          _buildQuizPerformanceStats(),
          
          const SizedBox(height: 24),
          
          // Subject-wise Performance
          _buildSubjectPerformance(),
          
          const SizedBox(height: 24),
          
          // Difficulty Analysis
          _buildDifficultyAnalysis(),
        ],
      ),
    );
  }

  Widget _buildLearningTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Learning Stats
          _buildLearningStats(),
          
          const SizedBox(height: 24),
          
          // Content Engagement
          _buildContentEngagement(),
          
          const SizedBox(height: 24),
          
          // Study Recommendations
          _buildStudyRecommendations(),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Timeline
          _buildProgressTimeline(),
          
          const SizedBox(height: 24),
          
          // Goal Tracking
          _buildGoalTracking(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, String? subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: UnifiedTheme.tertiaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: UnifiedTheme.tertiaryText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Simple bar chart representation
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActivityBar('Mon', 0.7, UnifiedTheme.primaryGreen),
                _buildActivityBar('Tue', 0.4, UnifiedTheme.blueAccent),
                _buildActivityBar('Wed', 0.9, UnifiedTheme.primaryGreen),
                _buildActivityBar('Thu', 0.6, UnifiedTheme.goldAccent),
                _buildActivityBar('Fri', 0.8, UnifiedTheme.primaryGreen),
                _buildActivityBar('Sat', 0.3, UnifiedTheme.tertiaryText),
                _buildActivityBar('Sun', 0.5, UnifiedTheme.blueAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBar(String day, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: 80 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            fontSize: 10,
            color: UnifiedTheme.tertiaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAchievements() {
    final achievements = [
      {'title': 'Quiz Master', 'description': 'Completed 10 quizzes in a row', 'icon': Icons.quiz, 'color': UnifiedTheme.primaryGreen},
      {'title': 'Fast Learner', 'description': 'Completed course in record time', 'icon': Icons.speed, 'color': UnifiedTheme.blueAccent},
      {'title': 'Consistent Student', 'description': '7-day study streak', 'icon': Icons.local_fire_department, 'color': Colors.orange},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...achievements.map((achievement) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (achievement['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: (achievement['color'] as Color).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  achievement['icon'] as IconData,
                  color: achievement['color'] as Color,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        achievement['description'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: UnifiedTheme.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuizPerformanceStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quiz Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total Quizzes', '34', Icons.quiz, UnifiedTheme.primaryGreen),
              ),
              Expanded(
                child: _buildStatItem('Passed', '29', Icons.check_circle, UnifiedTheme.primaryGreen),
              ),
              Expanded(
                child: _buildStatItem('Failed', '5', Icons.cancel, UnifiedTheme.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Best Score', '96%', Icons.star, UnifiedTheme.goldAccent),
              ),
              Expanded(
                child: _buildStatItem('Average', '87%', Icons.trending_up, UnifiedTheme.blueAccent),
              ),
              Expanded(
                child: _buildStatItem('Time Saved', '2.5h', Icons.schedule, UnifiedTheme.tertiaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: UnifiedTheme.tertiaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubjectPerformance() {
    final subjects = [
      {'name': 'Anatomy', 'score': 92, 'total': 15, 'color': UnifiedTheme.primaryGreen},
      {'name': 'Pharmacology', 'score': 85, 'total': 12, 'color': UnifiedTheme.blueAccent},
      {'name': 'Pathology', 'score': 78, 'total': 8, 'color': UnifiedTheme.goldAccent},
      {'name': 'Surgery', 'score': 94, 'total': 6, 'color': UnifiedTheme.primaryGreen},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject-wise Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...subjects.map((subject) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subject['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${subject['score']}% (${subject['total']} quizzes)',
                      style: TextStyle(
                        fontSize: 12,
                        color: subject['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (subject['score'] as int) / 100,
                  backgroundColor: UnifiedTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(subject['color'] as Color),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDifficultyAnalysis() {
    final difficulties = [
      {'name': 'Beginner', 'correct': 45, 'total': 50, 'color': UnifiedTheme.primaryGreen},
      {'name': 'Intermediate', 'correct': 32, 'total': 40, 'color': UnifiedTheme.goldAccent},
      {'name': 'Advanced', 'correct': 18, 'total': 25, 'color': UnifiedTheme.redAccent},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Difficulty Level Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...difficulties.map((diff) {
            final accuracy = ((diff['correct'] as int) / (diff['total'] as int) * 100).round();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (diff['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (diff['color'] as Color).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: diff['color'] as Color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diff['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${diff['correct']} correct out of ${diff['total']} questions',
                          style: const TextStyle(
                            fontSize: 12,
                            color: UnifiedTheme.tertiaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$accuracy%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: diff['color'] as Color,
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

  Widget _buildLearningStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Notes Read', '28', Icons.book, UnifiedTheme.primaryGreen),
              ),
              Expanded(
                child: _buildStatItem('Videos Watched', '15', Icons.play_circle, UnifiedTheme.blueAccent),
              ),
              Expanded(
                child: _buildStatItem('Flashcards', '156', Icons.style, UnifiedTheme.goldAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Study Time', '45h', Icons.schedule, UnifiedTheme.tertiaryText),
              ),
              Expanded(
                child: _buildStatItem('Bookmarks', '12', Icons.bookmark, UnifiedTheme.goldAccent),
              ),
              Expanded(
                child: _buildStatItem('Highlights', '89', Icons.highlight, Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentEngagement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Content Engagement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildEngagementItem('Drug Center', 95, UnifiedTheme.primaryGreen),
          _buildEngagementItem('Question Bank', 88, UnifiedTheme.blueAccent),
          _buildEngagementItem('Short Notes', 76, UnifiedTheme.goldAccent),
          _buildEngagementItem('Video Lectures', 65, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(String feature, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                feature,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: UnifiedTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyRecommendations() {
    final recommendations = [
      {
        'title': 'Focus on Advanced Topics',
        'description': 'Your intermediate scores are strong. Try advanced level quizzes.',
        'icon': Icons.trending_up,
        'color': UnifiedTheme.goldAccent,
      },
      {
        'title': 'Review Pathology',
        'description': 'Pathology accuracy is 78%. Review your weak areas.',
        'icon': Icons.refresh,
        'color': UnifiedTheme.blueAccent,
      },
      {
        'title': 'Maintain Study Streak',
        'description': 'You\'re doing great! Keep your daily study habit.',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study Recommendations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (rec['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (rec['color'] as Color).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: rec['color'] as Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    rec['icon'] as IconData,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rec['description'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: UnifiedTheme.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline() {
    final milestones = [
      {
        'date': 'Today',
        'title': 'Completed Advanced Quiz',
        'description': 'Scored 94% in Veterinary Surgery quiz',
        'isCompleted': true,
      },
      {
        'date': 'Yesterday',
        'title': 'Study Streak: 12 days',
        'description': 'Maintained consistent daily learning',
        'isCompleted': true,
      },
      {
        'date': '3 days ago',
        'title': 'Drug Calculator Mastery',
        'description': 'Used advanced dosage calculations 20 times',
        'isCompleted': true,
      },
      {
        'date': '1 week ago',
        'title': 'Quiz Champion',
        'description': 'Passed 10 consecutive quizzes',
        'isCompleted': true,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Timeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...milestones.map((milestone) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: milestone['isCompleted'] as bool
                        ? UnifiedTheme.primaryGreen
                        : UnifiedTheme.borderColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    milestone['isCompleted'] as bool
                        ? Icons.check
                        : Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone['date'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: UnifiedTheme.tertiaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        milestone['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        milestone['description'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: UnifiedTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildGoalTracking() {
    final goals = [
      {
        'title': 'Weekly Quiz Goal',
        'current': 8,
        'target': 10,
        'unit': 'quizzes',
        'color': UnifiedTheme.primaryGreen,
      },
      {
        'title': 'Study Time Goal',
        'current': 6,
        'target': 8,
        'unit': 'hours',
        'color': UnifiedTheme.blueAccent,
      },
      {
        'title': 'Accuracy Target',
        'current': 87,
        'target': 90,
        'unit': '%',
        'color': UnifiedTheme.goldAccent,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: UnifiedTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goal Tracking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...goals.map((goal) {
            final progress = (goal['current'] as int) / (goal['target'] as int);
            final isCompleted = progress >= 1.0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (goal['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (goal['color'] as Color).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        goal['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          if (isCompleted)
                            Icon(
                              Icons.check_circle,
                              color: goal['color'] as Color,
                              size: 16,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            '${goal['current']}/${goal['target']} ${goal['unit']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: goal['color'] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: UnifiedTheme.borderColor,
                    valueColor: AlwaysStoppedAnimation<Color>(goal['color'] as Color),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}