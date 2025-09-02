import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/providers/home_provider.dart';
import 'features/question_bank/providers/question_provider.dart';
import 'features/drug_center/providers/drug_provider.dart';
import 'features/coins/providers/coin_provider.dart';
import 'features/notes/providers/notes_provider.dart';
import 'features/pyp/providers/pyp_provider.dart';
import 'features/test_series/providers/test_series_provider.dart';
import 'features/gamification/providers/gamification_provider.dart';
import 'shared/providers/category_provider.dart';
import 'features/admin/providers/admin_auth_provider.dart';
import 'core/utils/firebase_availability.dart';
import 'core/routing/app_router.dart';
import 'app_wrapper_with_admin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure font fallbacks for better emoji support
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  
  bool firebaseInitialized = false;
  try {
    // Initialize Firebase with timeout
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 15));
    firebaseInitialized = true;
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('🔴 Firebase initialization failed: $e');
    print('🟡 App will continue with limited functionality');
    // Continue without Firebase - the app should show appropriate error messages
  }
  
  // Set a global flag so auth services can check if Firebase is available
  FirebaseAvailability.isAvailable = firebaseInitialized;
  
  runApp(const VetPathshalaApp());
}

class VetPathshalaApp extends StatelessWidget {
  const VetPathshalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => QuestionProvider()),
        ChangeNotifierProvider(create: (_) => DrugProvider()),
        ChangeNotifierProvider(create: (_) => CoinProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => PYPProvider()),
        ChangeNotifierProvider(create: (_) => TestSeriesProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
      ],
      child: MaterialApp(
        title: 'Vet-Pathshala',
        theme: AppTheme.lightTheme.copyWith(
          // Add font fallbacks for better emoji and special character support
          textTheme: AppTheme.lightTheme.textTheme.apply(
            fontFamily: 'Inter',
            fontFamilyFallback: const [
              'Noto Color Emoji',
              'Noto Emoji',
              'Apple Color Emoji',
              'Segoe UI Emoji',
              'Segoe UI Symbol',
              'Android Emoji',
            ],
          ),
        ),
        home: const AppWrapperWithAdminCheck(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
