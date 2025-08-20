import 'package:flutter/foundation.dart';
import '../models/gamification_models.dart';
import '../models/user_model.dart';
import '../services/gamification_service.dart';

enum GamificationState {
  idle,
  loading,
  loaded,
  error
}

class GamificationProvider extends ChangeNotifier {
  final GamificationService _gamificationService = GamificationService();

  // State management
  GamificationState _state = GamificationState.idle;
  String? _errorMessage;

  // Badges
  List<BadgeModel> _allBadges = [];
  List<UserBadgeModel> _userBadges = [];
  Map<String, BadgeModel> _badgeDetails = {};

  // Challenges
  List<ChallengeModel> _activeChallenges = [];
  List<UserChallengeModel> _userChallenges = [];

  // Achievements
  List<AchievementModel> _allAchievements = [];
  List<UserAchievementModel> _userAchievements = [];

  // Leaderboard
  List<LeaderboardEntryModel> _leaderboard = [];
  LeaderboardEntryModel? _userLeaderboardEntry;

  // Streaks
  List<StreakModel> _userStreaks = [];

  // User stats
  Map<String, dynamic> _userStats = {};

  // Getters
  GamificationState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == GamificationState.loading;

  List<BadgeModel> get allBadges => _allBadges;
  List<UserBadgeModel> get userBadges => _userBadges;
  List<ChallengeModel> get activeChallenges => _activeChallenges;
  List<UserChallengeModel> get userChallenges => _userChallenges;
  List<AchievementModel> get allAchievements => _allAchievements;
  List<UserAchievementModel> get userAchievements => _userAchievements;
  List<LeaderboardEntryModel> get leaderboard => _leaderboard;
  LeaderboardEntryModel? get userLeaderboardEntry => _userLeaderboardEntry;
  List<StreakModel> get userStreaks => _userStreaks;
  Map<String, dynamic> get userStats => _userStats;

  // Computed properties
  int get totalBadges => _userBadges.length;
  int get totalAchievements => _userAchievements.where((a) => a.isCompleted).length;
  int get activeChallengesCount => _userChallenges.where((c) => c.status == ChallengeStatus.active).length;
  int get completedChallengesCount => _userChallenges.where((c) => c.status == ChallengeStatus.completed).length;

  StreakModel? get dailyLoginStreak => _userStreaks
      .where((s) => s.streakType == 'daily_login')
      .firstOrNull;

  StreakModel? get studyStreak => _userStreaks
      .where((s) => s.streakType == 'study_time')
      .firstOrNull;

  List<BadgeModel> get rareBadges => _getUserBadgesWithDetails()
      .where((badge) => badge.rarity == BadgeRarity.rare || 
                       badge.rarity == BadgeRarity.epic || 
                       badge.rarity == BadgeRarity.legendary)
      .toList();

  List<ChallengeModel> get todaysChallenges => _activeChallenges
      .where((c) => c.type == ChallengeType.daily && c.isOngoing)
      .toList();

  // Badge Management
  Future<void> loadBadges({String? targetRole}) async {
    try {
      _setState(GamificationState.loading);
      _allBadges = await _gamificationService.getAllBadges(targetRole: targetRole);
      
      // Create badge details map for quick lookup
      _badgeDetails = {
        for (final badge in _allBadges) badge.id: badge
      };
      
      _setState(GamificationState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUserBadges(String userId) async {
    try {
      _userBadges = await _gamificationService.getUserBadges(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  List<BadgeModel> _getUserBadgesWithDetails() {
    return _userBadges
        .map((userBadge) => _badgeDetails[userBadge.badgeId])
        .where((badge) => badge != null)
        .cast<BadgeModel>()
        .toList();
  }

  Future<void> awardBadge(String userId, String badgeId, {Map<String, dynamic>? progressData}) async {
    try {
      await _gamificationService.awardBadge(userId, badgeId, progressData: progressData);
      await loadUserBadges(userId);
      
      // Show notification or update UI
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Challenge Management
  Future<void> loadActiveChallenges({String? targetRole}) async {
    try {
      _activeChallenges = await _gamificationService.getActiveChallenges(targetRole: targetRole);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUserChallenges(String userId) async {
    try {
      _userChallenges = await _gamificationService.getUserChallenges(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<String> startChallenge(String userId, String challengeId) async {
    try {
      final userChallengeId = await _gamificationService.startChallenge(userId, challengeId);
      await loadUserChallenges(userId);
      return userChallengeId;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> updateChallengeProgress(
    String userId,
    String challengeId,
    Map<String, dynamic> progressUpdate,
  ) async {
    try {
      await _gamificationService.updateChallengeProgress(userId, challengeId, progressUpdate);
      await loadUserChallenges(userId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  ChallengeModel? getChallengeById(String challengeId) {
    return _activeChallenges.where((c) => c.id == challengeId).firstOrNull;
  }

  UserChallengeModel? getUserChallengeById(String challengeId) {
    return _userChallenges.where((c) => c.challengeId == challengeId).firstOrNull;
  }

  double getChallengeProgress(String challengeId) {
    final userChallenge = getUserChallengeById(challengeId);
    return userChallenge?.completionPercentage ?? 0.0;
  }

  // Achievement Management
  Future<void> loadAchievements() async {
    try {
      _allAchievements = await _gamificationService.getAllAchievements();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUserAchievements(String userId) async {
    try {
      _userAchievements = await _gamificationService.getUserAchievements(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> checkAndUnlockAchievements(String userId, Map<String, dynamic> userStats) async {
    try {
      await _gamificationService.checkAndUnlockAchievements(userId, userStats);
      await loadUserAchievements(userId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  List<AchievementModel> getUnlockedAchievements() {
    final unlockedIds = _userAchievements.map((ua) => ua.achievementId).toSet();
    return _allAchievements.where((a) => unlockedIds.contains(a.id)).toList();
  }

  List<AchievementModel> getLockedAchievements() {
    final unlockedIds = _userAchievements.map((ua) => ua.achievementId).toSet();
    return _allAchievements.where((a) => !unlockedIds.contains(a.id)).toList();
  }

  // Leaderboard Management
  Future<void> loadLeaderboard({String? category, String? timeframe}) async {
    try {
      _leaderboard = await _gamificationService.getLeaderboard(
        category: category,
        timeframe: timeframe,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateUserLeaderboard(String userId) async {
    try {
      await _gamificationService.updateLeaderboard(userId);
      await loadLeaderboard();
      
      // Find user's entry
      _userLeaderboardEntry = _leaderboard.where((entry) => entry.userId == userId).firstOrNull;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  int getUserRank(String userId) {
    return _leaderboard.indexWhere((entry) => entry.userId == userId) + 1;
  }

  List<LeaderboardEntryModel> getTopUsers(int count) {
    return _leaderboard.take(count).toList();
  }

  // Streak Management
  Future<void> loadUserStreaks(String userId) async {
    try {
      _userStreaks = await _gamificationService.getUserStreaks(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateStreak(String userId, String streakType) async {
    try {
      await _gamificationService.updateStreak(userId, streakType);
      await loadUserStreaks(userId);
    } catch (e) {
      _setError(e.toString());
    }
  }

  StreakModel? getStreakByType(String streakType) {
    return _userStreaks.where((s) => s.streakType == streakType).firstOrNull;
  }

  bool isStreakActive(String streakType) {
    final streak = getStreakByType(streakType);
    return streak?.isActive ?? false;
  }

  int getCurrentStreak(String streakType) {
    final streak = getStreakByType(streakType);
    return streak?.currentStreak ?? 0;
  }

  int getLongestStreak(String streakType) {
    final streak = getStreakByType(streakType);
    return streak?.longestStreak ?? 0;
  }

  // Progress Tracking
  void recordQuizCompletion(String userId, {
    required String quizTitle,
    required int score,
    required String category,
  }) {
    // Update challenge progress for quiz-related challenges
    _updateQuizChallengeProgress(userId, score, category);
    
    // Update streaks
    updateStreak(userId, 'quiz_completion');
    
    // Check for achievements
    final updatedStats = Map<String, dynamic>.from(_userStats);
    updatedStats['quizzesCompleted'] = (updatedStats['quizzesCompleted'] ?? 0) + 1;
    updatedStats['totalScore'] = (updatedStats['totalScore'] ?? 0) + score;
    _userStats = updatedStats;
    
    checkAndUnlockAchievements(userId, updatedStats);
  }

  void _updateQuizChallengeProgress(String userId, int score, String category) {
    for (final userChallenge in _userChallenges) {
      if (userChallenge.status != ChallengeStatus.active) continue;
      
      final challenge = getChallengeById(userChallenge.challengeId);
      if (challenge == null) continue;
      
      final progressUpdate = <String, dynamic>{};
      
      // Check if this challenge has quiz requirements
      if (challenge.requirements.containsKey('quizzes_completed')) {
        final currentQuizzes = userChallenge.progress['quizzes_completed'] ?? 0;
        progressUpdate['quizzes_completed'] = currentQuizzes + 1;
      }
      
      if (challenge.requirements.containsKey('min_score') && 
          score >= (challenge.requirements['min_score'] ?? 0)) {
        final currentHighScores = userChallenge.progress['high_score_quizzes'] ?? 0;
        progressUpdate['high_score_quizzes'] = currentHighScores + 1;
      }
      
      if (progressUpdate.isNotEmpty) {
        updateChallengeProgress(userId, userChallenge.challengeId, progressUpdate);
      }
    }
  }

  void recordStudySession(String userId, int minutes) {
    updateStreak(userId, 'study_time');
    
    // Update study time challenges
    for (final userChallenge in _userChallenges) {
      if (userChallenge.status != ChallengeStatus.active) continue;
      
      final challenge = getChallengeById(userChallenge.challengeId);
      if (challenge?.requirements.containsKey('study_minutes') == true) {
        final currentMinutes = userChallenge.progress['study_minutes'] ?? 0;
        updateChallengeProgress(
          userId,
          userChallenge.challengeId,
          {'study_minutes': currentMinutes + minutes},
        );
      }
    }
  }

  void recordDailyLogin(String userId) {
    updateStreak(userId, 'daily_login');
    
    // Update daily login challenges
    for (final userChallenge in _userChallenges) {
      if (userChallenge.status != ChallengeStatus.active) continue;
      
      final challenge = getChallengeById(userChallenge.challengeId);
      if (challenge?.requirements.containsKey('daily_login') == true) {
        updateChallengeProgress(
          userId,
          userChallenge.challengeId,
          {'daily_login': 1},
        );
      }
    }
  }

  // Initialization
  Future<void> initializeGamification(String userId, {String? userRole}) async {
    try {
      _setState(GamificationState.loading);
      
      // Load all gamification data
      await Future.wait([
        loadBadges(targetRole: userRole),
        loadUserBadges(userId),
        loadActiveChallenges(targetRole: userRole),
        loadUserChallenges(userId),
        loadAchievements(),
        loadUserAchievements(userId),
        loadUserStreaks(userId),
        loadLeaderboard(),
      ]);
      
      _setState(GamificationState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Utility methods
  void _setState(GamificationState newState) {
    _state = newState;
    if (newState != GamificationState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _state = GamificationState.error;
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == GamificationState.error) {
      _state = GamificationState.idle;
    }
    notifyListeners();
  }

  // Badge filtering and sorting
  List<BadgeModel> getBadgesByCategory(BadgeCategory category) {
    return _getUserBadgesWithDetails()
        .where((badge) => badge.category == category)
        .toList();
  }

  List<BadgeModel> getBadgesByRarity(BadgeRarity rarity) {
    return _getUserBadgesWithDetails()
        .where((badge) => badge.rarity == rarity)
        .toList();
  }

  // Challenge filtering
  List<ChallengeModel> getChallengesByType(ChallengeType type) {
    return _activeChallenges.where((c) => c.type == type).toList();
  }

  List<UserChallengeModel> getUserChallengesByStatus(ChallengeStatus status) {
    return _userChallenges.where((c) => c.status == status).toList();
  }

  // Statistics
  Map<String, int> getBadgeStats() {
    final stats = <String, int>{};
    for (final category in BadgeCategory.values) {
      stats[category.name] = getBadgesByCategory(category).length;
    }
    return stats;
  }

  Map<String, int> getChallengeStats() {
    return {
      'active': activeChallengesCount,
      'completed': completedChallengesCount,
      'total': _userChallenges.length,
    };
  }
}

// Extension to add firstOrNull method
extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}