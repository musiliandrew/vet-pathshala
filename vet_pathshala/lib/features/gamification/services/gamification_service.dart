import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_model.dart';
import '../../coins/providers/coin_provider.dart';

class GamificationService extends ChangeNotifier {
  static final GamificationService _instance = GamificationService._internal();
  factory GamificationService() => _instance;
  GamificationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Service states
  UserGameStats? _currentUserStats;
  List<Achievement> _achievements = [];
  List<DailyChallenge> _dailyChallenges = [];
  List<LeaderboardEntry> _leaderboard = [];
  List<PointsTransaction> _recentTransactions = [];
  bool _isLoading = false;

  // Getters
  UserGameStats? get currentUserStats => _currentUserStats;
  List<Achievement> get achievements => _achievements;
  List<DailyChallenge> get dailyChallenges => _dailyChallenges;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  List<PointsTransaction> get recentTransactions => _recentTransactions;
  bool get isLoading => _isLoading;

  // Initialize user stats
  Future<void> initializeUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _loadUserStats(userId);
      await _loadAchievements(userId);
      await _loadDailyChallenges(userId);
      await _loadRecentTransactions(userId);

      debugPrint('✅ Gamification service initialized for user: $userId');
    } catch (e) {
      debugPrint('❌ Error initializing gamification: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserStats(String userId) async {
    try {
      final doc = await _firestore.collection('user_game_stats').doc(userId).get();
      
      if (doc.exists) {
        _currentUserStats = UserGameStats.fromFirestore(doc);
      } else {
        // Create new user stats
        _currentUserStats = UserGameStats(
          userId: userId,
          lastActiveDate: DateTime.now(),
        );
        await _saveUserStats();
      }
    } catch (e) {
      debugPrint('❌ Error loading user stats: $e');
    }
  }

  Future<void> _loadAchievements(String userId) async {
    try {
      // Load all achievements
      final achievementsSnapshot = await _firestore
          .collection('achievements')
          .orderBy('category')
          .get();

      // Load user's unlocked achievements
      final userAchievementsSnapshot = await _firestore
          .collection('user_achievements')
          .where('userId', isEqualTo: userId)
          .get();

      final unlockedIds = userAchievementsSnapshot.docs
          .map((doc) => doc.data()['achievementId'] as String)
          .toSet();

      _achievements = achievementsSnapshot.docs.map((doc) {
        final achievement = Achievement.fromFirestore(doc);
        return Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          pointsReward: achievement.pointsReward,
          coinsReward: achievement.coinsReward,
          category: achievement.category,
          requirements: achievement.requirements,
          isUnlocked: unlockedIds.contains(achievement.id),
          unlockedAt: achievement.unlockedAt,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error loading achievements: $e');
    }
  }

  Future<void> _loadDailyChallenges(String userId) async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final challengesSnapshot = await _firestore
          .collection('daily_challenges')
          .where('validDate', isEqualTo: Timestamp.fromDate(todayStart))
          .get();

      final userChallengesSnapshot = await _firestore
          .collection('user_daily_challenges')
          .where('userId', isEqualTo: userId)
          .where('validDate', isEqualTo: Timestamp.fromDate(todayStart))
          .get();

      final completedIds = userChallengesSnapshot.docs
          .map((doc) => doc.data()['challengeId'] as String)
          .toSet();

      _dailyChallenges = challengesSnapshot.docs.map((doc) {
        final challenge = DailyChallenge.fromFirestore(doc);
        return DailyChallenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          requirements: challenge.requirements,
          pointsReward: challenge.pointsReward,
          coinsReward: challenge.coinsReward,
          validDate: challenge.validDate,
          isCompleted: completedIds.contains(challenge.id),
          completedAt: challenge.completedAt,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error loading daily challenges: $e');
    }
  }

  Future<void> _loadRecentTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('points_transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      _recentTransactions = snapshot.docs
          .map((doc) => PointsTransaction.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading transactions: $e');
    }
  }

  // Award points for various actions
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String reason,
    String? referenceId,
  }) async {
    try {
      if (_currentUserStats == null) return;

      // Create transaction
      final transaction = PointsTransaction(
        id: _generateTransactionId(),
        userId: userId,
        points: points,
        type: 'earned',
        reason: reason,
        referenceId: referenceId,
        createdAt: DateTime.now(),
      );

      // Save transaction
      await _firestore
          .collection('points_transactions')
          .doc(transaction.id)
          .set(transaction.toFirestore());

      // Update user stats
      _currentUserStats = UserGameStats(
        userId: _currentUserStats!.userId,
        totalPoints: _currentUserStats!.totalPoints + points,
        totalCoins: _currentUserStats!.totalCoins,
        currentStreak: _currentUserStats!.currentStreak,
        maxStreak: _currentUserStats!.maxStreak,
        questionsAnswered: _currentUserStats!.questionsAnswered,
        correctAnswers: _currentUserStats!.correctAnswers,
        lessonsCompleted: _currentUserStats!.lessonsCompleted,
        notesRead: _currentUserStats!.notesRead,
        achievementsUnlocked: _currentUserStats!.achievementsUnlocked,
        rank: _currentUserStats!.rank,
        lastActiveDate: DateTime.now(),
        categoryStats: _currentUserStats!.categoryStats,
      );

      await _saveUserStats();
      await _checkAchievements(userId);

      // Add to recent transactions
      _recentTransactions.insert(0, transaction);
      if (_recentTransactions.length > 20) {
        _recentTransactions.removeLast();
      }

      debugPrint('✅ Awarded $points points for $reason');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error awarding points: $e');
    }
  }

  // Update activity stats
  Future<void> updateActivity({
    required String userId,
    int questionsAnswered = 0,
    int correctAnswers = 0,
    int lessonsCompleted = 0,
    int notesRead = 0,
    String? category,
  }) async {
    try {
      if (_currentUserStats == null) return;

      final categoryStats = Map<String, int>.from(_currentUserStats!.categoryStats);
      if (category != null) {
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }

      _currentUserStats = UserGameStats(
        userId: _currentUserStats!.userId,
        totalPoints: _currentUserStats!.totalPoints,
        totalCoins: _currentUserStats!.totalCoins,
        currentStreak: _updateStreak(),
        maxStreak: _currentUserStats!.maxStreak,
        questionsAnswered: _currentUserStats!.questionsAnswered + questionsAnswered,
        correctAnswers: _currentUserStats!.correctAnswers + correctAnswers,
        lessonsCompleted: _currentUserStats!.lessonsCompleted + lessonsCompleted,
        notesRead: _currentUserStats!.notesRead + notesRead,
        achievementsUnlocked: _currentUserStats!.achievementsUnlocked,
        rank: _currentUserStats!.rank,
        lastActiveDate: DateTime.now(),
        categoryStats: categoryStats,
      );

      await _saveUserStats();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error updating activity: $e');
    }
  }

  int _updateStreak() {
    if (_currentUserStats == null) return 0;

    final now = DateTime.now();
    final lastActive = _currentUserStats!.lastActiveDate;
    final daysSinceLastActive = now.difference(lastActive).inDays;

    if (daysSinceLastActive == 1) {
      // Consecutive day
      final newStreak = _currentUserStats!.currentStreak + 1;
      final maxStreak = newStreak > _currentUserStats!.maxStreak 
          ? newStreak 
          : _currentUserStats!.maxStreak;
      
      // Update max streak in stats
      _currentUserStats = UserGameStats(
        userId: _currentUserStats!.userId,
        totalPoints: _currentUserStats!.totalPoints,
        totalCoins: _currentUserStats!.totalCoins,
        currentStreak: _currentUserStats!.currentStreak,
        maxStreak: maxStreak,
        questionsAnswered: _currentUserStats!.questionsAnswered,
        correctAnswers: _currentUserStats!.correctAnswers,
        lessonsCompleted: _currentUserStats!.lessonsCompleted,
        notesRead: _currentUserStats!.notesRead,
        achievementsUnlocked: _currentUserStats!.achievementsUnlocked,
        rank: _currentUserStats!.rank,
        lastActiveDate: _currentUserStats!.lastActiveDate,
        categoryStats: _currentUserStats!.categoryStats,
      );

      return newStreak;
    } else if (daysSinceLastActive > 1) {
      // Streak broken
      return 0;
    } else {
      // Same day
      return _currentUserStats!.currentStreak;
    }
  }

  Future<void> _checkAchievements(String userId) async {
    try {
      if (_currentUserStats == null) return;

      for (final achievement in _achievements) {
        if (achievement.isUnlocked) continue;

        bool shouldUnlock = false;

        switch (achievement.category) {
          case 'learning':
            shouldUnlock = _checkLearningAchievement(achievement);
            break;
          case 'social':
            shouldUnlock = _checkSocialAchievement(achievement);
            break;
          case 'milestone':
            shouldUnlock = _checkMilestoneAchievement(achievement);
            break;
        }

        if (shouldUnlock) {
          await _unlockAchievement(userId, achievement);
        }
      }
    } catch (e) {
      debugPrint('❌ Error checking achievements: $e');
    }
  }

  bool _checkLearningAchievement(Achievement achievement) {
    final requirements = achievement.requirements;
    
    if (requirements.containsKey('questionsAnswered')) {
      if (_currentUserStats!.questionsAnswered < requirements['questionsAnswered']) {
        return false;
      }
    }
    
    if (requirements.containsKey('correctAnswers')) {
      if (_currentUserStats!.correctAnswers < requirements['correctAnswers']) {
        return false;
      }
    }
    
    if (requirements.containsKey('accuracy')) {
      if (_currentUserStats!.accuracy < requirements['accuracy']) {
        return false;
      }
    }
    
    return true;
  }

  bool _checkSocialAchievement(Achievement achievement) {
    // Implement social achievement checks (sharing, referrals, etc.)
    return false;
  }

  bool _checkMilestoneAchievement(Achievement achievement) {
    final requirements = achievement.requirements;
    
    if (requirements.containsKey('totalPoints')) {
      if (_currentUserStats!.totalPoints < requirements['totalPoints']) {
        return false;
      }
    }
    
    if (requirements.containsKey('streak')) {
      if (_currentUserStats!.maxStreak < requirements['streak']) {
        return false;
      }
    }
    
    return true;
  }

  Future<void> _unlockAchievement(String userId, Achievement achievement) async {
    try {
      // Record achievement unlock
      await _firestore.collection('user_achievements').add({
        'userId': userId,
        'achievementId': achievement.id,
        'unlockedAt': FieldValue.serverTimestamp(),
      });

      // Award points and coins
      await awardPoints(
        userId: userId,
        points: achievement.pointsReward,
        reason: 'achievement',
        referenceId: achievement.id,
      );

      if (achievement.coinsReward > 0) {
        CoinProvider().addCoins(achievement.coinsReward, 'achievement');
      }

      // Update achievement in local list
      final index = _achievements.indexWhere((a) => a.id == achievement.id);
      if (index != -1) {
        _achievements[index] = Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          icon: achievement.icon,
          pointsReward: achievement.pointsReward,
          coinsReward: achievement.coinsReward,
          category: achievement.category,
          requirements: achievement.requirements,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }

      debugPrint('🏆 Achievement unlocked: ${achievement.title}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error unlocking achievement: $e');
    }
  }

  // Complete daily challenge
  Future<void> completeDailyChallenge(String userId, String challengeId) async {
    try {
      final challenge = _dailyChallenges.firstWhere((c) => c.id == challengeId);
      
      if (challenge.isCompleted) return;

      // Record completion
      await _firestore.collection('user_daily_challenges').add({
        'userId': userId,
        'challengeId': challengeId,
        'completedAt': FieldValue.serverTimestamp(),
        'validDate': Timestamp.fromDate(challenge.validDate),
      });

      // Award rewards
      await awardPoints(
        userId: userId,
        points: challenge.pointsReward,
        reason: 'daily_challenge',
        referenceId: challengeId,
      );

      if (challenge.coinsReward > 0) {
        CoinProvider().addCoins(challenge.coinsReward, 'daily_challenge');
      }

      // Update challenge in local list
      final index = _dailyChallenges.indexWhere((c) => c.id == challengeId);
      if (index != -1) {
        _dailyChallenges[index] = DailyChallenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          type: challenge.type,
          requirements: challenge.requirements,
          pointsReward: challenge.pointsReward,
          coinsReward: challenge.coinsReward,
          validDate: challenge.validDate,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
      }

      debugPrint('✅ Daily challenge completed: ${challenge.title}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error completing daily challenge: $e');
    }
  }

  // Load leaderboard
  Future<void> loadLeaderboard({String period = 'all_time', int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('user_game_stats')
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();

      _leaderboard = snapshot.docs.asMap().entries.map((entry) {
        final index = entry.key;
        final doc = entry.value;
        final data = doc.data();
        
        return LeaderboardEntry(
          userId: doc.id,
          displayName: data['displayName'] ?? 'Anonymous',
          profileImageUrl: data['profileImageUrl'],
          totalPoints: data['totalPoints'] ?? 0,
          rank: index + 1,
          userRole: data['userRole'] ?? '',
          questionsAnswered: data['questionsAnswered'] ?? 0,
          accuracy: data['questionsAnswered'] > 0 
              ? (data['correctAnswers'] ?? 0) / (data['questionsAnswered'] ?? 1)
              : 0.0,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading leaderboard: $e');
    }
  }

  Future<void> _saveUserStats() async {
    try {
      if (_currentUserStats == null) return;

      await _firestore
          .collection('user_game_stats')
          .doc(_currentUserStats!.userId)
          .set(_currentUserStats!.toFirestore());
    } catch (e) {
      debugPrint('❌ Error saving user stats: $e');
    }
  }

  String _generateTransactionId() {
    return 'pts_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Quick access methods for common actions
  Future<void> onQuestionAnswered(String userId, bool isCorrect, String category) async {
    await updateActivity(
      userId: userId,
      questionsAnswered: 1,
      correctAnswers: isCorrect ? 1 : 0,
      category: category,
    );

    if (isCorrect) {
      await awardPoints(
        userId: userId,
        points: 10,
        reason: 'correct_answer',
      );
    }
  }

  Future<void> onLessonCompleted(String userId, String category) async {
    await updateActivity(
      userId: userId,
      lessonsCompleted: 1,
      category: category,
    );

    await awardPoints(
      userId: userId,
      points: 25,
      reason: 'lesson_completed',
    );
  }

  Future<void> onNoteRead(String userId, String category) async {
    await updateActivity(
      userId: userId,
      notesRead: 1,
      category: category,
    );

    await awardPoints(
      userId: userId,
      points: 5,
      reason: 'note_read',
    );
  }
}