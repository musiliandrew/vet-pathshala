import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_model.dart';
import '../models/payment_model.dart';
import 'dynamic_subscription_service.dart';

class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DynamicSubscriptionService _subscriptionService = DynamicSubscriptionService();
  late Razorpay _razorpay;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Payment states
  bool _isProcessing = false;
  String? _currentPaymentId;
  PaymentStatus _lastPaymentStatus = PaymentStatus.none;

  // In-App Purchase products
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  // Getters
  bool get isProcessing => _isProcessing;
  String? get currentPaymentId => _currentPaymentId;
  PaymentStatus get lastPaymentStatus => _lastPaymentStatus;
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  // Legacy subscription plans (kept for backward compatibility)
  final Map<String, SubscriptionPlan> _subscriptionPlans = {
    'notes_monthly': SubscriptionPlan(
      id: 'notes_monthly',
      name: 'Notes Access - Monthly',
      description: 'Access to all veterinary notes and summaries',
      price: 199,
      currency: 'INR',
      duration: 30,
      features: ['All Notes', 'AI Summaries', 'Offline Access'],
      category: 'notes',
      createdAt: DateTime.now(),
    ),
    'quiz_monthly': SubscriptionPlan(
      id: 'quiz_monthly',
      name: 'Quiz & PYQ - Monthly',
      description: 'Access to quizzes and previous year questions',
      price: 299,
      currency: 'INR',
      duration: 30,
      features: ['All Quizzes', 'Previous Year Papers', 'Detailed Analysis'],
      category: 'quiz',
      createdAt: DateTime.now(),
    ),
    'premium_monthly': SubscriptionPlan(
      id: 'premium_monthly',
      name: 'Premium - Monthly',
      description: 'Complete access to all features',
      price: 499,
      currency: 'INR',
      duration: 30,
      features: ['All Features', 'Priority Support', 'Ad-Free Experience', 'Unlimited Coins'],
      category: 'premium',
      createdAt: DateTime.now(),
    ),
    'premium_yearly': SubscriptionPlan(
      id: 'premium_yearly',
      name: 'Premium - Yearly',
      description: 'Complete access to all features (Save 40%)',
      price: 2999,
      currency: 'INR',
      duration: 365,
      features: ['All Features', 'Priority Support', 'Ad-Free Experience', 'Unlimited Coins'],
      category: 'premium',
      isPopular: true,
      createdAt: DateTime.now(),
    ),
  };

  // Coin packages
  final Map<String, CoinPackage> _coinPackages = {
    'coins_100': CoinPackage(
      id: 'coins_100',
      name: '100 Drug Coins',
      description: 'Perfect for trying premium features',
      coins: 100,
      price: 99,
      currency: 'INR',
    ),
    'coins_500': CoinPackage(
      id: 'coins_500',
      name: '500 Drug Coins',
      description: 'Great value for regular users',
      coins: 500,
      price: 399,
      currency: 'INR',
      bonusCoins: 50,
      isPopular: true,
    ),
    'coins_1000': CoinPackage(
      id: 'coins_1000',
      name: '1000 Drug Coins',
      description: 'Best value with bonus coins',
      coins: 1000,
      price: 699,
      currency: 'INR',
      bonusCoins: 200,
    ),
  };

  Future<void> initialize() async {
    try {
      // Initialize Razorpay
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      // Initialize In-App Purchases
      _isAvailable = await _inAppPurchase.isAvailable();
      if (_isAvailable) {
        await _loadProducts();
      }

      debugPrint('✅ Payment service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing payment service: $e');
    }
  }

  Future<void> _loadProducts() async {
    try {
      const productIds = {
        'notes_monthly',
        'quiz_monthly', 
        'premium_monthly',
        'premium_yearly',
        'coins_100',
        'coins_500',
        'coins_1000',
      };

      final response = await _inAppPurchase.queryProductDetails(productIds);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('⚠️ Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading products: $e');
    }
  }

  // Purchase subscription using Razorpay with dynamic plans
  Future<bool> purchaseSubscription({
    required String planId,
    required String userId,
    required Map<String, dynamic> userDetails,
    String? deviceId,
  }) async {
    try {
      // Check device limit before payment
      if (deviceId != null) {
        final canLogin = await _subscriptionService.canLoginFromDevice(userId, deviceId);
        if (!canLogin) {
          throw Exception('Device limit exceeded. Please logout from another device.');
        }
      }

      // Get plan from dynamic service
      final plans = _subscriptionService.plans;
      final plan = plans.firstWhere((p) => p.id == planId);

      _isProcessing = true;
      _currentPaymentId = _generatePaymentId();
      notifyListeners();

      var options = {
        'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
        'amount': (plan.price * 100).round(), // Amount in paise
        'name': 'Vet-Pathshala',
        'description': plan.description,
        'order_id': _currentPaymentId,
        'prefill': {
          'contact': userDetails['phone'] ?? '',
          'email': userDetails['email'] ?? '',
        },
        'theme': {
          'color': '#4CAF50',
        },
        'method': {
          'netbanking': true,
          'card': true,
          'wallet': true,
          'upi': true,
        },
        'notes': {
          'planId': planId,
          'userId': userId,
          'deviceId': deviceId ?? '',
        },
      };

      _razorpay.open(options);
      return true;
    } catch (e) {
      _isProcessing = false;
      _lastPaymentStatus = PaymentStatus.failed;
      notifyListeners();
      debugPrint('❌ Error initiating payment: $e');
      return false;
    }
  }

  // Purchase individual feature subscription
  Future<bool> purchaseFeatureSubscription({
    required String featureId,
    required String userId,
    required Map<String, dynamic> userDetails,
    String? deviceId,
  }) async {
    try {
      final featureSub = _subscriptionService.getFeatureSubscription(featureId);
      if (featureSub == null) {
        throw Exception('Feature subscription not found');
      }

      _isProcessing = true;
      _currentPaymentId = _generatePaymentId();
      notifyListeners();

      var options = {
        'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
        'amount': (featureSub.price * 100).round(), // Amount in paise
        'name': 'Vet-Pathshala',
        'description': featureSub.description,
        'order_id': _currentPaymentId,
        'prefill': {
          'contact': userDetails['phone'] ?? '',
          'email': userDetails['email'] ?? '',
        },
        'theme': {
          'color': '#4CAF50',
        },
        'notes': {
          'featureId': featureId,
          'userId': userId,
          'type': 'feature_subscription',
        },
      };

      _razorpay.open(options);
      return true;
    } catch (e) {
      _isProcessing = false;
      _lastPaymentStatus = PaymentStatus.failed;
      notifyListeners();
      debugPrint('❌ Error initiating feature purchase: $e');
      return false;
    }
  }

  // Purchase coins using Razorpay (kept for backward compatibility)
  Future<bool> purchaseCoins({
    required String packageId,
    required String userId,
    required Map<String, dynamic> userDetails,
  }) async {
    try {
      final package = _coinPackages[packageId];
      if (package == null) {
        throw Exception('Coin package not found');
      }

      _isProcessing = true;
      _currentPaymentId = _generatePaymentId();
      notifyListeners();

      var options = {
        'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
        'amount': (package.price * 100).round(), // Amount in paise
        'name': 'Vet-Pathshala',
        'description': package.description,
        'order_id': _currentPaymentId,
        'prefill': {
          'contact': userDetails['phone'] ?? '',
          'email': userDetails['email'] ?? '',
        },
        'theme': {
          'color': '#4CAF50',
        },
        'notes': {
          'packageId': packageId,
          'userId': userId,
          'type': 'coin_package',
        },
      };

      _razorpay.open(options);
      return true;
    } catch (e) {
      _isProcessing = false;
      _lastPaymentStatus = PaymentStatus.failed;
      notifyListeners();
      debugPrint('❌ Error initiating coin purchase: $e');
      return false;
    }
  }

  // Purchase using In-App Purchase (for app stores)
  Future<bool> purchaseProduct(ProductDetails product, String userId) async {
    try {
      _isProcessing = true;
      notifyListeners();

      final purchaseParam = PurchaseParam(productDetails: product);
      final success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      
      return success;
    } catch (e) {
      _isProcessing = false;
      _lastPaymentStatus = PaymentStatus.failed;
      notifyListeners();
      debugPrint('❌ Error with in-app purchase: $e');
      return false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      _isProcessing = false;
      _lastPaymentStatus = PaymentStatus.success;
      
      // Record payment in Firestore
      await _recordPayment(
        paymentId: response.paymentId!,
        orderId: response.orderId!,
        signature: response.signature!,
        status: 'success',
      );

      // Create user subscription based on payment notes
      await _processSuccessfulPayment(response);

      debugPrint('✅ Payment successful: ${response.paymentId}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error handling payment success: $e');
    }
  }

  Future<void> _processSuccessfulPayment(PaymentSuccessResponse response) async {
    try {
      // Get payment details from Razorpay
      final paymentDoc = await _firestore
          .collection('payments')
          .doc(response.paymentId!)
          .get();

      if (!paymentDoc.exists) return;

      final paymentData = paymentDoc.data()!;
      final notes = paymentData['notes'] ?? {};
      final userId = notes['userId'];
      final planId = notes['planId'];
      final featureId = notes['featureId'];
      final deviceId = notes['deviceId'];
      final type = notes['type'] ?? 'subscription';

      if (type == 'feature_subscription' && featureId != null) {
        // Create individual feature subscription
        await _createFeatureUserSubscription(
          userId: userId,
          featureId: featureId,
          paymentId: response.paymentId!,
          deviceId: deviceId,
        );
      } else if (planId != null) {
        // Create full subscription
        await _subscriptionService.createUserSubscription(
          userId: userId,
          planId: planId,
          paymentId: response.paymentId!,
          amount: paymentData['amount'] / 100, // Convert from paise
          deviceId: deviceId,
        );

        // Create device session if provided
        if (deviceId != null && deviceId.isNotEmpty) {
          await _subscriptionService.createDeviceSession(
            userId: userId,
            deviceId: deviceId,
            deviceInfo: 'Mobile Device', // You can get actual device info
            ipAddress: '0.0.0.0', // You can get actual IP
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error processing successful payment: $e');
    }
  }

  Future<void> _createFeatureUserSubscription({
    required String userId,
    required String featureId,
    required String paymentId,
    String? deviceId,
  }) async {
    try {
      final featureSub = _subscriptionService.getFeatureSubscription(featureId);
      if (featureSub == null) return;

      final now = DateTime.now();
      final endDate = now.add(Duration(days: featureSub.duration));

      final userSub = UserSubscription(
        id: '',
        userId: userId,
        planId: featureSub.id,
        category: featureSub.featureId,
        featureIds: [featureSub.featureId],
        startDate: now,
        endDate: endDate,
        status: 'active',
        paymentId: paymentId,
        amount: featureSub.price,
        createdAt: now,
        currentDeviceId: deviceId,
        activeDeviceCount: deviceId != null ? 1 : 0,
      );

      await _firestore.collection('user_subscriptions').add(userSub.toFirestore());
      debugPrint('✅ Created feature subscription for: $featureId');
    } catch (e) {
      debugPrint('❌ Error creating feature subscription: $e');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _isProcessing = false;
    _lastPaymentStatus = PaymentStatus.failed;
    
    debugPrint('❌ Payment failed: ${response.code} - ${response.message}');
    notifyListeners();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('🔄 External wallet selected: ${response.walletName}');
  }

  Future<void> _recordPayment({
    required String paymentId,
    required String orderId,
    required String signature,
    required String status,
  }) async {
    try {
      // Get the order details from Razorpay to include notes
      await _firestore.collection('payments').doc(paymentId).set({
        'paymentId': paymentId,
        'orderId': orderId,
        'signature': signature,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'platform': 'razorpay',
      });
    } catch (e) {
      debugPrint('❌ Error recording payment: $e');
    }
  }

  // Get user's active subscriptions (delegated to dynamic service)
  Future<List<UserSubscription>> getUserSubscriptions(String userId) async {
    await _subscriptionService.loadUserSubscriptions(userId);
    return _subscriptionService.getActiveSubscriptions();
  }

  // Check if user has active subscription for category (delegated to dynamic service)
  Future<bool> hasActiveSubscription(String userId, String category, {String? featureId}) async {
    await _subscriptionService.initializeForUser(userId);
    return _subscriptionService.hasActiveSubscription(category, featureId: featureId);
  }

  // Get available subscription plans from dynamic service
  List<SubscriptionPlan> get subscriptionPlans => _subscriptionService.plans;
  
  // Get available coin packages (kept for backward compatibility)
  Map<String, CoinPackage> get coinPackages => _coinPackages;
  
  // Get feature subscriptions
  List<FeatureSubscription> get featureSubscriptions => _subscriptionService.featureSubscriptions;
  
  // Initialize payment service with user
  Future<void> initializeForUser(String userId) async {
    await _subscriptionService.initializeForUser(userId);
  }

  String _generatePaymentId() {
    return 'order_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Device session management methods
  Future<bool> canLoginFromDevice(String userId, String deviceId) async {
    return await _subscriptionService.canLoginFromDevice(userId, deviceId);
  }

  Future<void> createDeviceSession({
    required String userId,
    required String deviceId,
    required String deviceInfo,
    required String ipAddress,
  }) async {
    await _subscriptionService.createDeviceSession(
      userId: userId,
      deviceId: deviceId,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
    );
  }

  Future<void> endDeviceSession(String userId, String deviceId) async {
    await _subscriptionService.endDeviceSession(userId, deviceId);
  }

  Future<void> updateDeviceActivity(String userId, String deviceId) async {
    await _subscriptionService.updateDeviceActivity(userId, deviceId);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}

enum PaymentStatus { none, processing, success, failed }