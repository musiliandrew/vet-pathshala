import 'package:flutter/material.dart';

class UnifiedTheme {
  // Consistent Color Palette (Quiet Green Theme)
  static const Color primaryGreen = Color(0xFF4B5E4A);
  static const Color lightGreen = Color(0xFF6B7A69);
  static const Color darkGreen = Color(0xFF4B5E4A);
  static const Color greenAccent = Color(0xFF4B5E4A);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFF1C2526);
  static const Color lightBackground = Color(0xFF1C2526);
  static const Color cardBackground = Color(0xFF1C2526);
  static const Color surfaceColor = Color(0xFF1C2526);
  
  // Text Colors
  static const Color primaryText = Color(0xFFD4D4D4);
  static const Color secondaryText = Color(0x99D4D4D4);
  static const Color tertiaryText = Color(0x66D4D4D4);
  
  // Accent Colors
  static const Color goldAccent = Color(0xFFFBBF24);
  static const Color redAccent = Color(0xFFEF4444);
  static const Color blueAccent = Color(0xFF3B82F6);
  
  // Border Colors
  static const Color borderColor = Color(0xFF4B5E4A);
  static const Color lightBorder = Color(0xFF6B7A69);
  
  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundColor, lightBackground],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
  );
  
  // Typography
  static const TextStyle headerLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: primaryText,
    height: 1.2,
  );
  
  static const TextStyle headerMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: primaryText,
  );
  
  static const TextStyle headerSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: primaryText,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: secondaryText,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: tertiaryText,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusRound = 25.0;
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Card Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusM),
    border: Border.all(color: borderColor),
    boxShadow: cardShadow,
  );
  
  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: elevatedShadow,
  );
  
  // Button Styles
  static BoxDecoration primaryButtonDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radiusS),
    boxShadow: cardShadow,
  );
  
  static BoxDecoration secondaryButtonDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(radiusS),
    border: Border.all(color: borderColor),
  );
  
  // Input Styles
  static InputDecoration searchInputDecoration = InputDecoration(
    hintText: 'Search...',
    hintStyle: bodyMedium,
    prefixIcon: const Icon(Icons.search, color: tertiaryText),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusRound),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusRound),
      borderSide: const BorderSide(color: primaryGreen),
    ),
    filled: true,
    fillColor: cardBackground,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
  
  // Icon Styles
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;
  
  // Avatar Styles
  static BoxDecoration avatarDecoration = BoxDecoration(
    color: goldAccent,
    borderRadius: BorderRadius.circular(25),
  );
  
  // Notification Badge
  static BoxDecoration notificationBadge = BoxDecoration(
    color: primaryText,
    borderRadius: BorderRadius.circular(20),
  );
  
  static BoxDecoration notificationDot = BoxDecoration(
    color: redAccent,
    borderRadius: BorderRadius.circular(9),
  );
  
  // Category Chip Styles
  static BoxDecoration selectedChipDecoration = BoxDecoration(
    color: greenAccent,
    borderRadius: BorderRadius.circular(radiusXL),
    border: Border.all(color: primaryGreen),
  );
  
  static BoxDecoration unselectedChipDecoration = BoxDecoration(
    color: lightBorder,
    borderRadius: BorderRadius.circular(radiusXL),
  );
  
  // Feature Card Styles
  static BoxDecoration featureCardDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radiusL),
    boxShadow: cardShadow,
  );
  
  // Common Widget Builders
  static Widget buildGradientContainer({
    required Widget child,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(spacingXXL),
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
  
  static Widget buildCard({
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool elevated = false,
  }) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(spacingL),
      decoration: elevated ? elevatedCardDecoration : cardDecoration,
      child: child,
    );
  }
  
  static Widget buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    EdgeInsets? padding,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(vertical: spacingM, horizontal: spacingL),
        decoration: primaryButtonDecoration,
        child: Text(
          text,
          style: buttonText,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
  
  static Widget buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    EdgeInsets? padding,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(vertical: spacingM, horizontal: spacingL),
        decoration: secondaryButtonDecoration,
        child: Text(
          text,
          style: bodyLarge.copyWith(color: primaryGreen),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}