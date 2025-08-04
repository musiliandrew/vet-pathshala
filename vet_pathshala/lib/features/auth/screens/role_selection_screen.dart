import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import 'sign_up_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with TickerProviderStateMixin {
  String? selectedRole;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              UnifiedTheme.backgroundColor,
              UnifiedTheme.primaryGreen.withOpacity(0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: UnifiedTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Your Role',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: UnifiedTheme.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select your profession to get personalized content',
                              style: TextStyle(
                                fontSize: 16,
                                color: UnifiedTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Role Cards
                  Expanded(
                    child: Column(
                      children: [
                        _buildRoleCard(
                          role: 'doctor',
                          title: 'Veterinarian',
                          description: 'Animal health professionals & veterinary doctors',
                          imagePath: 'assets/images/veterinarian.png',
                          delay: 0,
                        ),
                        const SizedBox(height: 20),
                        _buildRoleCard(
                          role: 'pharmacist',
                          title: 'Pharmacist',
                          description: 'Veterinary pharmacy & medication specialists',
                          imagePath: 'assets/images/pharmacist.png',
                          delay: 200,
                        ),
                        const SizedBox(height: 20),
                        _buildRoleCard(
                          role: 'farmer',
                          title: 'Farmer',
                          description: 'Livestock & animal husbandry professionals',
                          imagePath: 'assets/images/farmer.png',
                          delay: 400,
                        ),
                      ],
                    ),
                  ),

                  // Continue Button
                  const SizedBox(height: 30),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedRole != null ? _onContinuePressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedRole != null
                            ? UnifiedTheme.primaryGreen
                            : UnifiedTheme.tertiaryText,
                        disabledBackgroundColor: UnifiedTheme.tertiaryText,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: selectedRole != null ? 2 : 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: selectedRole != null 
                                  ? Colors.white 
                                  : UnifiedTheme.secondaryText,
                            ),
                          ),
                          if (selectedRole != null) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String description,
    required String imagePath,
    required int delay,
  }) {
    final isSelected = selectedRole == role;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: GestureDetector(
              onTap: () => setState(() => selectedRole = role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: UnifiedTheme.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? UnifiedTheme.primaryGreen
                        : UnifiedTheme.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                          ? UnifiedTheme.primaryGreen.withOpacity(0.1)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: isSelected ? 12 : 8,
                      offset: Offset(0, isSelected ? 6 : 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Image Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? UnifiedTheme.primaryGreen.withOpacity(0.1)
                            : UnifiedTheme.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected 
                              ? UnifiedTheme.primaryGreen
                              : UnifiedTheme.borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: UnifiedTheme.primaryGreen.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ] : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            // Remove color tinting to show original images
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? UnifiedTheme.primaryGreen
                                  : UnifiedTheme.primaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: UnifiedTheme.secondaryText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection Indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? UnifiedTheme.primaryGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? UnifiedTheme.primaryGreen
                              : UnifiedTheme.borderColor,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onContinuePressed() {
    if (selectedRole == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SignUpScreen(selectedRole: selectedRole!),
      ),
    );
  }
}