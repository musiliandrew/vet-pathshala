import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../providers/auth_provider.dart';
import 'sign_in_screen.dart';
import 'phone_auth_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String selectedRole;

  const SignUpScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  AuthProvider? _authProvider;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store reference to AuthProvider safely
    if (_authProvider == null) {
      _authProvider = context.read<AuthProvider>();
      _authProvider!.addListener(_onAuthStateChanged);
    }
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    
    final authProvider = _authProvider;
    if (authProvider == null) return;
    
    print('🟡 SignUpScreen: Auth state changed to ${authProvider.state}');
    
    if (authProvider.isAuthenticated && mounted) {
      print('✅ SignUpScreen: User authenticated, navigating to home');
      // Pop all auth screens and let AppWrapper handle navigation
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    // Remove authentication listener safely
    _authProvider?.removeListener(_onAuthStateChanged);
    _authProvider = null;
    
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String get _roleTitle {
    switch (widget.selectedRole) {
      case 'doctor':
        return 'Veterinarian';
      case 'pharmacist':
        return 'Pharmacist';
      case 'farmer':
        return 'Farmer';
      default:
        return 'Professional';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              margin: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 10,
                  shadowColor: UnifiedTheme.primaryGreen.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: UnifiedTheme.primaryGreen,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Role Badge (top right)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: UnifiedTheme.primaryGreen.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _roleTitle,
                                style: TextStyle(
                                  color: UnifiedTheme.primaryGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Logo
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  UnifiedTheme.primaryGreen,
                                  const Color(0xFF00A278),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: UnifiedTheme.primaryGreen.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Title
                          Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: UnifiedTheme.primaryGreen,
                            ),
                          ),
                          
                          const SizedBox(height: 5),
                          
                          // Subtitle
                          Text(
                            'Join VetPathshala Pro to enhance your veterinary knowledge',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF666666),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 30),
                    
                          // Form Fields
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'Enter your email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Create a password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: 'Confirm your password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            onToggleVisibility: () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Terms Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: Checkbox(
                                  value: true,
                                  onChanged: (value) {},
                                  activeColor: UnifiedTheme.primaryGreen,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF666666),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: UnifiedTheme.primaryGreen,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' and ',
                                        style: TextStyle(
                                          color: const Color(0xFF666666),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: UnifiedTheme.primaryGreen,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 30),
                    
                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _onSignUpPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UnifiedTheme.primaryGreen,
                                disabledBackgroundColor: UnifiedTheme.tertiaryText,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.person_add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // OR Divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(
                                  'or sign up with',
                                  style: TextStyle(
                                    color: const Color(0xFF666666),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // Google Sign Up Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: (_isLoading || authProvider.state == AuthState.loading) 
                                      ? null 
                                      : _onGoogleSignUpPressed,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: BorderSide(
                                      color: const Color(0xFFDB4437),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.g_mobiledata,
                                        color: const Color(0xFFDB4437),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFDB4437),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: const Color(0xFF666666),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => SignInScreen(selectedRole: widget.selectedRole),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: UnifiedTheme.primaryGreen,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF666666),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF666666),
              size: 20,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF666666),
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: UnifiedTheme.primaryGreen,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }


  void _onSignUpPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: widget.selectedRole,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign up failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onGoogleSignUpPressed() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithGoogle(role: widget.selectedRole);
      
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign up failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Don't set _isLoading = false here, let AuthProvider handle the state
      // The AppWrapper will navigate away automatically on successful auth
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign up failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onPhoneSignUpPressed() {
    // Navigate to phone auth screen for sign up
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhoneAuthScreen(
          selectedRole: widget.selectedRole,
        ),
      ),
    );
  }
}