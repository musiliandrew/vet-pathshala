import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Updated based on design inspiration
  static const Color primary = Color(0xFF00C851); // Green from design
  static const Color primaryDark = Color(0xFF007E33); // Darker green
  static const Color primaryLight = Color(0xFF69F0AE);
  static const Color secondaryLight = Color(0xFF90CAF9);
  static const Color secondary = Color(0xFF4299E1); // Blue secondary
  static const Color accent = Color(0xFF38B2AC); // Teal accent
  
  // Surface Colors - Modern glassmorphism style
  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color glassSurface = Color(0xF2FFFFFF); // 95% opacity white
  
  // Text Colors - Better contrast
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Status Colors - Vibrant and modern
  static const Color success = Color(0xFF00C851);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF4299E1);
  
  // Border & Divider
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  
  // Role-based Colors - Updated to match design
  static const Color doctorColor = Color(0xFF4299E1); // Blue
  static const Color pharmacistColor = Color(0xFF00C851); // Green
  static const Color farmerColor = Color(0xFFED8936); // Orange
  static const Color veterinaryColor = Color(0xFF00C851); // Green for backward compatibility
  
  // Card Colors for different categories
  static const Color cardBlue = Color(0xFF4299E1);
  static const Color cardOrange = Color(0xFFED8936);
  static const Color cardTeal = Color(0xFF38B2AC);
  static const Color cardGreen = Color(0xFF00C851);
  static const Color cardGreenLight = Color(0xFF69F0AE);
  static const Color cardGreenDark = Color(0xFF007E33);
  
  // Gradients - Updated based on design inspiration
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C851), Color(0xFF007E33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF00C851), Color(0xFF38B2AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C851), Color(0xFF007E33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Role-based gradients
  static const LinearGradient veterinaryGradient = LinearGradient(
    colors: [Color(0xFF00C851), Color(0xFF007E33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient pharmacistGradient = LinearGradient(
    colors: [Color(0xFF00C851), Color(0xFF007E33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient farmerGradient = LinearGradient(
    colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Glass morphism effect colors
  static const Color glassWhite = Color(0xF2FFFFFF); // 95% opacity
  static const Color glassBlur = Color(0x1AFFFFFF); // 10% opacity for backdrop
  
  // Shimmer effect colors
  static const Color shimmerBase = Color(0xFFF0F0F0);
  static const Color shimmerHighlight = Color(0xFFE0E0E0);
  
  // Helper methods
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'veterinarian':
      case 'veterinary':
      case 'doctor':
        return veterinaryColor;
      case 'pharmacist':
        return pharmacistColor;
      case 'farmer':
        return farmerColor;
      default:
        return primary;
    }
  }
  
  static LinearGradient getRoleGradient(String role) {
    switch (role.toLowerCase()) {
      case 'veterinarian':
      case 'veterinary':
      case 'doctor':
        return veterinaryGradient;
      case 'pharmacist':
        return pharmacistGradient;
      case 'farmer':
        return farmerGradient;
      default:
        return primaryGradient;
    }
  }
  
  // Get category colors for different exam types
  static Color getCategoryColor(int index) {
    final colors = [
      cardGreen,
      cardBlue,
      cardOrange, 
      cardTeal,
      cardGreenLight,
      cardGreenDark,
    ];
    return colors[index % colors.length];
  }
  
  static LinearGradient getCategoryGradient(int index) {
    final gradients = [
      primaryGradient,
      secondaryGradient,
      warningGradient,
      const LinearGradient(colors: [Color(0xFF38B2AC), Color(0xFF319795)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      successGradient,
      const LinearGradient(colors: [Color(0xFF69F0AE), Color(0xFF00C851)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ];
    return gradients[index % gradients.length];
  }
}