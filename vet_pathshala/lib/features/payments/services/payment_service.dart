import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription_model.dart';
import '../models/payment_model.dart';

class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  // Subscription plans
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

  // Purchase subscription using Razorpay
  Future<bool> purchaseSubscription({
    required String planId,
    required String userId,
    required Map<String, dynamic> userDetails,
  }) async {
    try {
      final plan = _subscriptionPlans[planId];
      if (plan == null) {
        throw Exception('Subscription plan not found');
      }

      _isProcessing = true;
      _currentPaymentId = _generatePaymentId();
      notifyListeners();

      var options = {
        'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
        'amount': plan.price * 100, // Amount in paise
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

  // Purchase coins using Razorpay
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
        'amount': package.price * 100, // Amount in paise
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

      debugPrint('✅ Payment successful: ${response.paymentId}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error handling payment success: $e');
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

  // Get user's active subscriptions
  Future<List<UserSubscription>> getUserSubscriptions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_subscriptions')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs
          .map((doc) => UserSubscription.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting user subscriptions: $e');
      return [];
    }
  }

  // Check if user has active subscription for category
  Future<bool> hasActiveSubscription(String userId, String category) async {
    try {
      final subscriptions = await getUserSubscriptions(userId);
      return subscriptions.any((sub) => 
          sub.category == category || sub.category == 'premium');
    } catch (e) {
      debugPrint('❌ Error checking subscription: $e');
      return false;
    }
  }

  // Get available subscription plans
  Map<String, SubscriptionPlan> get subscriptionPlans => _subscriptionPlans;
  
  // Get available coin packages
  Map<String, CoinPackage> get coinPackages => _coinPackages;

  String _generatePaymentId() {
    return 'order_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}

enum PaymentStatus { none, processing, success, failed }