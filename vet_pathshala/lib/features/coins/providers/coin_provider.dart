import 'package:flutter/foundation.dart';
import '../services/coin_service.dart';
import '../../../shared/services/phase2_integration_service.dart';
import '../../../shared/models/ebook_models.dart';
import '../../../shared/models/video_models.dart';
import '../../../shared/models/gamification_models.dart';

class CoinProvider with ChangeNotifier {
  // State variables
  int _currentBalance = 0;
  List<CoinTransaction> _transactions = [];
  CoinStats? _stats;
  bool _isLoading = false;
  String? _error;
  bool _hasClaimedDailyBonus = false;
  DateTime? _lastDailyBonusCheck;

  // Getters
  int get currentBalance => _currentBalance;
  List<CoinTransaction> get transactions => _transactions;
  CoinStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasClaimedDailyBonus => _hasClaimedDailyBonus;

  // Initialize provider for a user
  Future<void> initialize(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await loadUserCoins(userId);
      await loadTransactions(userId);
      await loadStats(userId);
      await checkDailyBonusStatus(userId);

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user's current coin balance
  Future<void> loadUserCoins(String userId) async {
    try {
      _currentBalance = await CoinService.getUserCoins(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load transaction history
  Future<void> loadTransactions(String userId, {bool refresh = false}) async {
    try {
      if (refresh) {
        _transactions.clear();
      }

      final newTransactions = await CoinService.getUserTransactions(
        userId,
        limit: 20,
      );

      if (refresh) {
        _transactions = newTransactions;
      } else {
        _transactions.addAll(newTransactions);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load coin statistics
  Future<void> loadStats(String userId) async {
    try {
      _stats = await CoinService.getUserCoinStats(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check if user has claimed daily bonus today
  Future<void> checkDailyBonusStatus(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Check if we already checked today
      if (_lastDailyBonusCheck != null) {
        final lastCheck = DateTime(
          _lastDailyBonusCheck!.year,
          _lastDailyBonusCheck!.month,
          _lastDailyBonusCheck!.day,
        );
        
        if (lastCheck == today) {
          return; // Already checked today
        }
      }

      // Check recent transactions for daily bonus
      final recentTransactions = await CoinService.getUserTransactions(
        userId,
        limit: 10,
      );

      _hasClaimedDailyBonus = recentTransactions.any((transaction) {
        final transactionDate = DateTime(
          transaction.createdAt.year,
          transaction.createdAt.month,
          transaction.createdAt.day,
        );
        
        return transactionDate == today && 
               transaction.reason == CoinService.earnReasonDailyLogin;
      });

      _lastDailyBonusCheck = now;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error checking daily bonus status: $e');
      }
    }
  }

  // Claim daily login bonus
  Future<bool> claimDailyBonus(String userId) async {
    try {
      if (_hasClaimedDailyBonus) {
        return false; // Already claimed today
      }

      await CoinService.awardDailyLoginCoins(userId);
      
      // Update local state
      final dailyBonusAmount = CoinService.getCoinEarningRates()[CoinService.earnReasonDailyLogin] ?? 5;
      _currentBalance += dailyBonusAmount;
      _hasClaimedDailyBonus = true;

      // Add transaction to local list
      final transaction = CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: CoinService.transactionTypeEarn,
        amount: dailyBonusAmount,
        reason: CoinService.earnReasonDailyLogin,
        description: 'Daily login bonus',
        balanceBefore: _currentBalance - dailyBonusAmount,
        balanceAfter: _currentBalance,
        metadata: {'date': DateTime.now().toIso8601String()},
        createdAt: DateTime.now(),
      );
      
      _transactions.insert(0, transaction);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Award quiz completion coins
  Future<void> awardQuizCompletionCoins({
    required String userId,
    required int questionsCorrect,
    required int totalQuestions,
  }) async {
    try {
      await CoinService.awardQuizCompletionCoins(
        userId: userId,
        questionsCorrect: questionsCorrect,
        totalQuestions: totalQuestions,
      );

      // Update local balance
      await loadUserCoins(userId);
      await loadTransactions(userId, refresh: true);
      
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Process premium feature payment
  Future<bool> processPayment({
    required String userId,
    required String featureType,
    required int amount,
  }) async {
    try {
      bool success = false;
      
      switch (featureType) {
        case 'drug_calculator':
          success = await CoinService.processDrugCalculatorPayment(userId);
          break;
        case 'interaction_checker':
          success = await CoinService.processInteractionCheckerPayment(userId);
          break;
        case 'prescription_helper':
          success = await CoinService.processPrescriptionHelperPayment(userId);
          break;
        default:
          success = await CoinService.deductCoins(
            userId: userId,
            amount: amount,
            reason: featureType,
            description: 'Premium feature usage',
          );
      }

      if (success) {
        // Update local balance
        _currentBalance -= amount;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if user has enough coins
  bool hasEnoughCoins(int requiredCoins) {
    return _currentBalance >= requiredCoins;
  }

  // Get coin earning rates
  Map<String, int> getCoinEarningRates() {
    return CoinService.getCoinEarningRates();
  }

  // Get coin spending costs
  Map<String, int> getCoinSpendingCosts() {
    return CoinService.getCoinSpendingCosts();
  }

  // Purchase coins (this would integrate with in-app purchases)
  Future<bool> purchaseCoins({
    required String userId,
    required int amount,
    required String packageId,
    required String transactionId,
  }) async {
    try {
      await CoinService.addCoins(
        userId: userId,
        amount: amount,
        reason: CoinService.transactionTypePurchase,
        description: 'Purchased $amount coins ($packageId)',
        metadata: {
          'packageId': packageId,
          'transactionId': transactionId,
          'purchaseDate': DateTime.now().toIso8601String(),
        },
      );

      // Update local balance
      _currentBalance += amount;
      
      // Add transaction to local list
      final transaction = CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: CoinService.transactionTypePurchase,
        amount: amount,
        reason: CoinService.transactionTypePurchase,
        description: 'Purchased $amount coins',
        balanceBefore: _currentBalance - amount,
        balanceAfter: _currentBalance,
        metadata: {
          'packageId': packageId,
          'transactionId': transactionId,
        },
        createdAt: DateTime.now(),
      );
      
      _transactions.insert(0, transaction);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Watch ad for coins (this would integrate with AdMob)
  Future<bool> watchAdForCoins(String userId) async {
    try {
      // Simulate ad watching (in real implementation, this would be called after ad completion)
      const adRewardAmount = 2; // 2 coins per ad
      
      await CoinService.addCoins(
        userId: userId,
        amount: adRewardAmount,
        reason: 'watch_ad',
        description: 'Watched rewarded video ad',
        metadata: {
          'adProvider': 'admob',
          'adType': 'rewarded_video',
          'watchedAt': DateTime.now().toIso8601String(),
        },
      );

      // Update local balance
      _currentBalance += adRewardAmount;
      
      // Add transaction to local list
      final transaction = CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: CoinService.transactionTypeEarn,
        amount: adRewardAmount,
        reason: 'watch_ad',
        description: 'Watched rewarded video ad',
        balanceBefore: _currentBalance - adRewardAmount,
        balanceAfter: _currentBalance,
        metadata: {'adProvider': 'admob'},
        createdAt: DateTime.now(),
      );
      
      _transactions.insert(0, transaction);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Refresh all data
  Future<void> refresh(String userId) async {
    await initialize(userId);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset daily bonus status (for testing)
  void resetDailyBonusForTesting() {
    _hasClaimedDailyBonus = false;
    _lastDailyBonusCheck = null;
    notifyListeners();
  }

  // Phase 2 Integration Methods

  // E-book related methods
  Future<bool> canAccessEbook(String userId, EbookModel ebook) async {
    return await Phase2IntegrationService.checkEbookAccess(userId, ebook);
  }

  Future<bool> purchaseEbookAccess(String userId, EbookModel ebook) async {
    final success = await Phase2IntegrationService.purchaseEbookAccess(userId, ebook);
    if (success) {
      await loadUserCoins(userId);
      await loadTransactions(userId, refresh: true);
    }
    return success;
  }

  Future<void> awardReadingCoins({
    required String userId,
    required String ebookId,
    required double progressIncrement,
    bool chapterCompleted = false,
    bool bookCompleted = false,
  }) async {
    await Phase2IntegrationService.awardReadingProgressCoins(
      userId: userId,
      ebookId: ebookId,
      progressIncrement: progressIncrement,
      chapterCompleted: chapterCompleted,
      bookCompleted: bookCompleted,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  // Quiz related methods
  Future<bool> canAccessQuizFeature(String userId, String featureType) async {
    return await Phase2IntegrationService.checkQuizFeatureAccess(userId, featureType);
  }

  Future<bool> purchaseQuizFeature(String userId, String featureType) async {
    final success = await Phase2IntegrationService.purchaseQuizFeatureAccess(userId, featureType);
    if (success) {
      await loadUserCoins(userId);
      await loadTransactions(userId, refresh: true);
    }
    return success;
  }

  Future<void> awardAdvancedQuizCoins({
    required String userId,
    required int questionsCorrect,
    required int totalQuestions,
    required String quizType,
    bool isPerfectScore = false,
  }) async {
    await Phase2IntegrationService.awardQuizCompletionCoins(
      userId: userId,
      questionsCorrect: questionsCorrect,
      totalQuestions: totalQuestions,
      quizType: quizType,
      isPerfectScore: isPerfectScore,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  // Social features methods
  Future<bool> canAccessSocialFeature(String userId, String featureType) async {
    return await Phase2IntegrationService.checkSocialFeatureAccess(userId, featureType);
  }

  Future<bool> purchaseSocialFeature(String userId, String featureType) async {
    final success = await Phase2IntegrationService.purchaseSocialFeatureAccess(userId, featureType);
    if (success) {
      await loadUserCoins(userId);
      await loadTransactions(userId, refresh: true);
    }
    return success;
  }

  Future<void> awardSocialCoins({
    required String userId,
    required String engagementType,
    String? targetId,
    Map<String, dynamic>? metadata,
  }) async {
    await Phase2IntegrationService.awardSocialEngagementCoins(
      userId: userId,
      engagementType: engagementType,
      targetId: targetId,
      metadata: metadata,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  // Gamification rewards
  Future<void> awardAchievementCoins(String userId, String achievementType, {Map<String, dynamic>? metadata}) async {
    await Phase2IntegrationService.awardGamificationCoins(userId, achievementType, metadata: metadata);
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  Future<void> awardLeaderboardCoins({
    required String userId,
    required int position,
    required String leaderboardType,
    required String period,
  }) async {
    await Phase2IntegrationService.awardLeaderboardCoins(
      userId: userId,
      position: position,
      leaderboardType: leaderboardType,
      period: period,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  Future<void> awardChallengeCoins({
    required String userId,
    required String challengeId,
    required String challengeType,
    Map<String, dynamic>? challengeData,
  }) async {
    await Phase2IntegrationService.awardChallengeCompletionCoins(
      userId: userId,
      challengeId: challengeId,
      challengeType: challengeType,
      challengeData: challengeData,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  Future<void> awardStreakCoins({
    required String userId,
    required int streakDays,
    required String streakType,
  }) async {
    await Phase2IntegrationService.awardStreakBonus(
      userId: userId,
      streakDays: streakDays,
      streakType: streakType,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  Future<void> awardBadgeCoins({
    required String userId,
    required BadgeModel badge,
  }) async {
    await Phase2IntegrationService.awardBadgeUnlockCoins(
      userId: userId,
      badge: badge,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  // Check affordability for any feature
  Future<bool> canAffordFeature(String userId, String featureType, String category) async {
    return await Phase2IntegrationService.canAffordFeature(userId, featureType, category);
  }

  // Get feature costs for display
  Map<String, Map<String, int>> getFeatureCosts() {
    return Phase2IntegrationService.getAllFeatureCosts();
  }

  // Get reward amounts for display
  Map<String, int> getRewardAmounts() {
    return Phase2IntegrationService.getAllRewards();
  }

  // Video-specific methods

  // Check if user can access video
  Future<bool> canAccessVideo(String userId, VideoLectureModel video) async {
    return await Phase2IntegrationService.checkVideoAccess(userId, video);
  }

  // Purchase video access with coins
  Future<bool> purchaseVideoAccess(String userId, VideoLectureModel video) async {
    final success = await Phase2IntegrationService.purchaseVideoAccess(userId, video);
    if (success) {
      await loadUserCoins(userId);
      await loadTransactions(userId, refresh: true);
    }
    return success;
  }

  // Award coins for video watching progress
  Future<void> awardVideoWatchingCoins({
    required String userId,
    required String videoId,
    required double progressIncrement,
    required String videoTitle,
    bool chapterCompleted = false,
    bool videoCompleted = false,
  }) async {
    await Phase2IntegrationService.awardVideoWatchingCoins(
      userId: userId,
      videoId: videoId,
      progressIncrement: progressIncrement,
      videoTitle: videoTitle,
      chapterCompleted: chapterCompleted,
      videoCompleted: videoCompleted,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  // Award coins for video engagement activities
  Future<void> awardVideoEngagementCoins({
    required String userId,
    required String videoId,
    required String engagementType,
    Map<String, dynamic>? metadata,
  }) async {
    await Phase2IntegrationService.awardVideoEngagementCoins(
      userId: userId,
      videoId: videoId,
      engagementType: engagementType,
      metadata: metadata,
    );
    
    await loadUserCoins(userId);
    await loadTransactions(userId, refresh: true);
  }

  // Check if user can afford a specific video
  Future<bool> canAffordVideo(String userId, VideoLectureModel video) async {
    return await Phase2IntegrationService.canAffordVideo(userId, video);
  }

  // Simple method to add coins (for farmer module features)
  void addCoins(int amount, String reason) {
    _currentBalance += amount;
    
    // Create transaction record
    final transaction = CoinTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user', // In real app, this would come from auth
      type: CoinService.transactionTypeEarn,
      amount: amount,
      reason: reason,
      description: reason,
      balanceBefore: _currentBalance - amount,
      balanceAfter: _currentBalance,
      metadata: {},
      createdAt: DateTime.now(),
    );
    
    _transactions.insert(0, transaction);
    notifyListeners();
  }

  // Simple method to deduct coins (for farmer module features)
  void deductCoins(int amount, String reason) {
    if (_currentBalance >= amount) {
      _currentBalance -= amount;
      
      // Create transaction record
      final transaction = CoinTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // In real app, this would come from auth
        type: CoinService.transactionTypeSpend,
        amount: amount,
        reason: reason,
        description: reason,
        balanceBefore: _currentBalance + amount,
        balanceAfter: _currentBalance,
        metadata: {},
        createdAt: DateTime.now(),
      );
      
      _transactions.insert(0, transaction);
      notifyListeners();
    }
  }
}