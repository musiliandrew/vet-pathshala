import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentRecord {
  final String id;
  final String userId;
  final String paymentId;
  final String orderId;
  final String type; // 'subscription', 'coins'
  final String itemId; // planId or packageId
  final double amount;
  final String currency;
  final String status; // 'pending', 'success', 'failed'
  final String platform; // 'razorpay', 'in_app_purchase'
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  PaymentRecord({
    required this.id,
    required this.userId,
    required this.paymentId,
    required this.orderId,
    required this.type,
    required this.itemId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.platform,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory PaymentRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentRecord(
      id: doc.id,
      userId: data['userId'] ?? '',
      paymentId: data['paymentId'] ?? '',
      orderId: data['orderId'] ?? '',
      type: data['type'] ?? '',
      itemId: data['itemId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'INR',
      status: data['status'] ?? 'pending',
      platform: data['platform'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'paymentId': paymentId,
      'orderId': orderId,
      'type': type,
      'itemId': itemId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'platform': platform,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'metadata': metadata,
    };
  }
}

class CoinTransaction {
  final String id;
  final String userId;
  final int amount; // positive for earn, negative for spend
  final String type; // 'purchase', 'earned', 'spent', 'bonus'
  final String reason; // 'drug_calculator', 'quiz_completion', 'purchase', etc.
  final String? referenceId; // paymentId, questionId, etc.
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  CoinTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.reason,
    this.referenceId,
    required this.createdAt,
    this.metadata,
  });

  factory CoinTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoinTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: data['amount'] ?? 0,
      type: data['type'] ?? '',
      reason: data['reason'] ?? '',
      referenceId: data['referenceId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type,
      'reason': reason,
      'referenceId': referenceId,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }

  bool get isEarned => amount > 0;
  bool get isSpent => amount < 0;
}