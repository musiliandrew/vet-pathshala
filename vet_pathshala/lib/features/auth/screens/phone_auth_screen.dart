import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class PhoneAuthScreen extends StatefulWidget {
  final String selectedRole;

  const PhoneAuthScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  int _resendTimer = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Listen for verification ID changes
          if (authProvider.verificationId != null && !_isOtpSent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _isOtpSent = true;
              });
              _startResendTimer();
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 40),

                    // Form
                    if (!_isOtpSent) ...[
                      _buildPhoneForm(),
                    ] else ...[
                      _buildOtpForm(),
                    ],

                    const SizedBox(height: 32),

                    // Action Button
                    _buildActionButton(authProvider),
                    const SizedBox(height: 20),

                    // Resend OTP (if OTP sent)
                    if (_isOtpSent) _buildResendOtp(authProvider),

                    // Error Message
                    if (authProvider.errorMessage != null)
                      _buildErrorMessage(authProvider.errorMessage!),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppColors.getRoleGradient(widget.selectedRole),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.phone_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isOtpSent ? 'Verify Phone Number' : 'Phone Number',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isOtpSent
              ? 'Enter the 6-digit code sent to ${_phoneController.text}'
              : 'We\'ll send you a verification code',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      children: [
        AuthTextField(
          controller: _nameController,
          hintText: AppStrings.nameHint,
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.nameRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _phoneController,
          hintText: '+91 XXXXXXXXXX',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.phoneRequired;
            }
            if (!RegExp(r'^\+91[6-9]\d{9}$').hasMatch(value)) {
              return 'Please enter a valid Indian phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        // OTP Input
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 8,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the OTP';
            }
            if (value.length != 6) {
              return 'Please enter a valid 6-digit OTP';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Change Phone Number
        TextButton(
          onPressed: () {
            setState(() {
              _isOtpSent = false;
              _otpController.clear();
            });
            context.read<AuthProvider>().clearVerificationId();
          },
          child: Text(
            'Change phone number',
            style: TextStyle(
              color: AppColors.getRoleColor(widget.selectedRole),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authProvider.isLoading 
            ? null 
            : (_isOtpSent ? () => _verifyOtp(authProvider) : () => _sendOtp(authProvider)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getRoleColor(widget.selectedRole),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: authProvider.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isOtpSent ? 'Verify OTP' : 'Send OTP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildResendOtp(AuthProvider authProvider) {
    return Center(
      child: _resendTimer > 0
          ? Text(
              'Resend OTP in ${_resendTimer}s',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiary,
              ),
            )
          : TextButton(
              onPressed: authProvider.isLoading ? null : () => _resendOtp(authProvider),
              child: Text(
                'Resend OTP',
                style: TextStyle(
                  color: AppColors.getRoleColor(widget.selectedRole),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.signInWithPhone(_phoneController.text.trim());
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _verifyOtp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authProvider.verifyOTP(
      smsCode: _otpController.text.trim(),
      name: _nameController.text.trim(),
      role: widget.selectedRole,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.signInSuccessful),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _resendOtp(AuthProvider authProvider) async {
    final success = await authProvider.signInWithPhone(_phoneController.text.trim());
    
    if (success && mounted) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _resendTimer--;
        });
        return _resendTimer > 0;
      }
      return false;
    });
  }
}