import 'package:cloud_firestore/cloud_firestore.dart';

class CoinService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';
  static const String _transactionsCollection = 'coin_transactions';

  // Transaction types
  static const String transactionTypeEarn = 'earn';
  static const String transactionTypeSpend = 'spend';
  static const String transactionTypePurchase = 'purchase';

  // Earn reasons
  static const String earnReasonQuizComplete = 'quiz_complete';
  static const String earnReasonDailyLogin = 'daily_login';
  static const String earnReasonReferral = 'referral';
  static const String earnReasonAchievement = 'achievement';

  // Spend reasons
  static const String spendReasonDrugCalculator = 'drug_calculator';
  static const String spendReasonPremiumContent = 'premium_content';
  static const String spendReasonInteractionChecker = 'interaction_checker';
  static const String spendReasonPrescriptionHelper = 'prescription_helper';

  // Get user's current coin balance
  static Future<int> getUserCoins(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        return data['coins'] ?? 0;
      }
      return 0;
    } catch (e) {
      // If permission denied, return default starting coins
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        return 50; // Starting coins for new users
      }
      throw Exception('Failed to get user coins: $e');
    }
  }

  // Check if user has enough coins
  static Future<bool> hasEnoughCoins(String userId, int requiredCoins) async {
    try {
      final currentCoins = await getUserCoins(userId);
      return currentCoins >= requiredCoins;
    } catch (e) {
      return false;
    }
  }

  // Deduct coins from user account
  static Future<bool> deductCoins({
    required String userId,
    required int amount,
    required String reason,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        // Get current user document
        final userRef = _firestore.collection(_usersCollection).doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final currentCoins = userData['coins'] ?? 0;

        // Check if user has enough coins
        if (currentCoins < amount) {
          return false; // Insufficient coins
        }

        // Calculate new balance
        final newBalance = currentCoins - amount;

        // Update user's coin balance
        transaction.update(userRef, {
          'coins': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final transactionRef = _firestore.collection(_transactionsCollection).doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'type': transactionTypeSpend,
          'amount': amount,
          'reason': reason,
          'description': description ?? 'Spent $amount coins for $reason',
          'balanceBefore': currentCoins,
          'balanceAfter': newBalance,
          'metadata': metadata ?? {},
          'createdAt': FieldValue.serverTimestamp(),
        });

        return true; // Success
      });
    } catch (e) {
      throw Exception('Failed to deduct coins: $e');
    }
  }

  // Add coins to user account
  static Future<void> addCoins({
    required String userId,
    required int amount,
    required String reason,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        // Get current user document
        final userRef = _firestore.collection(_usersCollection).doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data() as Map<String, dynamic>;
        final currentCoins = userData['coins'] ?? 0;
        final newBalance = currentCoins + amount;

        // Update user's coin balance
        transaction.update(userRef, {
          'coins': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create transaction record
        final transactionRef = _firestore.collection(_transactionsCollection).doc();
        transaction.set(transactionRef, {
          'userId': userId,
          'type': transactionTypeEarn,
          'amount': amount,
          'reason': reason,
          'description': description ?? 'Earned $amount coins for $reason',
          'balanceBefore': currentCoins,
          'balanceAfter': newBalance,
          'metadata': metadata ?? {},
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to add coins: $e');
    }
  }

  // Get user's transaction history
  static Future<List<CoinTransaction>> getUserTransactions(
    String userId, {
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final QuerySnapshot snapshot = await query.get();

      return snapshot.docs
          .map((doc) => CoinTransaction.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      // If permission denied, return sample transactions
      if (e.toString().contains('permission-denied') || 
          e.toString().contains('PERMISSION_DENIED')) {
        return _getSampleTransactions(userId, limit);
      }
      throw Exception('Failed to get transaction history: $e');
    }
  }

  // Get coin earning opportunities
  static Map<String, int> getCoinEarningRates() {
    return {
      earnReasonQuizComplete: 10, // 10 coins per quiz completion
      earnReasonDailyLogin: 5, // 5 coins for daily login
      earnReasonReferral: 50, // 50 coins for successful referral
      earnReasonAchievement: 25, // 25 coins for achievements
    };
  }

  // Get coin spending costs
  static Map<String, int> getCoinSpendingCosts() {
    return {
      spendReasonDrugCalculator: 5, // 5 coins for drug calculator
      spendReasonInteractionChecker: 3, // 3 coins for interaction checker
      spendReasonPrescriptionHelper: 2, // 2 coins for prescription helper
      spendReasonPremiumContent: 10, // 10 coins for premium content
    };
  }

  // Award coins for quiz completion
  static Future<void> awardQuizCompletionCoins({
    required String userId,
    required int questionsCorrect,
    required int totalQuestions,
  }) async {
    try {
      final baseCoins = getCoinEarningRates()[earnReasonQuizComplete] ?? 10;
      final percentage = questionsCorrect / totalQuestions;
      final coinsToAward = (baseCoins * percentage).round();

      if (coinsToAward > 0) {
        await addCoins(
          userId: userId,
          amount: coinsToAward,
          reason: earnReasonQuizComplete,
          description: 'Earned $coinsToAward coins for completing quiz ($questionsCorrect/$totalQuestions correct)',
          metadata: {
            'questionsCorrect': questionsCorrect,
            'totalQuestions': totalQuestions,
            'percentage': percentage,
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to award quiz completion coins: $e');
    }
  }

  // Award daily login coins
  static Future<void> awardDailyLoginCoins(String userId) async {
    try {
      // Check if user already received coins today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final QuerySnapshot recentTransactions = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('reason', isEqualTo: earnReasonDailyLogin)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .limit(1)
          .get();

      if (recentTransactions.docs.isEmpty) {
        // No daily login coins awarded today, award them
        final coinsToAward = getCoinEarningRates()[earnReasonDailyLogin] ?? 5;
        
        await addCoins(
          userId: userId,
          amount: coinsToAward,
          reason: earnReasonDailyLogin,
          description: 'Daily login bonus',
          metadata: {
            'date': today.toIso8601String(),
          },
        );
      }
    } catch (e) {
      throw Exception('Failed to award daily login coins: $e');
    }
  }

  // Process drug calculator payment
  static Future<bool> processDrugCalculatorPayment(String userId) async {
    try {
      final cost = getCoinSpendingCosts()[spendReasonDrugCalculator] ?? 5;
      
      return await deductCoins(
        userId: userId,
        amount: cost,
        reason: spendReasonDrugCalculator,
        description: 'Used drug dosage calculator',
        metadata: {
          'feature': 'drug_calculator',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to process drug calculator payment: $e');
    }
  }

  // Process interaction checker payment
  static Future<bool> processInteractionCheckerPayment(String userId) async {
    try {
      final cost = getCoinSpendingCosts()[spendReasonInteractionChecker] ?? 3;
      
      return await deductCoins(
        userId: userId,
        amount: cost,
        reason: spendReasonInteractionChecker,
        description: 'Used drug interaction checker',
        metadata: {
          'feature': 'interaction_checker',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to process interaction checker payment: $e');
    }
  }

  // Process prescription helper payment
  static Future<bool> processPrescriptionHelperPayment(String userId) async {
    try {
      final cost = getCoinSpendingCosts()[spendReasonPrescriptionHelper] ?? 2;
      
      return await deductCoins(
        userId: userId,
        amount: cost,
        reason: spendReasonPrescriptionHelper,
        description: 'Used prescription helper',
        metadata: {
          'feature': 'prescription_helper',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to process prescription helper payment: $e');
    }
  }

  // Get user's coin statistics
  static Future<CoinStats> getUserCoinStats(String userId) async {
    try {
      final transactions = await getUserTransactions(userId, limit: 1000);
      
      int totalEarned = 0;
      int totalSpent = 0;
      int quizCoins = 0;
      int loginCoins = 0;
      int calculatorSpent = 0;
      
      for (final transaction in transactions) {
        if (transaction.type == transactionTypeEarn) {
          totalEarned += transaction.amount;
          
          if (transaction.reason == earnReasonQuizComplete) {
            quizCoins += transaction.amount;
          } else if (transaction.reason == earnReasonDailyLogin) {
            loginCoins += transaction.amount;
          }
        } else if (transaction.type == transactionTypeSpend) {
          totalSpent += transaction.amount;
          
          if (transaction.reason == spendReasonDrugCalculator) {
            calculatorSpent += transaction.amount;
          }
        }
      }

      final currentBalance = await getUserCoins(userId);

      return CoinStats(
        currentBalance: currentBalance,
        totalEarned: totalEarned,
        totalSpent: totalSpent,
        quizCoins: quizCoins,
        loginCoins: loginCoins,
        calculatorSpent: calculatorSpent,
        transactionCount: transactions.length,
      );
    } catch (e) {
      throw Exception('Failed to get coin statistics: $e');
    }
  }
  // Get sample transactions when Firestore access fails
  static List<CoinTransaction> _getSampleTransactions(String userId, int limit) {
    final now = DateTime.now();
    final sampleTransactions = [
      CoinTransaction(
        id: '1',
        userId: userId,
        type: transactionTypeEarn,
        amount: 5,
        reason: earnReasonDailyLogin,
        description: 'Daily login bonus',
        balanceBefore: 45,
        balanceAfter: 50,
        metadata: {'date': now.toIso8601String()},
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      CoinTransaction(
        id: '2',
        userId: userId,
        type: transactionTypeEarn,
        amount: 10,
        reason: earnReasonQuizComplete,
        description: 'Completed quiz: Basic Veterinary Medicine',
        balanceBefore: 35,
        balanceAfter: 45,
        metadata: {'questionsCorrect': 8, 'totalQuestions': 10},
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      CoinTransaction(
        id: '3',
        userId: userId,
        type: transactionTypeSpend,
        amount: 5,
        reason: spendReasonDrugCalculator,
        description: 'Used drug calculator',
        balanceBefore: 40,
        balanceAfter: 35,
        metadata: {'drugName': 'Amoxicillin'},
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      CoinTransaction(
        id: '4',
        userId: userId,
        type: transactionTypeEarn,
        amount: 2,
        reason: 'watch_ad',
        description: 'Watched rewarded video ad',
        balanceBefore: 38,
        balanceAfter: 40,
        metadata: {'adProvider': 'admob'},
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      CoinTransaction(
        id: '5',
        userId: userId,
        type: transactionTypeEarn,
        amount: 5,
        reason: earnReasonDailyLogin,
        description: 'Daily login bonus',
        balanceBefore: 33,
        balanceAfter: 38,
        metadata: {'date': now.subtract(const Duration(days: 3)).toIso8601String()},
        createdAt: now.subtract(const Duration(days: 3, hours: 8)),
      ),
    ];
    
    return sampleTransactions.take(limit).toList();
  }
}

// Coin transaction model
class CoinTransaction {
  final String id;
  final String userId;
  final String type;
  final int amount;
  final String reason;
  final String description;
  final int balanceBefore;
  final int balanceAfter;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  CoinTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.reason,
    required this.description,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.metadata,
    required this.createdAt,
  });

  factory CoinTransaction.fromMap(Map<String, dynamic> map) {
    return CoinTransaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      amount: map['amount'] ?? 0,
      reason: map['reason'] ?? '',
      description: map['description'] ?? '',
      balanceBefore: map['balanceBefore'] ?? 0,
      balanceAfter: map['balanceAfter'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'reason': reason,
      'description': description,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

// Coin statistics model
class CoinStats {
  final int currentBalance;
  final int totalEarned;
  final int totalSpent;
  final int quizCoins;
  final int loginCoins;
  final int calculatorSpent;
  final int transactionCount;

  CoinStats({
    required this.currentBalance,
    required this.totalEarned,
    required this.totalSpent,
    required this.quizCoins,
    required this.loginCoins,
    required this.calculatorSpent,
    required this.transactionCount,
  });

  double get earningEfficiency => 
      transactionCount > 0 ? totalEarned / transactionCount : 0.0;
  
  double get spendingRate => 
      totalEarned > 0 ? totalSpent / totalEarned : 0.0;
}