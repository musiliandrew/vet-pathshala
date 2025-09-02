import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_model.dart';
import '../../auth/providers/auth_provider.dart';

class DynamicSubscriptionService extends ChangeNotifier {
  static final DynamicSubscriptionService _instance = DynamicSubscriptionService._internal();
  factory DynamicSubscriptionService() => _instance;
  DynamicSubscriptionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State management
  List<SubscriptionPlan> _plans = [];
  List<FeatureSubscription> _featureSubscriptions = [];
  List<UserSubscription> _userSubscriptions = [];
  List<DeviceSession> _deviceSessions = [];
  bool _isLoading = false;
  String? _currentUserId;

  // Getters
  List<SubscriptionPlan> get plans => _plans.where((p) => p.isActive).toList();
  List<FeatureSubscription> get featureSubscriptions => _featureSubscriptions;
  List<UserSubscription> get userSubscriptions => _userSubscriptions;
  List<DeviceSession> get deviceSessions => _deviceSessions;
  bool get isLoading => _isLoading;

  // Initialize for user
  Future<void> initializeForUser(String userId) async {
    _currentUserId = userId;
    await Future.wait([
      loadSubscriptionPlans(),
      loadFeatureSubscriptions(),
      loadUserSubscriptions(userId),
      loadUserDeviceSessions(userId),
    ]);
  }

  // ADMIN FUNCTIONS - Load and manage subscription plans

  /// Load all subscription plans from Firestore
  Future<void> loadSubscriptionPlans() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('subscription_plans')
          .orderBy('createdAt', descending: false)
          .get();

      _plans = snapshot.docs
          .map((doc) => SubscriptionPlan.fromFirestore(doc))
          .toList();

      debugPrint('✅ Loaded ${_plans.length} subscription plans');
    } catch (e) {
      debugPrint('❌ Error loading subscription plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new subscription plan (Admin only)
  Future<bool> createSubscriptionPlan({
    required String name,
    required String description,
    required double price,
    required String currency,
    required int duration,
    required List<String> features,
    required String category,
    List<String> featureIds = const [],
    bool isPopular = false,
    String? discountText,
    List<String> targetRoles = const [],
    int maxDevices = 1,
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      final plan = SubscriptionPlan(
        id: '', // Firestore will generate
        name: name,
        description: description,
        price: price,
        currency: currency,
        duration: duration,
        features: features,
        category: category,
        featureIds: featureIds,
        isPopular: isPopular,
        discountText: discountText,
        isActive: true,
        createdAt: DateTime.now(),
        targetRoles: targetRoles,
        maxDevices: maxDevices,
        metadata: metadata,
      );

      await _firestore.collection('subscription_plans').add(plan.toFirestore());
      await loadSubscriptionPlans(); // Refresh

      debugPrint('✅ Created subscription plan: $name');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating subscription plan: $e');
      return false;
    }
  }

  /// Update existing subscription plan (Admin only)
  Future<bool> updateSubscriptionPlan(String planId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      
      await _firestore
          .collection('subscription_plans')
          .doc(planId)
          .update(updates);

      await loadSubscriptionPlans(); // Refresh

      debugPrint('✅ Updated subscription plan: $planId');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating subscription plan: $e');
      return false;
    }
  }

  /// Delete/deactivate subscription plan (Admin only)
  Future<bool> deleteSubscriptionPlan(String planId) async {
    try {
      await _firestore
          .collection('subscription_plans')
          .doc(planId)
          .update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      await loadSubscriptionPlans(); // Refresh

      debugPrint('✅ Deactivated subscription plan: $planId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deactivating subscription plan: $e');
      return false;
    }
  }

  // FEATURE SUBSCRIPTION MANAGEMENT

  /// Load all feature subscriptions
  Future<void> loadFeatureSubscriptions() async {
    try {
      final snapshot = await _firestore
          .collection('feature_subscriptions')
          .where('isActive', isEqualTo: true)
          .get();

      _featureSubscriptions = snapshot.docs
          .map((doc) => FeatureSubscription.fromFirestore(doc))
          .toList();

      debugPrint('✅ Loaded ${_featureSubscriptions.length} feature subscriptions');
    } catch (e) {
      debugPrint('❌ Error loading feature subscriptions: $e');
    }
  }

  /// Create individual feature subscription
  Future<bool> createFeatureSubscription({
    required String featureId,
    required String name,
    required String description,
    required double price,
    required String currency,
    required int duration,
    List<String> targetRoles = const [],
  }) async {
    try {
      final featureSub = FeatureSubscription(
        id: '',
        featureId: featureId,
        name: name,
        description: description,
        price: price,
        currency: currency,
        duration: duration,
        createdAt: DateTime.now(),
        targetRoles: targetRoles,
      );

      await _firestore.collection('feature_subscriptions').add(featureSub.toFirestore());
      await loadFeatureSubscriptions();

      debugPrint('✅ Created feature subscription: $name');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating feature subscription: $e');
      return false;
    }
  }

  // USER SUBSCRIPTION MANAGEMENT

  /// Load user's subscriptions
  Future<void> loadUserSubscriptions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_subscriptions')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _userSubscriptions = snapshot.docs
          .map((doc) => UserSubscription.fromFirestore(doc))
          .toList();

      debugPrint('✅ Loaded ${_userSubscriptions.length} user subscriptions');
    } catch (e) {
      debugPrint('❌ Error loading user subscriptions: $e');
    }
  }

  /// Check if user has active subscription for category or feature
  bool hasActiveSubscription(String category, {String? featureId}) {
    final now = DateTime.now();
    
    return _userSubscriptions.any((sub) {
      if (sub.status != 'active' || now.isAfter(sub.endDate)) return false;
      
      // Check premium access (all features)
      if (sub.category == 'premium') return true;
      
      // Check category access
      if (sub.category == category) return true;
      
      // Check individual feature access
      if (featureId != null && sub.featureIds.contains(featureId)) return true;
      
      return false;
    });
  }

  /// Get active subscriptions
  List<UserSubscription> getActiveSubscriptions() {
    final now = DateTime.now();
    return _userSubscriptions.where((sub) => 
        sub.status == 'active' && now.isBefore(sub.endDate)
    ).toList();
  }

  /// Create user subscription after successful payment
  Future<bool> createUserSubscription({
    required String userId,
    required String planId,
    required String paymentId,
    required double amount,
    String? deviceId,
  }) async {
    try {
      final plan = _plans.firstWhere((p) => p.id == planId);
      final now = DateTime.now();
      final endDate = now.add(Duration(days: plan.duration));

      final userSub = UserSubscription(
        id: '',
        userId: userId,
        planId: planId,
        category: plan.category,
        featureIds: plan.featureIds,
        startDate: now,
        endDate: endDate,
        status: 'active',
        paymentId: paymentId,
        amount: amount,
        createdAt: now,
        currentDeviceId: deviceId,
        activeDeviceCount: deviceId != null ? 1 : 0,
      );

      await _firestore.collection('user_subscriptions').add(userSub.toFirestore());
      await loadUserSubscriptions(userId);

      debugPrint('✅ Created user subscription for plan: $planId');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating user subscription: $e');
      return false;
    }
  }

  // DEVICE SESSION MANAGEMENT

  /// Load user's device sessions
  Future<void> loadUserDeviceSessions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('device_sessions')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      _deviceSessions = snapshot.docs
          .map((doc) => DeviceSession.fromFirestore(doc))
          .toList();

      debugPrint('✅ Loaded ${_deviceSessions.length} active device sessions');
    } catch (e) {
      debugPrint('❌ Error loading device sessions: $e');
    }
  }

  /// Check if user can login from new device
  Future<bool> canLoginFromDevice(String userId, String deviceId) async {
    if (_currentUserId != userId) {
      await loadUserDeviceSessions(userId);
    }

    // Check if device already has active session
    final existingSession = _deviceSessions.firstWhere(
      (session) => session.deviceId == deviceId && session.isActive,
      orElse: () => DeviceSession(
        id: '',
        userId: '',
        deviceId: '',
        deviceInfo: '',
        loginTime: DateTime.now(),
        ipAddress: '',
        isActive: false,
      ),
    );

    if (existingSession.isActive) return true;

    // Check device limit based on active subscriptions
    final activeSubscriptions = getActiveSubscriptions();
    if (activeSubscriptions.isEmpty) return false;

    final maxDevices = activeSubscriptions
        .map((sub) => _plans.firstWhere((p) => p.id == sub.planId).maxDevices)
        .reduce((a, b) => a > b ? a : b);

    return _deviceSessions.length < maxDevices;
  }

  /// Create new device session
  Future<bool> createDeviceSession({
    required String userId,
    required String deviceId,
    required String deviceInfo,
    required String ipAddress,
  }) async {
    try {
      // End other sessions if exceeding device limit
      if (!await canLoginFromDevice(userId, deviceId)) {
        await _endOldestDeviceSession(userId);
      }

      final session = DeviceSession(
        id: '',
        userId: userId,
        deviceId: deviceId,
        deviceInfo: deviceInfo,
        loginTime: DateTime.now(),
        lastActiveTime: DateTime.now(),
        ipAddress: ipAddress,
        isActive: true,
      );

      await _firestore.collection('device_sessions').add(session.toFirestore());
      await loadUserDeviceSessions(userId);

      debugPrint('✅ Created device session for: $deviceId');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating device session: $e');
      return false;
    }
  }

  /// End oldest device session when limit exceeded
  Future<void> _endOldestDeviceSession(String userId) async {
    try {
      if (_deviceSessions.isEmpty) return;

      // Sort by login time and end the oldest session
      _deviceSessions.sort((a, b) => a.loginTime.compareTo(b.loginTime));
      final oldestSession = _deviceSessions.first;

      await _firestore
          .collection('device_sessions')
          .doc(oldestSession.id)
          .update({
        'isActive': false,
        'lastActiveTime': Timestamp.fromDate(DateTime.now()),
      });

      debugPrint('✅ Ended oldest device session: ${oldestSession.deviceId}');
    } catch (e) {
      debugPrint('❌ Error ending oldest device session: $e');
    }
  }

  /// Update device session activity
  Future<void> updateDeviceActivity(String userId, String deviceId) async {
    try {
      final snapshot = await _firestore
          .collection('device_sessions')
          .where('userId', isEqualTo: userId)
          .where('deviceId', isEqualTo: deviceId)
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'lastActiveTime': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      debugPrint('❌ Error updating device activity: $e');
    }
  }

  /// End device session (logout)
  Future<void> endDeviceSession(String userId, String deviceId) async {
    try {
      final snapshot = await _firestore
          .collection('device_sessions')
          .where('userId', isEqualTo: userId)
          .where('deviceId', isEqualTo: deviceId)
          .where('isActive', isEqualTo: true)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({
          'isActive': false,
          'lastActiveTime': Timestamp.fromDate(DateTime.now()),
        });
      }

      await loadUserDeviceSessions(userId);
      debugPrint('✅ Ended device session for: $deviceId');
    } catch (e) {
      debugPrint('❌ Error ending device session: $e');
    }
  }

  // GAMIFICATION ACCESS CONTROL

  /// Check if gamification features are accessible
  bool canAccessGamification(String userId) {
    // Gamification requires active subscription
    final activeSubscriptions = getActiveSubscriptions();
    return activeSubscriptions.isNotEmpty;
  }

  /// Check specific feature access
  bool canAccessFeature(String featureId, {String? category}) {
    return hasActiveSubscription(category ?? featureId, featureId: featureId);
  }

  // UTILITY METHODS

  /// Get subscription plans by category
  List<SubscriptionPlan> getPlansByCategory(String category) {
    return _plans.where((plan) => 
        plan.category == category && plan.isActive
    ).toList();
  }

  /// Get subscription plans for specific role
  List<SubscriptionPlan> getPlansForRole(String role) {
    return _plans.where((plan) => 
        plan.isActive && 
        (plan.targetRoles.isEmpty || plan.targetRoles.contains(role))
    ).toList();
  }

  /// Get feature pricing
  FeatureSubscription? getFeatureSubscription(String featureId) {
    try {
      return _featureSubscriptions.firstWhere((fs) => fs.featureId == featureId);
    } catch (e) {
      return null;
    }
  }

  /// Calculate subscription savings
  double calculateSavings(String planId, String comparisonPlanId) {
    try {
      final plan = _plans.firstWhere((p) => p.id == planId);
      final comparisonPlan = _plans.firstWhere((p) => p.id == comparisonPlanId);
      
      final dailyPrice = plan.dailyPrice;
      final comparisonDailyPrice = comparisonPlan.dailyPrice;
      
      return ((comparisonDailyPrice - dailyPrice) / comparisonDailyPrice) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  /// Reset all state
  void reset() {
    _currentUserId = null;
    _plans.clear();
    _featureSubscriptions.clear();
    _userSubscriptions.clear();
    _deviceSessions.clear();
    _isLoading = false;
    notifyListeners();
  }
}