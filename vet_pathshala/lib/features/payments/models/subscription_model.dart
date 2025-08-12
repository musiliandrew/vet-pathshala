import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int duration; // days
  final List<String> features;
  final String category; // 'notes', 'quiz', 'premium'
  final bool isPopular;
  final String? discountText;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.duration,
    required this.features,
    required this.category,
    this.isPopular = false,
    this.discountText,
  });

  String get durationText {
    if (duration == 30) return 'Monthly';
    if (duration == 365) return 'Yearly';
    return '$duration days';
  }

  double get dailyPrice => price / duration;
}

class CoinPackage {
  final String id;
  final String name;
  final String description;
  final int coins;
  final double price;
  final String currency;
  final int bonusCoins;
  final bool isPopular;

  CoinPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.coins,
    required this.price,
    required this.currency,
    this.bonusCoins = 0,
    this.isPopular = false,
  });

  int get totalCoins => coins + bonusCoins;
  double get coinsPerRupee => totalCoins / price;
}

class UserSubscription {
  final String id;
  final String userId;
  final String planId;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'expired', 'cancelled'
  final String paymentId;
  final double amount;
  final DateTime createdAt;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentId,
    required this.amount,
    required this.createdAt,
  });

  factory UserSubscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSubscription(
      id: doc.id,
      userId: data['userId'] ?? '',
      planId: data['planId'] ?? '',
      category: data['category'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
      paymentId: data['paymentId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId,
      'category': category,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'paymentId': paymentId,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}