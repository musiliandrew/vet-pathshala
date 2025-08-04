import 'package:flutter/material.dart';

class UnifiedTheme {
  // Modern Bright Color Palette (VetPathshala Pro Theme)
  static const Color primary = Color(0xFF00C897);
  static const Color secondary = Color(0xFF3D84FF);
  static const Color accent = Color(0xFFFF9F29);
  static const Color dark = Color(0xFF2D4059);
  static const Color light = Color(0xFFF6F6F6);
  static const Color white = Color(0xFFFFFFFF);
  
  // Legacy names for backward compatibility
  static const Color primaryGreen = primary;
  static const Color lightGreen = Color(0xFF00A278);
  static const Color darkGreen = Color(0xFF00A278);
  static const Color greenAccent = primary;
  
  // Background Colors (Light Theme)
  static const Color backgroundColor = light;
  static const Color lightBackground = Color(0xFFF9F9F9);
  static const Color cardBackground = white;
  static const Color surfaceColor = white;
  
  // Text Colors (Dark on Light)
  static const Color primaryText = dark;
  static const Color secondaryText = Color(0xFF7A7A7A);
  static const Color tertiaryText = Color(0xFFBDBDBD);
  
  // Accent Colors
  static const Color goldAccent = accent;
  static const Color redAccent = Color(0xFFEF4444);
  static const Color blueAccent = secondary;
  
  // Border Colors (Light Theme)
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFF0F0F0);
  
  // Gradients (Modern Bright)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundColor, lightBackground],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, lightGreen],
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [accent, Color(0xFFFF7B00)],
  );
  
  // Ebook Gradients (from HTML design)
  static const LinearGradient ebook1Gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), secondary],
  );
  
  static const LinearGradient ebook2Gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, lightGreen],
  );
  
  static const LinearGradient ebook3Gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFF7B00)],
  );
  
  static const LinearGradient ebook4Gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFF3D3D)],
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
  
  // Shadows (Enhanced for modern look)
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];
  
  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 15),
    ),
  ];
  
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> accentShadow = [
    BoxShadow(
      color: accent.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
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