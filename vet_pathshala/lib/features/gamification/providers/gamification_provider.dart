import 'package:flutter/foundation.dart';
import '../models/gamification_model.dart';
import '../services/gamification_service.dart';
import '../../auth/providers/auth_provider.dart';

class GamificationProvider extends ChangeNotifier {
  static final GamificationProvider _instance = GamificationProvider._internal();
  factory GamificationProvider() => _instance;
  GamificationProvider._internal();

  final GamificationService _gamificationService = GamificationService();
  
  // Current user ID
  String? _currentUserId;
  bool _isInitialized = false;

  // Getters that delegate to the service
  UserGameStats? get userStats => _gamificationService.currentUserStats;
  List<Achievement> get achievements => _gamificationService.achievements;
  List<DailyChallenge> get dailyChallenges => _gamificationService.dailyChallenges;
  List<LeaderboardEntry> get leaderboard => _gamificationService.leaderboard;
  List<PointsTransaction> get recentTransactions => _gamificationService.recentTransactions;
  bool get isLoading => _gamificationService.isLoading;
  bool get isInitialized => _isInitialized;

  // Filtered getters
  List<Achievement> get unlockedAchievements => 
      achievements.where((a) => a.isUnlocked).toList();
  
  List<Achievement> get lockedAchievements => 
      achievements.where((a) => !a.isUnlocked).toList();

  List<DailyChallenge> get activeChallenges => 
      dailyChallenges.where((c) => !c.isCompleted && c.isValid).toList();

  List<DailyChallenge> get completedChallenges => 
      dailyChallenges.where((c) => c.isCompleted).toList();

  // Initialize for a user
  Future<void> initializeForUser(String userId) async {
    if (_currentUserId == userId && _isInitialized) return;
    
    _currentUserId = userId;
    _isInitialized = false;
    notifyListeners();

    // Listen to the service
    _gamificationService.addListener(_onServiceUpdate);
    
    await _gamificationService.initializeUser(userId);
    
    _isInitialized = true;
    notifyListeners();
  }

  void _onServiceUpdate() {
    notifyListeners();
  }

  // User progress helpers
  double get levelProgress {
    if (userStats == null) return 0.0;
    
    if (userStats!.level >= 10) return 1.0;
    
    final currentLevelPoints = _getLevelThreshold(userStats!.level - 1);
    final nextLevelPoints = _getLevelThreshold(userStats!.level);
    final pointsInLevel = userStats!.totalPoints - currentLevelPoints;
    final pointsNeededForLevel = nextLevelPoints - currentLevelPoints;
    
    return pointsInLevel / pointsNeededForLevel;
  }

  int _getLevelThreshold(int level) {
    const thresholds = [0, 100, 500, 1000, 2500, 5000, 10000, 20000, 50000, 100000];
    if (level < 0) return 0;
    if (level >= thresholds.length) return thresholds.last;
    return thresholds[level];
  }

  // Achievement categories
  List<Achievement> getAchievementsByCategory(String category) {
    return achievements.where((a) => a.category == category).toList();
  }

  int getUnlockedAchievementsCount(String category) {
    return achievements
        .where((a) => a.category == category && a.isUnlocked)
        .length;
  }

  int getTotalAchievementsCount(String category) {
    return achievements.where((a) => a.category == category).length;
  }

  // Daily challenge helpers
  int get totalChallengeRewards {
    return activeChallenges.fold(0, (sum, challenge) => 
        sum + challenge.pointsReward + challenge.coinsReward);
  }

  double get dailyChallengeProgress {
    if (dailyChallenges.isEmpty) return 0.0;
    final completed = completedChallenges.length;
    return completed / dailyChallenges.length;
  }

  // Streak helpers
  String get streakStatus {
    if (userStats == null) return 'Start your streak!';
    
    final streak = userStats!.currentStreak;
    if (streak == 0) return 'Start your learning streak today!';
    if (streak == 1) return 'Great start! Keep it up!';
    if (streak < 7) return '$streak days strong! 🔥';
    if (streak < 30) return 'Amazing $streak day streak! 🚀';
    return 'Incredible $streak day streak! You\'re a legend! 👑';
  }

  // Leaderboard helpers
  int? getUserRank(String userId) {
    try {
      return leaderboard.firstWhere((entry) => entry.userId == userId).rank;
    } catch (e) {
      return null;
    }
  }

  List<LeaderboardEntry> getTopUsers(int count) {
    return leaderboard.take(count).toList();
  }

  // Action delegates to service
  Future<void> awardPoints({
    required int points,
    required String reason,
    String? referenceId,
  }) async {
    if (_currentUserId == null) return;
    
    await _gamificationService.awardPoints(
      userId: _currentUserId!,
      points: points,
      reason: reason,
      referenceId: referenceId,
    );
  }

  Future<void> onQuestionAnswered(bool isCorrect, String category) async {
    if (_currentUserId == null) return;
    
    await _gamificationService.onQuestionAnswered(
      _currentUserId!,
      isCorrect,
      category,
    );
  }

  Future<void> onLessonCompleted(String category) async {
    if (_currentUserId == null) return;
    
    await _gamificationService.onLessonCompleted(_currentUserId!, category);
  }

  Future<void> onNoteRead(String category) async {
    if (_currentUserId == null) return;
    
    await _gamificationService.onNoteRead(_currentUserId!, category);
  }

  Future<void> completeDailyChallenge(String challengeId) async {
    if (_currentUserId == null) return;
    
    await _gamificationService.completeDailyChallenge(_currentUserId!, challengeId);
  }

  Future<void> loadLeaderboard({String period = 'all_time', int limit = 50}) async {
    await _gamificationService.loadLeaderboard(period: period, limit: limit);
  }

  // Quick stats
  Map<String, dynamic> getQuickStats() {
    if (userStats == null) {
      return {
        'level': 1,
        'levelTitle': 'Novice',
        'totalPoints': 0,
        'rank': 'N/A',
        'streak': 0,
        'accuracy': '0%',
        'achievements': 0,
      };
    }

    return {
      'level': userStats!.level,
      'levelTitle': userStats!.levelTitle,
      'totalPoints': userStats!.totalPoints,
      'rank': getUserRank(_currentUserId!) ?? 'N/A',
      'streak': userStats!.currentStreak,
      'accuracy': '${(userStats!.accuracy * 100).toInt()}%',
      'achievements': unlockedAchievements.length,
    };
  }

  // Category stats
  Map<String, int> getCategoryStats() {
    return userStats?.categoryStats ?? {};
  }

  String getMostActiveCategory() {
    final stats = getCategoryStats();
    if (stats.isEmpty) return 'None yet';
    
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries.first.key;
  }

  // Recent activity
  List<Map<String, dynamic>> getRecentActivity({int limit = 5}) {
    return recentTransactions.take(limit).map((transaction) {
      String action = '';
      String icon = '';
      
      switch (transaction.reason) {
        case 'correct_answer':
          action = 'Answered question correctly';
          icon = '✅';
          break;
        case 'lesson_completed':
          action = 'Completed lesson';
          icon = '📚';
          break;
        case 'note_read':
          action = 'Read notes';
          icon = '📝';
          break;
        case 'achievement':
          action = 'Unlocked achievement';
          icon = '🏆';
          break;
        case 'daily_challenge':
          action = 'Completed daily challenge';
          icon = '⭐';
          break;
        default:
          action = 'Earned points';
          icon = '⚡';
      }
      
      return {
        'action': action,
        'icon': icon,
        'points': transaction.points,
        'date': transaction.createdAt,
      };
    }).toList();
  }

  // Level rewards
  Map<String, dynamic> getLevelRewards(int level) {
    final rewards = {
      2: {'coins': 50, 'title': 'First Level Up!'},
      3: {'coins': 100, 'title': 'Getting Started'},
      5: {'coins': 200, 'title': 'Dedicated Learner'},
      7: {'coins': 300, 'title': 'Knowledge Seeker'},
      10: {'coins': 500, 'title': 'Grandmaster Unlocked!'},
    };
    
    return rewards[level] ?? {};
  }

  // Reset/cleanup
  void reset() {
    _currentUserId = null;
    _isInitialized = false;
    _gamificationService.removeListener(_onServiceUpdate);
    notifyListeners();
  }

  @override
  void dispose() {
    _gamificationService.removeListener(_onServiceUpdate);
    super.dispose();
  }
}