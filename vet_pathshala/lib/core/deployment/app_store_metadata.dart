/// App Store metadata and configuration for deployment
class AppStoreMetadata {
  /// App Store listing information
  static const AppStoreListing listing = AppStoreListing(
    appName: 'Vet Pathshala',
    shortDescription: 'Complete veterinary education platform for doctors, pharmacists, and farmers',
    fullDescription: '''
Vet Pathshala is a comprehensive educational platform designed specifically for veterinary professionals including doctors, pharmacists, and farmers. Our app provides cutting-edge learning tools, interactive content, and practical resources to enhance veterinary knowledge and skills.

🎓 KEY FEATURES:

FOR VETERINARY DOCTORS:
• Comprehensive video lectures from industry experts
• Interactive quiz bank with detailed explanations
• Drug calculator and interaction checker
• Latest research papers and clinical guides
• Continuing education credits tracking

FOR VETERINARY PHARMACISTS:
• Extensive drug database with dosage calculations
• Drug interaction analysis tools
• Prescription validation features
• Inventory management guidance
• Regulatory compliance updates

FOR FARMERS:
• Animal health management tools
• Breeding and reproduction tracking
• Milk production analytics
• QR code-based animal identification
• Veterinary consultation scheduling

📚 LEARNING RESOURCES:
• High-quality video lectures in multiple languages
• Comprehensive e-book library
• Interactive quiz system with adaptive learning
• Short notes and AI-powered summaries
• Progress tracking and performance analytics

🎮 GAMIFICATION:
• Achievement system with badges and rewards
• Leaderboards and competitive learning
• Daily challenges and streak bonuses
• Coin-based premium content access
• Social learning communities

💎 PREMIUM FEATURES:
• Advanced drug calculator
• Offline content download
• Ad-free learning experience
• Exclusive masterclass content
• Priority customer support

🌐 ACCESSIBILITY:
• Multi-language support (English, Hindi, Spanish)
• Offline learning capabilities
• Responsive design for all devices
• Voice-over and text-to-speech support
• High-contrast mode for better visibility

Whether you're a veterinary student, practicing professional, or livestock farmer, Vet Pathshala provides the tools and knowledge you need to excel in animal care and veterinary science.

Download now and join thousands of veterinary professionals advancing their careers with Vet Pathshala!
    ''',
    keywords: [
      'veterinary education',
      'animal health',
      'veterinary medicine',
      'livestock management',
      'veterinary pharmacy',
      'animal care',
      'veterinary training',
      'agriculture education',
      'veterinary science',
      'animal husbandry',
    ],
    category: AppCategory.education,
    contentRating: ContentRating.everyone,
    privacyPolicyUrl: 'https://vetpathshala.com/privacy-policy',
    termsOfServiceUrl: 'https://vetpathshala.com/terms-of-service',
    supportUrl: 'https://vetpathshala.com/support',
    websiteUrl: 'https://vetpathshala.com',
  );

  /// Screenshots and visual assets
  static const VisualAssets visualAssets = VisualAssets(
    appIcon: 'assets/icons/app_icon.png',
    featureGraphic: 'assets/store/feature_graphic.png',
    screenshots: ScreenshotSet(
      phone: [
        'assets/store/screenshots/phone_1_home.png',
        'assets/store/screenshots/phone_2_videos.png',
        'assets/store/screenshots/phone_3_quiz.png',
        'assets/store/screenshots/phone_4_notes.png',
        'assets/store/screenshots/phone_5_profile.png',
      ],
      tablet: [
        'assets/store/screenshots/tablet_1_home.png',
        'assets/store/screenshots/tablet_2_videos.png',
        'assets/store/screenshots/tablet_3_quiz.png',
      ],
    ),
    promoVideo: 'https://vetpathshala.com/promo-video.mp4',
  );

  /// What's new in this version
  static const String releaseNotes = '''
🎉 Welcome to Vet Pathshala v1.0.0!

✨ NEW FEATURES:
• Complete video lecture system with HD streaming
• Interactive quiz bank with 1000+ questions
• Comprehensive e-book library
• Advanced drug calculator and interaction checker
• Farmer animal management tools
• QR code-based animal identification
• Gamification system with achievements and rewards

🔧 CORE FUNCTIONALITY:
• Multi-role support (Doctors, Pharmacists, Farmers)
• Offline learning capabilities
• Multi-language support
• Performance optimizations
• Enhanced security features

🎯 PREMIUM FEATURES:
• Coin-based content access system
• Exclusive masterclass content
• Advanced analytics and progress tracking
• Priority customer support

📱 USER EXPERIENCE:
• Modern Material Design 3 interface
• Smooth animations and transitions
• Accessibility improvements
• Dark mode support (coming soon)

This is our initial release with foundational features. We're continuously working to improve your learning experience. Stay tuned for regular updates!

Have feedback? Contact us at support@vetpathshala.com
  ''';

  /// App Store optimization
  static const AppStoreOptimization aso = AppStoreOptimization(
    primaryKeywords: [
      'veterinary education',
      'animal health',
      'veterinary medicine',
    ],
    secondaryKeywords: [
      'livestock management',
      'veterinary pharmacy',
      'animal care',
      'veterinary training',
    ],
    competitorApps: [
      'VetPocket',
      'VIN Mobile',
      'Merck Veterinary Manual',
      'VetCalc',
    ],
    targetAudience: TargetAudience(
      primary: 'Veterinary professionals',
      secondary: 'Veterinary students',
      tertiary: 'Livestock farmers',
      demographics: {
        'age': '22-55',
        'profession': 'Veterinary, Agriculture',
        'education': 'College, Graduate',
        'interests': 'Animal health, Education, Technology',
      },
    ),
  );

  /// Localization information
  static const Map<String, LocalizedMetadata> localizations = {
    'en': LocalizedMetadata(
      appName: 'Vet Pathshala',
      shortDescription: 'Complete veterinary education platform',
      keywords: 'veterinary, education, animal, health, medicine',
    ),
    'hi': LocalizedMetadata(
      appName: 'वेट पाठशाला',
      shortDescription: 'संपूर्ण पशु चिकित्सा शिक्षा मंच',
      keywords: 'पशु चिकित्सा, शिक्षा, पशु, स्वास्थ्य, दवा',
    ),
    'es': LocalizedMetadata(
      appName: 'Vet Pathshala',
      shortDescription: 'Plataforma educativa veterinaria completa',
      keywords: 'veterinaria, educación, animal, salud, medicina',
    ),
  };

  /// Rating and review guidelines
  static const ReviewGuidelines reviewGuidelines = ReviewGuidelines(
    encouragePositiveReviews: true,
    reviewPromptTriggers: [
      'course_completed',
      'quiz_perfect_score',
      'seven_day_streak',
      'feature_usage_milestone',
    ],
    reviewPromptDelay: Duration(days: 3),
    minimumUsageBeforePrompt: Duration(hours: 2),
  );

  /// App Store submission checklist
  static const List<String> submissionChecklist = [
    '✅ App icon in all required sizes (1024x1024, 512x512, etc.)',
    '✅ Screenshots for all device types (phone, tablet)',
    '✅ Feature graphic (1024x500)',
    '✅ App description with keywords',
    '✅ Privacy policy URL',
    '✅ Terms of service URL',
    '✅ Age rating questionnaire completed',
    '✅ Content rating appropriate',
    '✅ All required permissions justified',
    '✅ No placeholder content or lorem ipsum',
    '✅ All links working and accessible',
    '✅ App tested on multiple devices',
    '✅ Crash-free experience',
    '✅ Performance optimizations applied',
    '✅ Security measures implemented',
    '✅ Accessibility features enabled',
    '✅ Offline functionality working',
    '✅ Error handling comprehensive',
    '✅ User data protection compliant',
    '✅ Firebase configuration updated',
    '✅ Analytics tracking enabled',
    '✅ Crashlytics integrated',
    '✅ Release notes prepared',
    '✅ Beta testing completed',
    '✅ Team members granted access',
  ];

  /// Store-specific configurations
  static const StoreConfigurations storeConfigs = StoreConfigurations(
    googlePlay: GooglePlayConfig(
      developerName: 'Vet Pathshala Team',
      contactEmail: 'developer@vetpathshala.com',
      contactPhone: '+1-555-VET-PATH',
      contentRating: 'Everyone',
      targetSdkVersion: 34,
      permissions: [
        'INTERNET',
        'ACCESS_NETWORK_STATE',
        'CAMERA',
        'READ_EXTERNAL_STORAGE',
        'WRITE_EXTERNAL_STORAGE',
        'RECORD_AUDIO',
        'ACCESS_FINE_LOCATION',
        'ACCESS_COARSE_LOCATION',
      ],
      dataTypes: [
        'Personal info',
        'App activity',
        'App info and performance',
        'Device identifiers',
      ],
    ),
    appleAppStore: AppleAppStoreConfig(
      developerName: 'Vet Pathshala Inc.',
      contactEmail: 'support@vetpathshala.com',
      contentRating: '4+',
      capabilities: [
        'Camera',
        'Location Services',
        'Push Notifications',
        'Background App Refresh',
        'In-App Purchase',
      ],
      privacyTypes: [
        'Contact Info',
        'User Content',
        'Usage Data',
        'Diagnostics',
        'Identifiers',
      ],
    ),
  );
}

/// App store listing information
class AppStoreListing {
  final String appName;
  final String shortDescription;
  final String fullDescription;
  final List<String> keywords;
  final AppCategory category;
  final ContentRating contentRating;
  final String privacyPolicyUrl;
  final String termsOfServiceUrl;
  final String supportUrl;
  final String websiteUrl;

  const AppStoreListing({
    required this.appName,
    required this.shortDescription,
    required this.fullDescription,
    required this.keywords,
    required this.category,
    required this.contentRating,
    required this.privacyPolicyUrl,
    required this.termsOfServiceUrl,
    required this.supportUrl,
    required this.websiteUrl,
  });
}

/// Visual assets for app stores
class VisualAssets {
  final String appIcon;
  final String featureGraphic;
  final ScreenshotSet screenshots;
  final String? promoVideo;

  const VisualAssets({
    required this.appIcon,
    required this.featureGraphic,
    required this.screenshots,
    this.promoVideo,
  });
}

/// Screenshot sets for different device types
class ScreenshotSet {
  final List<String> phone;
  final List<String> tablet;

  const ScreenshotSet({
    required this.phone,
    required this.tablet,
  });
}

/// App Store Optimization data
class AppStoreOptimization {
  final List<String> primaryKeywords;
  final List<String> secondaryKeywords;
  final List<String> competitorApps;
  final TargetAudience targetAudience;

  const AppStoreOptimization({
    required this.primaryKeywords,
    required this.secondaryKeywords,
    required this.competitorApps,
    required this.targetAudience,
  });
}

/// Target audience information
class TargetAudience {
  final String primary;
  final String secondary;
  final String tertiary;
  final Map<String, String> demographics;

  const TargetAudience({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.demographics,
  });
}

/// Localized metadata
class LocalizedMetadata {
  final String appName;
  final String shortDescription;
  final String keywords;

  const LocalizedMetadata({
    required this.appName,
    required this.shortDescription,
    required this.keywords,
  });
}

/// Review guidelines and prompts
class ReviewGuidelines {
  final bool encouragePositiveReviews;
  final List<String> reviewPromptTriggers;
  final Duration reviewPromptDelay;
  final Duration minimumUsageBeforePrompt;

  const ReviewGuidelines({
    required this.encouragePositiveReviews,
    required this.reviewPromptTriggers,
    required this.reviewPromptDelay,
    required this.minimumUsageBeforePrompt,
  });
}

/// Store-specific configurations
class StoreConfigurations {
  final GooglePlayConfig googlePlay;
  final AppleAppStoreConfig appleAppStore;

  const StoreConfigurations({
    required this.googlePlay,
    required this.appleAppStore,
  });
}

/// Google Play Store configuration
class GooglePlayConfig {
  final String developerName;
  final String contactEmail;
  final String contactPhone;
  final String contentRating;
  final int targetSdkVersion;
  final List<String> permissions;
  final List<String> dataTypes;

  const GooglePlayConfig({
    required this.developerName,
    required this.contactEmail,
    required this.contactPhone,
    required this.contentRating,
    required this.targetSdkVersion,
    required this.permissions,
    required this.dataTypes,
  });
}

/// Apple App Store configuration
class AppleAppStoreConfig {
  final String developerName;
  final String contactEmail;
  final String contentRating;
  final List<String> capabilities;
  final List<String> privacyTypes;

  const AppleAppStoreConfig({
    required this.developerName,
    required this.contactEmail,
    required this.contentRating,
    required this.capabilities,
    required this.privacyTypes,
  });
}

/// App categories
enum AppCategory {
  education,
  medical,
  productivity,
  business,
  lifestyle,
}

/// Content ratings
enum ContentRating {
  everyone,
  teen,
  mature,
  adult,
}