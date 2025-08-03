import 'package:flutter/foundation.dart';
import '../services/coin_service.dart';

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
}