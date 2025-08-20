import '../models/ebook_models.dart';
import '../models/gamification_models.dart';
import '../models/video_models.dart';
import '../../features/coins/services/coin_service.dart';

/// Service to integrate all Phase 2 features with the coin/premium system
class Phase2IntegrationService {
  // E-book premium access costs
  static const Map<String, int> ebookAccessCosts = {
    'premium_ebook': 50,
    'exclusive_ebook': 100,
    'specialty_textbook': 75,
    'research_paper': 25,
    'clinical_guide': 40,
  };

  // Video lecture premium access costs
  static const Map<String, int> videoAccessCosts = {
    'basic_lecture': 20,
    'premium_lecture': 50,
    'masterclass': 100,
    'live_session': 75,
    'recorded_webinar': 30,
    'specialty_course': 80,
  };

  // Quiz premium features costs
  static const Map<String, int> quizPremiumCosts = {
    'timed_quiz_mode': 10,
    'battle_mode_entry': 15,
    'mock_exam_access': 30,
    'detailed_analytics': 20,
    'answer_explanations': 5,
  };

  // Social features costs
  static const Map<String, int> socialFeatureCosts = {
    'create_study_group': 25,
    'join_premium_group': 15,
    'private_messaging': 10,
    'content_sharing': 5,
    'mentor_access': 50,
  };

  // Gamification rewards
  static const Map<String, int> gamificationRewards = {
    'daily_login_streak_5': 10,
    'daily_login_streak_10': 25,
    'daily_login_streak_30': 100,
    'first_quiz_completion': 15,
    'perfect_quiz_score': 20,
    'study_group_participation': 5,
    'ebook_chapter_completion': 8,
    'weekly_challenge_completion': 30,
    'monthly_challenge_completion': 100,
    'leaderboard_top_10': 50,
    'leaderboard_top_3': 100,
    'leaderboard_first_place': 200,
  };

  // Check if user has access to premium e-book
  static Future<bool> checkEbookAccess(String userId, EbookModel ebook) async {
    try {
      // Free books are always accessible
      if (ebook.accessLevel == AccessLevel.free) {
        return true;
      }

      // Check user's coin balance
      final userCoins = await CoinService.getUserCoins(userId);
      final requiredCoins = ebookAccessCosts[ebook.type.name] ?? ebookAccessCosts['premium_ebook']!;

      // Check if user already purchased this ebook
      // This would check the user_ebooks collection in real implementation
      // For now, we'll check based on coin balance
      return userCoins >= requiredCoins;
    } catch (e) {
      return false;
    }
  }

  // Purchase e-book access with coins
  static Future<bool> purchaseEbookAccess(String userId, EbookModel ebook) async {
    try {
      final requiredCoins = ebookAccessCosts[ebook.type.name] ?? ebookAccessCosts['premium_ebook']!;
      
      final success = await CoinService.deductCoins(
        userId: userId,
        amount: requiredCoins,
        reason: 'ebook_purchase',
        description: 'Purchased access to "${ebook.title}"',
        metadata: {
          'ebookId': ebook.id,
          'ebookTitle': ebook.title,
          'ebookType': ebook.type.name,
        },
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  // Check access to premium quiz features
  static Future<bool> checkQuizFeatureAccess(String userId, String featureType) async {
    try {
      final userCoins = await CoinService.getUserCoins(userId);
      final requiredCoins = quizPremiumCosts[featureType] ?? 10;

      return userCoins >= requiredCoins;
    } catch (e) {
      return false;
    }
  }

  // Purchase quiz feature access
  static Future<bool> purchaseQuizFeatureAccess(String userId, String featureType) async {
    try {
      final requiredCoins = quizPremiumCosts[featureType] ?? 10;
      
      final success = await CoinService.deductCoins(
        userId: userId,
        amount: requiredCoins,
        reason: 'quiz_feature',
        description: 'Purchased quiz feature: $featureType',
        metadata: {
          'featureType': featureType,
        },
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  // Check access to social features
  static Future<bool> checkSocialFeatureAccess(String userId, String featureType) async {
    try {
      final userCoins = await CoinService.getUserCoins(userId);
      final requiredCoins = socialFeatureCosts[featureType] ?? 10;

      return userCoins >= requiredCoins;
    } catch (e) {
      return false;
    }
  }

  // Purchase social feature access
  static Future<bool> purchaseSocialFeatureAccess(String userId, String featureType) async {
    try {
      final requiredCoins = socialFeatureCosts[featureType] ?? 10;
      
      final success = await CoinService.deductCoins(
        userId: userId,
        amount: requiredCoins,
        reason: 'social_feature',
        description: 'Purchased social feature: $featureType',
        metadata: {
          'featureType': featureType,
        },
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  // Award coins for gamification achievements
  static Future<void> awardGamificationCoins(String userId, String achievementType, {Map<String, dynamic>? metadata}) async {
    try {
      final coinAmount = gamificationRewards[achievementType] ?? 5;
      
      await CoinService.addCoins(
        userId: userId,
        amount: coinAmount,
        reason: 'achievement',
        description: 'Achievement unlocked: $achievementType',
        metadata: {
          'achievementType': achievementType,
          'awardedAt': DateTime.now().toIso8601String(),
          ...?metadata,
        },
      );
    } catch (e) {
      print('Error awarding gamification coins: $e');
    }
  }

  // Award coins for quiz completion
  static Future<void> awardQuizCompletionCoins({
    required String userId,
    required int questionsCorrect,
    required int totalQuestions,
    required String quizType,
    bool isPerfectScore = false,
  }) async {
    try {
      // Base coins for completion
      int baseCoins = (questionsCorrect / totalQuestions * 10).round();
      
      // Bonus for different quiz types
      switch (quizType) {
        case 'timed_quiz':
          baseCoins += 5;
          break;
        case 'battle_mode':
          baseCoins += 10;
          break;
        case 'mock_exam':
          baseCoins += 15;
          break;
      }
      
      // Perfect score bonus
      if (isPerfectScore) {
        baseCoins += gamificationRewards['perfect_quiz_score']!;
      }
      
      await CoinService.addCoins(
        userId: userId,
        amount: baseCoins,
        reason: 'quiz_completion',
        description: 'Quiz completed: $questionsCorrect/$totalQuestions correct',
        metadata: {
          'quizType': quizType,
          'questionsCorrect': questionsCorrect,
          'totalQuestions': totalQuestions,
          'isPerfectScore': isPerfectScore,
        },
      );
    } catch (e) {
      print('Error awarding quiz completion coins: $e');
    }
  }

  // Award coins for e-book reading progress
  static Future<void> awardReadingProgressCoins({
    required String userId,
    required String ebookId,
    required double progressIncrement,
    bool chapterCompleted = false,
    bool bookCompleted = false,
  }) async {
    try {
      int coinAmount = 0;
      String description = '';
      
      if (bookCompleted) {
        coinAmount = 50; // Major reward for completing entire book
        description = 'E-book completed';
      } else if (chapterCompleted) {
        coinAmount = gamificationRewards['ebook_chapter_completion']!;
        description = 'Chapter completed';
      } else if (progressIncrement >= 0.1) { // 10% progress increment
        coinAmount = 3;
        description = 'Reading progress milestone';
      }
      
      if (coinAmount > 0) {
        await CoinService.addCoins(
          userId: userId,
          amount: coinAmount,
          reason: 'reading_progress',
          description: description,
          metadata: {
            'ebookId': ebookId,
            'progressIncrement': progressIncrement,
            'chapterCompleted': chapterCompleted,
            'bookCompleted': bookCompleted,
          },
        );
      }
    } catch (e) {
      print('Error awarding reading progress coins: $e');
    }
  }

  // Award coins for social engagement
  static Future<void> awardSocialEngagementCoins({
    required String userId,
    required String engagementType,
    String? targetId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      int coinAmount = 0;
      String description = '';
      
      switch (engagementType) {
        case 'study_group_join':
          coinAmount = 5;
          description = 'Joined study group';
          break;
        case 'content_share':
          coinAmount = 3;
          description = 'Shared content';
          break;
        case 'help_other_user':
          coinAmount = 10;
          description = 'Helped another user';
          break;
        case 'mentor_session':
          coinAmount = 20;
          description = 'Completed mentor session';
          break;
        case 'group_activity_participation':
          coinAmount = gamificationRewards['study_group_participation']!;
          description = 'Participated in group activity';
          break;
      }
      
      if (coinAmount > 0) {
        await CoinService.addCoins(
          userId: userId,
          amount: coinAmount,
          reason: 'social_engagement',
          description: description,
          metadata: {
            'engagementType': engagementType,
            'targetId': targetId,
            ...?metadata,
          },
        );
      }
    } catch (e) {
      print('Error awarding social engagement coins: $e');
    }
  }

  // Award coins for leaderboard achievements
  static Future<void> awardLeaderboardCoins({
    required String userId,
    required int position,
    required String leaderboardType,
    required String period, // 'daily', 'weekly', 'monthly'
  }) async {
    try {
      int coinAmount = 0;
      String description = '';
      
      if (position == 1) {
        coinAmount = gamificationRewards['leaderboard_first_place']!;
        description = 'Leaderboard 1st place';
      } else if (position <= 3) {
        coinAmount = gamificationRewards['leaderboard_top_3']!;
        description = 'Leaderboard top 3';
      } else if (position <= 10) {
        coinAmount = gamificationRewards['leaderboard_top_10']!;
        description = 'Leaderboard top 10';
      }
      
      // Period multiplier
      switch (period) {
        case 'weekly':
          coinAmount = (coinAmount * 1.5).round();
          break;
        case 'monthly':
          coinAmount = (coinAmount * 2).round();
          break;
      }
      
      if (coinAmount > 0) {
        await CoinService.addCoins(
          userId: userId,
          amount: coinAmount,
          reason: 'leaderboard_achievement',
          description: '$description ($period $leaderboardType)',
          metadata: {
            'position': position,
            'leaderboardType': leaderboardType,
            'period': period,
          },
        );
      }
    } catch (e) {
      print('Error awarding leaderboard coins: $e');
    }
  }

  // Award daily/weekly/monthly challenge completion coins
  static Future<void> awardChallengeCompletionCoins({
    required String userId,
    required String challengeId,
    required String challengeType, // 'daily', 'weekly', 'monthly'
    Map<String, dynamic>? challengeData,
  }) async {
    try {
      int coinAmount = 0;
      String description = '';
      
      switch (challengeType) {
        case 'daily':
          coinAmount = 15;
          description = 'Daily challenge completed';
          break;
        case 'weekly':
          coinAmount = gamificationRewards['weekly_challenge_completion']!;
          description = 'Weekly challenge completed';
          break;
        case 'monthly':
          coinAmount = gamificationRewards['monthly_challenge_completion']!;
          description = 'Monthly challenge completed';
          break;
      }
      
      await CoinService.addCoins(
        userId: userId,
        amount: coinAmount,
        reason: 'challenge_completion',
        description: description,
        metadata: {
          'challengeId': challengeId,
          'challengeType': challengeType,
          'completedAt': DateTime.now().toIso8601String(),
          ...?challengeData,
        },
      );
    } catch (e) {
      print('Error awarding challenge completion coins: $e');
    }
  }

  // Check if user can afford a feature
  static Future<bool> canAffordFeature(String userId, String featureType, String category) async {
    try {
      final userCoins = await CoinService.getUserCoins(userId);
      int requiredCoins = 0;
      
      switch (category) {
        case 'ebook':
          requiredCoins = ebookAccessCosts[featureType] ?? 50;
          break;
        case 'quiz':
          requiredCoins = quizPremiumCosts[featureType] ?? 10;
          break;
        case 'social':
          requiredCoins = socialFeatureCosts[featureType] ?? 10;
          break;
      }
      
      return userCoins >= requiredCoins;
    } catch (e) {
      return false;
    }
  }

  // Check if user has access to premium video
  static Future<bool> checkVideoAccess(String userId, VideoLectureModel video) async {
    try {
      // Free videos are always accessible
      if (video.accessLevel == VideoAccessLevel.free) {
        return true;
      }

      // Check user's coin balance
      final userCoins = await CoinService.getUserCoins(userId);
      final requiredCoins = video.coinCost > 0 
          ? video.coinCost 
          : videoAccessCosts['premium_lecture']!;

      return userCoins >= requiredCoins;
    } catch (e) {
      return false;
    }
  }

  // Purchase video access with coins
  static Future<bool> purchaseVideoAccess(String userId, VideoLectureModel video) async {
    try {
      final requiredCoins = video.coinCost > 0 
          ? video.coinCost 
          : videoAccessCosts['premium_lecture']!;
      
      final success = await CoinService.deductCoins(
        userId: userId,
        amount: requiredCoins,
        reason: 'video_access',
        description: 'Purchased access to "${video.title}"',
        metadata: {
          'videoId': video.id,
          'videoTitle': video.title,
          'videoCategory': video.category.name,
          'instructor': video.instructor,
        },
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  // Award coins for video watching milestones
  static Future<void> awardVideoWatchingCoins({
    required String userId,
    required String videoId,
    required double progressIncrement,
    required String videoTitle,
    bool chapterCompleted = false,
    bool videoCompleted = false,
  }) async {
    try {
      int coinAmount = 0;
      String description = '';
      
      if (videoCompleted) {
        coinAmount = 30; // Major reward for completing entire video
        description = 'Video completed: $videoTitle';
      } else if (chapterCompleted) {
        coinAmount = 10;
        description = 'Video chapter completed';
      } else if (progressIncrement >= 0.25) { // 25% progress increment
        coinAmount = 5;
        description = 'Video progress milestone';
      }
      
      if (coinAmount > 0) {
        await CoinService.addCoins(
          userId: userId,
          amount: coinAmount,
          reason: 'video_progress',
          description: description,
          metadata: {
            'videoId': videoId,
            'videoTitle': videoTitle,
            'progressIncrement': progressIncrement,
            'chapterCompleted': chapterCompleted,
            'videoCompleted': videoCompleted,
          },
        );
      }
    } catch (e) {
      print('Error awarding video watching coins: $e');
    }
  }

  // Award coins for video engagement (bookmarks, notes)
  static Future<void> awardVideoEngagementCoins({
    required String userId,
    required String videoId,
    required String engagementType, // 'bookmark_added', 'note_added', 'video_shared'
    Map<String, dynamic>? metadata,
  }) async {
    try {
      int coinAmount = 0;
      String description = '';
      
      switch (engagementType) {
        case 'bookmark_added':
          coinAmount = 2;
          description = 'Added video bookmark';
          break;
        case 'note_added':
          coinAmount = 3;
          description = 'Added video note';
          break;
        case 'video_shared':
          coinAmount = 5;
          description = 'Shared video';
          break;
        case 'video_downloaded':
          coinAmount = 1;
          description = 'Downloaded video for offline viewing';
          break;
      }
      
      if (coinAmount > 0) {
        await CoinService.addCoins(
          userId: userId,
          amount: coinAmount,
          reason: 'video_engagement',
          description: description,
          metadata: {
            'videoId': videoId,
            'engagementType': engagementType,
            ...?metadata,
          },
        );
      }
    } catch (e) {
      print('Error awarding video engagement coins: $e');
    }
  }

  // Check affordability for video features
  static Future<bool> canAffordVideo(String userId, VideoLectureModel video) async {
    try {
      if (video.accessLevel == VideoAccessLevel.free) {
        return true;
      }

      final userCoins = await CoinService.getUserCoins(userId);
      final requiredCoins = video.coinCost > 0 
          ? video.coinCost 
          : videoAccessCosts['premium_lecture']!;

      return userCoins >= requiredCoins;
    } catch (e) {
      return false;
    }
  }

  // Get all feature costs for display in UI
  static Map<String, Map<String, int>> getAllFeatureCosts() {
    return {
      'ebooks': ebookAccessCosts,
      'videos': videoAccessCosts,
      'quiz': quizPremiumCosts,
      'social': socialFeatureCosts,
    };
  }

  // Get all reward amounts for display in UI
  static Map<String, int> getAllRewards() {
    return gamificationRewards;
  }

  // Award streak bonus coins
  static Future<void> awardStreakBonus({
    required String userId,
    required int streakDays,
    required String streakType, // 'login', 'quiz', 'reading'
  }) async {
    try {
      int coinAmount = 0;
      String description = '';
      
      switch (streakType) {
        case 'login':
          if (streakDays == 5) {
            coinAmount = gamificationRewards['daily_login_streak_5']!;
            description = '5-day login streak bonus';
          } else if (streakDays == 10) {
            coinAmount = gamificationRewards['daily_login_streak_10']!;
            description = '10-day login streak bonus';
          } else if (streakDays == 30) {
            coinAmount = gamificationRewards['daily_login_streak_30']!;
            description = '30-day login streak bonus';
          }
          break;
        case 'quiz':
          coinAmount = streakDays * 2; // 2 coins per day in quiz streak
          description = '$streakDays-day quiz streak bonus';
          break;
        case 'reading':
          coinAmount = streakDays * 3; // 3 coins per day in reading streak
          description = '$streakDays-day reading streak bonus';
          break;
      }
      
      if (coinAmount > 0) {
        await CoinService.addCoins(
          userId: userId,
          amount: coinAmount,
          reason: 'streak_bonus',
          description: description,
          metadata: {
            'streakType': streakType,
            'streakDays': streakDays,
          },
        );
      }
    } catch (e) {
      print('Error awarding streak bonus coins: $e');
    }
  }

  // Process badge unlock rewards
  static Future<void> awardBadgeUnlockCoins({
    required String userId,
    required BadgeModel badge,
  }) async {
    try {
      int coinAmount = 0;
      
      // Award coins based on badge rarity
      switch (badge.rarity) {
        case BadgeRarity.common:
          coinAmount = 10;
          break;
        case BadgeRarity.uncommon:
          coinAmount = 25;
          break;
        case BadgeRarity.rare:
          coinAmount = 50;
          break;
        case BadgeRarity.epic:
          coinAmount = 100;
          break;
        case BadgeRarity.legendary:
          coinAmount = 200;
          break;
      }
      
      await CoinService.addCoins(
        userId: userId,
        amount: coinAmount,
        reason: 'badge_unlock',
        description: 'Badge unlocked: ${badge.name}',
        metadata: {
          'badgeId': badge.id,
          'badgeName': badge.name,
          'badgeRarity': badge.rarity.name,
          'badgeCategory': badge.category.name,
        },
      );
    } catch (e) {
      print('Error awarding badge unlock coins: $e');
    }
  }
}