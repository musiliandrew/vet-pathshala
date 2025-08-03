import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/models/user_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _specializationController = TextEditingController();
  final _locationController = TextEditingController();
  
  int _currentStep = 0;
  int _experienceYears = 1;
  String _selectedExperienceLevel = 'beginner';
  List<String> _selectedInterests = [];
  
  final List<String> _experienceLevels = [
    'beginner',
    'intermediate', 
    'advanced',
    'expert'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _specializationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: _currentStep > 0 
                ? IconButton(
                    onPressed: () => _previousStep(),
                    icon: const Icon(Icons.arrow_back_ios),
                  )
                : null,
            title: Text(
              'Step ${_currentStep + 1} of 3',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => _skipProfileSetup(authProvider),
                child: const Text(
                  AppStrings.skip,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(),
              
              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPersonalInfoStep(user),
                    _buildProfessionalInfoStep(user),
                    _buildPreferencesStep(user),
                  ],
                ),
              ),
              
              // Bottom Actions
              _buildBottomActions(authProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoStep(UserModel user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(
                icon: _getRoleIcon(user.userRole),
                title: AppStrings.personalInfo,
                subtitle: 'Tell us about yourself',
                userRole: user.userRole,
              ),
              const SizedBox(height: 32),
              
              AuthTextField(
                controller: _nameController,
                hintText: AppStrings.fullName,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return AppStrings.nameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              AuthTextField(
                controller: _phoneController,
                hintText: AppStrings.phoneNumber,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              AuthTextField(
                controller: _locationController,
                hintText: AppStrings.location,
                prefixIcon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoStep(UserModel user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              icon: '💼',
              title: AppStrings.professionalInfo,
              subtitle: 'Your professional background',
              userRole: user.userRole,
            ),
            const SizedBox(height: 32),
            
            AuthTextField(
              controller: _organizationController,
              hintText: AppStrings.organization,
              prefixIcon: Icons.business_outlined,
            ),
            const SizedBox(height: 16),
            
            AuthTextField(
              controller: _specializationController,
              hintText: _getSpecializationHint(user.userRole),
              prefixIcon: Icons.school_outlined,
            ),
            const SizedBox(height: 24),
            
            _buildExperienceSection(),
            const SizedBox(height: 24),
            
            _buildExperienceLevelSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesStep(UserModel user) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              icon: '⚡',
              title: AppStrings.preferences,
              subtitle: 'Customize your learning experience',
              userRole: user.userRole,
            ),
            const SizedBox(height: 32),
            
            _buildInterestsSection(user),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader({
    required String icon,
    required String title,
    required String subtitle,
    required String userRole,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.getRoleGradient(userRole),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.getRoleColor(userRole).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Years of Experience: $_experienceYears',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Slider(
                value: _experienceYears.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.border,
                onChanged: (value) {
                  setState(() {
                    _experienceYears = value.round();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fresh (1 year)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Expert (30+ years)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Experience Level',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _experienceLevels.map((level) {
            final isSelected = _selectedExperienceLevel == level;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedExperienceLevel = level;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _getExperienceLevelText(level),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsSection(UserModel user) {
    final interests = _getInterestsForRole(user.userRole);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Areas of Interest',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select topics you\'re interested in learning about',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Text(
                  interest,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomActions(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: TextButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : () {
                if (_currentStep < 2) {
                  _nextStep();
                } else {
                  _completeProfile(authProvider);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      _currentStep < 2 ? 'Next' : 'Complete Profile',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeProfile(AuthProvider authProvider) async {
    final success = await authProvider.completeProfile(
      specialization: _specializationController.text.trim().isNotEmpty 
          ? _specializationController.text.trim() 
          : null,
      experienceYears: _experienceYears,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.profileUpdated),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _skipProfileSetup(AuthProvider authProvider) async {
    final success = await authProvider.completeProfile();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile setup skipped'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  String _getRoleIcon(String userRole) {
    switch (userRole) {
      case 'doctor':
        return '🐕';
      case 'pharmacist':
        return '💊';
      case 'farmer':
        return '🌾';
      default:
        return '🐕';
    }
  }


  String _getSpecializationHint(String userRole) {
    switch (userRole) {
      case 'doctor':
        return 'Small Animal Practice, Surgery, etc.';
      case 'pharmacist':
        return 'Clinical Pharmacy, Research, etc.';
      case 'farmer':
        return 'Dairy, Poultry, Livestock, etc.';
      default:
        return 'Specialization';
    }
  }

  String _getExperienceLevelText(String level) {
    switch (level) {
      case 'beginner':
        return 'Beginner (0-2 years)';
      case 'intermediate':
        return 'Intermediate (2-5 years)';
      case 'advanced':
        return 'Advanced (5-10 years)';
      case 'expert':
        return 'Expert (10+ years)';
      default:
        return 'Beginner';
    }
  }

  List<String> _getInterestsForRole(String userRole) {
    switch (userRole) {
      case 'doctor':
        return [
          AppStrings.smallAnimalPractice,
          AppStrings.largeAnimalPractice,
          AppStrings.exoticAnimals,
          AppStrings.veterinarySurgery,
          AppStrings.animalNutrition,
          AppStrings.veterinaryPathology,
        ];
      case 'pharmacist':
        return [
          AppStrings.veterinaryPharmacology,
          AppStrings.drugCompounding,
          AppStrings.clinicalPharmacy,
          AppStrings.drugRegulation,
          AppStrings.pharmacovigilance,
        ];
      case 'farmer':
        return [
          AppStrings.livestock,
          AppStrings.animalHealth,
          AppStrings.breeding,
          AppStrings.nutrition,
          AppStrings.diseasesPrevention,
          AppStrings.organicFarming,
        ];
      default:
        return [];
    }
  }
}