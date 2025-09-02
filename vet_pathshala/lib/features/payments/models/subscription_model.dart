import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int duration; // days
  final List<String> features;
  final String category; // 'notes', 'quiz', 'premium', 'drug_center', 'lecture', 'ebooks', 'gamification'
  final List<String> featureIds; // Individual feature access
  final bool isPopular;
  final String? discountText;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;
  final List<String> targetRoles; // 'doctor', 'pharmacist', 'farmer'
  final int maxDevices; // Maximum concurrent devices allowed

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.duration,
    required this.features,
    required this.category,
    this.featureIds = const [],
    this.isPopular = false,
    this.discountText,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.metadata = const {},
    this.targetRoles = const [],
    this.maxDevices = 1,
  });

  factory SubscriptionPlan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionPlan(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'INR',
      duration: data['duration'] ?? 30,
      features: List<String>.from(data['features'] ?? []),
      category: data['category'] ?? '',
      featureIds: List<String>.from(data['featureIds'] ?? []),
      isPopular: data['isPopular'] ?? false,
      discountText: data['discountText'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] ?? {},
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
      maxDevices: data['maxDevices'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'duration': duration,
      'features': features,
      'category': category,
      'featureIds': featureIds,
      'isPopular': isPopular,
      'discountText': discountText,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'metadata': metadata,
      'targetRoles': targetRoles,
      'maxDevices': maxDevices,
    };
  }

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
  final List<String> featureIds; // Individual features included
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'expired', 'cancelled', 'suspended'
  final String paymentId;
  final double amount;
  final DateTime createdAt;
  final DateTime? lastAccessDate;
  final String? currentDeviceId;
  final int activeDeviceCount;
  final Map<String, dynamic> deviceSessions; // Track device sessions
  final bool autoRenew;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.category,
    this.featureIds = const [],
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.paymentId,
    required this.amount,
    required this.createdAt,
    this.lastAccessDate,
    this.currentDeviceId,
    this.activeDeviceCount = 0,
    this.deviceSessions = const {},
    this.autoRenew = true,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory UserSubscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSubscription(
      id: doc.id,
      userId: data['userId'] ?? '',
      planId: data['planId'] ?? '',
      category: data['category'] ?? '',
      featureIds: List<String>.from(data['featureIds'] ?? []),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
      paymentId: data['paymentId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastAccessDate: (data['lastAccessDate'] as Timestamp?)?.toDate(),
      currentDeviceId: data['currentDeviceId'],
      activeDeviceCount: data['activeDeviceCount'] ?? 0,
      deviceSessions: data['deviceSessions'] ?? {},
      autoRenew: data['autoRenew'] ?? true,
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      cancellationReason: data['cancellationReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'planId': planId,
      'category': category,
      'featureIds': featureIds,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'paymentId': paymentId,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastAccessDate': lastAccessDate != null ? Timestamp.fromDate(lastAccessDate!) : null,
      'currentDeviceId': currentDeviceId,
      'activeDeviceCount': activeDeviceCount,
      'deviceSessions': deviceSessions,
      'autoRenew': autoRenew,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancellationReason': cancellationReason,
    };
  }

  bool get isActive => status == 'active' && DateTime.now().isBefore(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining > 0;
  bool get hasFeatureAccess => featureIds.isNotEmpty || category == 'premium';
  
  bool canAccessFeature(String featureId) {
    if (status != 'active' || DateTime.now().isAfter(endDate)) return false;
    return category == 'premium' || featureIds.contains(featureId);
  }
}

// Feature access model for individual feature subscriptions
class FeatureSubscription {
  final String id;
  final String featureId;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int duration; // days
  final bool isActive;
  final DateTime createdAt;
  final List<String> targetRoles;

  FeatureSubscription({
    required this.id,
    required this.featureId,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.duration,
    this.isActive = true,
    required this.createdAt,
    this.targetRoles = const [],
  });

  factory FeatureSubscription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeatureSubscription(
      id: doc.id,
      featureId: data['featureId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'INR',
      duration: data['duration'] ?? 30,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'featureId': featureId,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'duration': duration,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetRoles': targetRoles,
    };
  }
}

// Device session tracking
class DeviceSession {
  final String id;
  final String userId;
  final String deviceId;
  final String deviceInfo;
  final DateTime loginTime;
  final DateTime? lastActiveTime;
  final String ipAddress;
  final bool isActive;

  DeviceSession({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceInfo,
    required this.loginTime,
    this.lastActiveTime,
    required this.ipAddress,
    this.isActive = true,
  });

  factory DeviceSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceSession(
      id: doc.id,
      userId: data['userId'] ?? '',
      deviceId: data['deviceId'] ?? '',
      deviceInfo: data['deviceInfo'] ?? '',
      loginTime: (data['loginTime'] as Timestamp).toDate(),
      lastActiveTime: (data['lastActiveTime'] as Timestamp?)?.toDate(),
      ipAddress: data['ipAddress'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'deviceInfo': deviceInfo,
      'loginTime': Timestamp.fromDate(loginTime),
      'lastActiveTime': lastActiveTime != null ? Timestamp.fromDate(lastActiveTime!) : null,
      'ipAddress': ipAddress,
      'isActive': isActive,
    };
  }

  Duration get sessionDuration {
    final endTime = lastActiveTime ?? DateTime.now();
    return endTime.difference(loginTime);
  }
}