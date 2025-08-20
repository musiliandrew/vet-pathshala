import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_models.dart';
import '../models/user_model.dart';

class GamificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Badge Management
  Future<List<BadgeModel>> getAllBadges({String? targetRole}) async {
    try {
      Query query = _firestore
          .collection('badges')
          .where('isActive', isEqualTo: true);

      if (targetRole != null) {
        query = query.where('targetRoles', arrayContains: targetRole);
      }

      final snapshot = await query.orderBy('category').orderBy('rarity').get();
      
      return snapshot.docs
          .map((doc) => BadgeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get badges: $e');
    }
  }

  Future<List<UserBadgeModel>> getUserBadges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_badges')
          .where('userId', isEqualTo: userId)
          .orderBy('earnedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserBadgeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user badges: $e');
    }
  }

  Future<void> awardBadge(String userId, String badgeId, {Map<String, dynamic>? progressData}) async {
    try {
      // Check if user already has this badge
      final existingBadge = await _firestore
          .collection('user_badges')
          .where('userId', isEqualTo: userId)
          .where('badgeId', isEqualTo: badgeId)
          .get();

      if (existingBadge.docs.isNotEmpty) {
        return; // User already has this badge
      }

      final userBadge = UserBadgeModel(
        id: '',
        userId: userId,
        badgeId: badgeId,
        earnedAt: DateTime.now(),
        progressData: progressData ?? {},
      );

      await _firestore.collection('user_badges').add(userBadge.toFirestore());

      // Get badge details for points reward
      final badgeDoc = await _firestore.collection('badges').doc(badgeId).get();
      if (badgeDoc.exists) {
        final badge = BadgeModel.fromFirestore(badgeDoc);
        if (badge.pointsReward > 0) {
          await _addUserPoints(userId, badge.pointsReward, 'Badge: ${badge.name}');
        }
      }
    } catch (e) {
      throw Exception('Failed to award badge: $e');
    }
  }

  // Challenge Management
  Future<List<ChallengeModel>> getActiveChallenges({String? targetRole}) async {
    try {
      final now = DateTime.now();
      
      Query query = _firestore
          .collection('challenges')
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThan: Timestamp.fromDate(now));

      if (targetRole != null) {
        query = query.where('targetRoles', arrayContains: targetRole);
      }

      final snapshot = await query.orderBy('endDate').get();
      
      return snapshot.docs
          .map((doc) => ChallengeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get active challenges: $e');
    }
  }

  Future<List<UserChallengeModel>> getUserChallenges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_challenges')
          .where('userId', isEqualTo: userId)
          .orderBy('startedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserChallengeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user challenges: $e');
    }
  }

  Future<String> startChallenge(String userId, String challengeId) async {
    try {
      // Check if user is already participating
      final existingChallenge = await _firestore
          .collection('user_challenges')
          .where('userId', isEqualTo: userId)
          .where('challengeId', isEqualTo: challengeId)
          .where('status', whereIn: [ChallengeStatus.active.name, ChallengeStatus.completed.name])
          .get();

      if (existingChallenge.docs.isNotEmpty) {
        throw Exception('Already participating in this challenge');
      }

      final userChallenge = UserChallengeModel(
        id: '',
        userId: userId,
        challengeId: challengeId,
        status: ChallengeStatus.active,
        startedAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('user_challenges')
          .add(userChallenge.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to start challenge: $e');
    }
  }

  Future<void> updateChallengeProgress(
    String userId,
    String challengeId,
    Map<String, dynamic> progressUpdate,
  ) async {
    try {
      final challengeSnapshot = await _firestore
          .collection('user_challenges')
          .where('userId', isEqualTo: userId)
          .where('challengeId', isEqualTo: challengeId)
          .where('status', isEqualTo: ChallengeStatus.active.name)
          .get();

      if (challengeSnapshot.docs.isEmpty) {
        return; // No active challenge found
      }

      final userChallengeDoc = challengeSnapshot.docs.first;
      final userChallenge = UserChallengeModel.fromFirestore(userChallengeDoc);

      // Merge progress data
      final newProgress = Map<String, dynamic>.from(userChallenge.progress);
      newProgress.addAll(progressUpdate);

      // Calculate completion percentage
      final challengeDoc = await _firestore.collection('challenges').doc(challengeId).get();
      if (!challengeDoc.exists) return;

      final challenge = ChallengeModel.fromFirestore(challengeDoc);
      final completionPercentage = _calculateChallengeCompletion(challenge, newProgress);

      await userChallengeDoc.reference.update({
        'progress': newProgress,
        'completionPercentage': completionPercentage,
      });

      // Check if challenge is completed
      if (completionPercentage >= 100.0) {
        await _completeChallenge(userId, challengeId, challenge);
      }
    } catch (e) {
      throw Exception('Failed to update challenge progress: $e');
    }
  }

  Future<void> _completeChallenge(String userId, String challengeId, ChallengeModel challenge) async {
    try {
      // Update challenge status
      final challengeSnapshot = await _firestore
          .collection('user_challenges')
          .where('userId', isEqualTo: userId)
          .where('challengeId', isEqualTo: challengeId)
          .where('status', isEqualTo: ChallengeStatus.active.name)
          .get();

      if (challengeSnapshot.docs.isNotEmpty) {
        await challengeSnapshot.docs.first.reference.update({
          'status': ChallengeStatus.completed.name,
          'completedAt': FieldValue.serverTimestamp(),
          'completionPercentage': 100.0,
        });

        // Award rewards
        for (final reward in challenge.rewards) {
          await _grantReward(userId, reward, 'Challenge: ${challenge.name}');
        }
      }
    } catch (e) {
      print('Failed to complete challenge: $e');
    }
  }

  double _calculateChallengeCompletion(ChallengeModel challenge, Map<String, dynamic> progress) {
    final requirements = challenge.requirements;
    if (requirements.isEmpty) return 0.0;

    double totalCompletion = 0.0;
    int totalRequirements = 0;

    for (final entry in requirements.entries) {
      final required = entry.value as int? ?? 0;
      final current = progress[entry.key] as int? ?? 0;
      
      if (required > 0) {
        totalCompletion += (current / required).clamp(0.0, 1.0);
        totalRequirements++;
      }
    }

    return totalRequirements > 0 ? (totalCompletion / totalRequirements) * 100 : 0.0;
  }

  // Achievement Management
  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final snapshot = await _firestore
          .collection('achievements')
          .orderBy('tier')
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => AchievementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get achievements: $e');
    }
  }

  Future<List<UserAchievementModel>> getUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_achievements')
          .where('userId', isEqualTo: userId)
          .orderBy('unlockedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserAchievementModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user achievements: $e');
    }
  }

  Future<void> checkAndUnlockAchievements(String userId, Map<String, dynamic> userStats) async {
    try {
      final achievements = await getAllAchievements();
      final userAchievements = await getUserAchievements(userId);
      final unlockedAchievementIds = userAchievements.map((ua) => ua.achievementId).toSet();

      for (final achievement in achievements) {
        if (unlockedAchievementIds.contains(achievement.id)) {
          continue; // Already unlocked
        }

        // Check prerequisites
        bool prerequisitesMet = true;
        for (final prerequisiteId in achievement.prerequisites) {
          if (!unlockedAchievementIds.contains(prerequisiteId)) {
            prerequisitesMet = false;
            break;
          }
        }

        if (!prerequisitesMet) continue;

        // Check unlock criteria
        if (_checkAchievementCriteria(achievement.unlockCriteria, userStats)) {
          await _unlockAchievement(userId, achievement.id);
        }
      }
    } catch (e) {
      print('Failed to check achievements: $e');
    }
  }

  bool _checkAchievementCriteria(Map<String, dynamic> criteria, Map<String, dynamic> userStats) {
    for (final entry in criteria.entries) {
      final required = entry.value as int? ?? 0;
      final current = userStats[entry.key] as int? ?? 0;
      
      if (current < required) {
        return false;
      }
    }
    return true;
  }

  Future<void> _unlockAchievement(String userId, String achievementId) async {
    try {
      final userAchievement = UserAchievementModel(
        id: '',
        userId: userId,
        achievementId: achievementId,
        unlockedAt: DateTime.now(),
        progress: 100.0,
        isCompleted: true,
      );

      await _firestore.collection('user_achievements').add(userAchievement.toFirestore());

      // Get achievement details for reward
      final achievementDoc = await _firestore.collection('achievements').doc(achievementId).get();
      if (achievementDoc.exists) {
        final achievement = AchievementModel.fromFirestore(achievementDoc);
        await _grantReward(userId, achievement.reward, 'Achievement: ${achievement.name}');
      }
    } catch (e) {
      throw Exception('Failed to unlock achievement: $e');
    }
  }

  // Leaderboard Management
  Future<List<LeaderboardEntryModel>> getLeaderboard({
    String? category,
    String? timeframe, // 'daily', 'weekly', 'monthly', 'all-time'
    int limit = 100,
  }) async {
    try {
      Query query = _firestore.collection('leaderboard_entries');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (timeframe != null) {
        query = query.where('timeframe', isEqualTo: timeframe);
      }

      final snapshot = await query
          .orderBy('totalPoints', descending: true)
          .orderBy('lastUpdate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => LeaderboardEntryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get leaderboard: $e');
    }
  }

  Future<void> updateLeaderboard(String userId) async {
    try {
      final userStats = await _getUserGamificationStats(userId);
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) return;
      
      final user = UserModel.fromFirestore(userDoc);
      final userBadges = await getUserBadges(userId);
      
      final leaderboardEntry = LeaderboardEntryModel(
        userId: userId,
        displayName: user.displayName,
        userRole: user.userRole,
        totalPoints: userStats['totalPoints'] ?? 0,
        rank: 0, // Will be calculated later
        stats: userStats,
        featuredBadges: userBadges.take(3).map((b) => b.badgeId).toList(),
        lastUpdate: DateTime.now(),
      );

      await _firestore
          .collection('leaderboard_entries')
          .doc(userId)
          .set(leaderboardEntry.toFirestore());

      // Update ranks (this should be done in a cloud function for efficiency)
      await _updateLeaderboardRanks();
    } catch (e) {
      throw Exception('Failed to update leaderboard: $e');
    }
  }

  Future<void> _updateLeaderboardRanks() async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard_entries')
          .orderBy('totalPoints', descending: true)
          .get();

      final batch = _firestore.batch();
      
      for (int i = 0; i < snapshot.docs.length; i++) {
        batch.update(snapshot.docs[i].reference, {'rank': i + 1});
      }

      await batch.commit();
    } catch (e) {
      print('Failed to update leaderboard ranks: $e');
    }
  }

  // Streak Management
  Future<List<StreakModel>> getUserStreaks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_streaks')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => StreakModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user streaks: $e');
    }
  }

  Future<void> updateStreak(String userId, String streakType) async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final streakSnapshot = await _firestore
          .collection('user_streaks')
          .where('userId', isEqualTo: userId)
          .where('streakType', isEqualTo: streakType)
          .get();

      if (streakSnapshot.docs.isEmpty) {
        // Create new streak
        final newStreak = StreakModel(
          userId: userId,
          streakType: streakType,
          currentStreak: 1,
          longestStreak: 1,
          lastActionDate: today,
          streakStartDate: today,
        );

        await _firestore.collection('user_streaks').add(newStreak.toFirestore());
      } else {
        // Update existing streak
        final streakDoc = streakSnapshot.docs.first;
        final streak = StreakModel.fromFirestore(streakDoc);

        final daysSinceLastAction = todayStart.difference(
          DateTime(streak.lastActionDate.year, streak.lastActionDate.month, streak.lastActionDate.day)
        ).inDays;

        int newCurrentStreak;
        DateTime newStreakStartDate;

        if (daysSinceLastAction == 0) {
          // Same day, no change
          return;
        } else if (daysSinceLastAction == 1) {
          // Consecutive day, increment streak
          newCurrentStreak = streak.currentStreak + 1;
          newStreakStartDate = streak.streakStartDate;
        } else {
          // Streak broken, restart
          newCurrentStreak = 1;
          newStreakStartDate = today;
        }

        final newLongestStreak = math.max(streak.longestStreak, newCurrentStreak);

        await streakDoc.reference.update({
          'currentStreak': newCurrentStreak,
          'longestStreak': newLongestStreak,
          'lastActionDate': Timestamp.fromDate(today),
          'streakStartDate': Timestamp.fromDate(newStreakStartDate),
        });

        // Award streak rewards
        await _checkStreakRewards(userId, streakType, newCurrentStreak);
      }
    } catch (e) {
      throw Exception('Failed to update streak: $e');
    }
  }

  Future<void> _checkStreakRewards(String userId, String streakType, int streakCount) async {
    // Award rewards for milestone streaks
    final milestones = [7, 14, 30, 60, 100, 365];
    
    if (milestones.contains(streakCount)) {
      final points = _getStreakRewardPoints(streakCount);
      await _addUserPoints(userId, points, '$streakType streak: $streakCount days');

      // Check for streak badges
      await _checkStreakBadges(userId, streakType, streakCount);
    }
  }

  int _getStreakRewardPoints(int streakCount) {
    switch (streakCount) {
      case 7: return 50;
      case 14: return 100;
      case 30: return 250;
      case 60: return 500;
      case 100: return 1000;
      case 365: return 5000;
      default: return 0;
    }
  }

  Future<void> _checkStreakBadges(String userId, String streakType, int streakCount) async {
    // This would check for specific streak badges based on type and count
    // Implementation depends on your badge system design
  }

  // Reward System
  Future<void> _grantReward(String userId, RewardModel reward, String reason) async {
    try {
      switch (reward.type) {
        case RewardType.coins:
          await _addUserPoints(userId, reward.amount, reason);
          break;
        case RewardType.badge:
          if (reward.itemId != null) {
            await awardBadge(userId, reward.itemId!);
          }
          break;
        case RewardType.premium_access:
          await _grantPremiumAccess(userId, reward.amount, reason);
          break;
        // Add other reward types as needed
        default:
          break;
      }
    } catch (e) {
      print('Failed to grant reward: $e');
    }
  }

  Future<void> _addUserPoints(String userId, int points, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(points),
      });

      // Record transaction
      await _firestore.collection('coin_transactions').add({
        'userId': userId,
        'amount': points,
        'type': 'earned',
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to add user points: $e');
    }
  }

  Future<void> _grantPremiumAccess(String userId, int days, String reason) async {
    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: days));

      await _firestore.collection('premium_access').add({
        'userId': userId,
        'startDate': Timestamp.fromDate(now),
        'endDate': Timestamp.fromDate(endDate),
        'reason': reason,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to grant premium access: $e');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> _getUserGamificationStats(String userId) async {
    try {
      // This would aggregate user statistics from various collections
      final badges = await getUserBadges(userId);
      final achievements = await getUserAchievements(userId);
      final challenges = await getUserChallenges(userId);
      
      final completedChallenges = challenges.where((c) => c.status == ChallengeStatus.completed).length;
      
      return {
        'totalPoints': 0, // Would be calculated from user's coins and other sources
        'badgeCount': badges.length,
        'achievementCount': achievements.length,
        'challengesCompleted': completedChallenges,
        'lastUpdate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {};
    }
  }

  // Daily/Weekly Challenge Generation
  Future<void> generateDailyChallenges() async {
    // This would be called by a scheduled function to generate daily challenges
    try {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      final challengeTemplates = [
        {
          'name': 'Daily Quiz Master',
          'description': 'Complete 3 quizzes with 80% or higher score',
          'requirements': {'quizzes_completed': 3, 'min_score': 80},
          'rewards': [
            {'type': 'coins', 'amount': 50, 'description': '50 coins'}
          ],
        },
        {
          'name': 'Study Streak Keeper',
          'description': 'Maintain your daily study streak',
          'requirements': {'daily_login': 1},
          'rewards': [
            {'type': 'coins', 'amount': 25, 'description': '25 coins'}
          ],
        },
        // Add more challenge templates
      ];

      for (final template in challengeTemplates) {
        final challenge = ChallengeModel(
          id: '',
          name: template['name'] as String,
          description: template['description'] as String,
          type: ChallengeType.daily,
          requirements: template['requirements'] as Map<String, dynamic>,
          rewards: (template['rewards'] as List<dynamic>)
              .map((r) => RewardModel.fromMap(r as Map<String, dynamic>))
              .toList(),
          startDate: today,
          endDate: tomorrow,
          targetRoles: ['doctor', 'pharmacist', 'farmer'],
        );

        await _firestore.collection('challenges').add(challenge.toFirestore());
      }
    } catch (e) {
      print('Failed to generate daily challenges: $e');
    }
  }
}