import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../screens/phone_auth_screen.dart';

class SocialAuthButtons extends StatelessWidget {
  final String selectedRole;
  final bool isSignUp;

  const SocialAuthButtons({
    super.key,
    required this.selectedRole,
    this.isSignUp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign In
        _buildGoogleButton(context),
        const SizedBox(height: 12),
        
        // Phone Sign In
        _buildPhoneButton(context),
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: authProvider.isLoading ? null : () => _signInWithGoogle(context, authProvider),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Icon
                _buildGoogleIcon(),
                const SizedBox(width: 12),
                Text(
                  AppStrings.signInWithGoogle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _signInWithPhone(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_outlined,
              size: 20,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.signInWithPhone,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: GoogleLogoPainter(),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context, AuthProvider authProvider) async {
    try {
      final success = await authProvider.signInWithGoogle(role: selectedRole);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.signInSuccessful),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate back to AppWrapper which will handle the authenticated state
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Google Sign-In Failed', _parseGoogleError(e.toString()));
      }
    }
  }

  String _parseGoogleError(String error) {
    if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error.contains('popup-closed-by-user')) {
      return 'Sign-in was cancelled. Please try again.';
    } else if (error.contains('popup-blocked')) {
      return 'Popup was blocked by your browser. Please allow popups for this site.';
    } else if (error.contains('cancelled')) {
      return 'Google Sign-In was cancelled.';
    } else if (error.contains('credential')) {
      return 'Authentication credentials are invalid. Please try signing in again.';
    } else {
      return 'Unable to sign in with Google. Please try again or use email instead.';
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _signInWithPhone(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhoneAuthScreen(selectedRole: selectedRole),
      ),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Google "G" blue part
    paint.color = const Color(0xFF4285F4);
    final path1 = Path();
    path1.moveTo(size.width * 0.5, size.height * 0.1);
    path1.lineTo(size.width * 0.9, size.height * 0.1);
    path1.lineTo(size.width * 0.9, size.height * 0.4);
    path1.lineTo(size.width * 0.75, size.height * 0.4);
    path1.lineTo(size.width * 0.75, size.height * 0.25);
    path1.lineTo(size.width * 0.5, size.height * 0.25);
    path1.close();
    canvas.drawPath(path1, paint);
    
    // Google "G" red part
    paint.color = const Color(0xFFEA4335);
    final path2 = Path();
    path2.moveTo(size.width * 0.1, size.height * 0.5);
    path2.arcToPoint(
      Offset(size.width * 0.5, size.height * 0.1),
      radius: Radius.circular(size.width * 0.4),
    );
    path2.lineTo(size.width * 0.5, size.height * 0.25);
    path2.arcToPoint(
      Offset(size.width * 0.25, size.height * 0.5),
      radius: Radius.circular(size.width * 0.25),
      clockwise: false,
    );
    path2.close();
    canvas.drawPath(path2, paint);
    
    // Google "G" yellow part
    paint.color = const Color(0xFFFBBC05);
    final path3 = Path();
    path3.moveTo(size.width * 0.1, size.height * 0.5);
    path3.arcToPoint(
      Offset(size.width * 0.5, size.height * 0.9),
      radius: Radius.circular(size.width * 0.4),
    );
    path3.lineTo(size.width * 0.5, size.height * 0.75);
    path3.arcToPoint(
      Offset(size.width * 0.25, size.height * 0.5),
      radius: Radius.circular(size.width * 0.25),
      clockwise: false,
    );
    path3.close();
    canvas.drawPath(path3, paint);
    
    // Google "G" green part
    paint.color = const Color(0xFF34A853);
    final path4 = Path();
    path4.moveTo(size.width * 0.5, size.height * 0.9);
    path4.arcToPoint(
      Offset(size.width * 0.9, size.height * 0.5),
      radius: Radius.circular(size.width * 0.4),
    );
    path4.lineTo(size.width * 0.75, size.height * 0.5);
    path4.arcToPoint(
      Offset(size.width * 0.5, size.height * 0.75),
      radius: Radius.circular(size.width * 0.25),
      clockwise: false,
    );
    path4.close();
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}