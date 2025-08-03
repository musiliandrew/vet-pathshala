import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/drug_provider.dart';

class EnhancedDrugCalculatorScreen extends StatefulWidget {
  const EnhancedDrugCalculatorScreen({super.key});

  @override
  State<EnhancedDrugCalculatorScreen> createState() => _EnhancedDrugCalculatorScreenState();
}

class _EnhancedDrugCalculatorScreenState extends State<EnhancedDrugCalculatorScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _concentrationController = TextEditingController();
  
  String? _selectedMedicine;
  String? _selectedAnimal;
  String? _selectedForm;
  Map<String, dynamic>? _calculationResult;
  bool _isCalculating = false;

  // Sample medicines data with standard doses
  final Map<String, Map<String, dynamic>> medicines = {
    'Amoxicillin': {
      'icon': '🧪',
      'standardDose': '15.0-20.0',
      'unit': 'mg/kg',
    },
    'Penicillin': {
      'icon': '💊',
      'standardDose': '10.0-15.0',
      'unit': 'mg/kg',
    },
    'Oxytetracycline': {
      'icon': '💉',
      'standardDose': '5.0-10.0',
      'unit': 'mg/kg',
    },
    'Ivermectin': {
      'icon': '🧪',
      'standardDose': '0.2-0.4',
      'unit': 'mg/kg',
    },
    'Dexamethasone': {
      'icon': '💊',
      'standardDose': '0.1-0.5',
      'unit': 'mg/kg',
    },
    'Vitamin B Complex': {
      'icon': '💉',
      'standardDose': '1.0-2.0',
      'unit': 'mg/kg',
    },
  };

  final Map<String, String> animals = {
    'Cattle': '🐄',
    'Buffalo': '🐃',
    'Goats': '🐐',
    'Sheep': '🐑',
    'Dogs': '🐕',
    'Cats': '🐱',
    'Horses': '🐴',
    'Pigs': '🐷',
  };

  final Map<String, String> medicineForms = {
    'Liquid Injection': '💉',
    'Powder': '🧂',
    'Tablet / Bolus': '💊',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    // Set default selections to null initially to avoid mismatches
    _selectedAnimal = null;
    _selectedForm = null;
    _selectedMedicine = null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _weightController.dispose();
    _concentrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Please sign in to access calculator')),
          );
        }

        return Scaffold(
          backgroundColor: UnifiedTheme.backgroundColor,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, user),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(UnifiedTheme.spacingL),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Medicine Selection
                              _buildMedicineDropdown(),
                              const SizedBox(height: UnifiedTheme.spacingL),
                              
                              // Animal Selection
                              _buildAnimalDropdown(),
                              const SizedBox(height: UnifiedTheme.spacingL),
                              
                              // Medicine Form Selection
                              _buildFormDropdown(),
                              const SizedBox(height: UnifiedTheme.spacingL),
                              
                              // Weight Input
                              _buildWeightInput(),
                              const SizedBox(height: UnifiedTheme.spacingL),
                              
                              // Concentration Input
                              _buildConcentrationInput(),
                              const SizedBox(height: UnifiedTheme.spacingS),
                              
                              // Info text
                              const Text(
                                'As per standard reference, dosage in mg/kg body weight.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: UnifiedTheme.tertiaryText,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: UnifiedTheme.spacingL),
                              
                              // Standard Dose Display
                              if (_selectedMedicine != null) _buildStandardDoseDisplay(),
                              const SizedBox(height: UnifiedTheme.spacingL),
                              
                              // Calculate Button
                              _buildCalculateButton(),
                              const SizedBox(height: UnifiedTheme.spacingL),
                              
                              // Results
                              if (_calculationResult != null) _buildResults(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return UnifiedTheme.buildGradientContainer(
      child: Column(
        children: [
          // Top navigation
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: UnifiedTheme.spacingL),
              Text(
                'Hello, ${user.name.isNotEmpty ? user.name : 'Dr. NK'}',
                style: UnifiedTheme.headerMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: UnifiedTheme.spacingS),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Text(
                'Welcome to Drug Dose Calculator',
                style: UnifiedTheme.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineDropdown() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.lightBackground, UnifiedTheme.lightBackground.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      child: DropdownButtonFormField<String?>(
        value: _selectedMedicine != null && medicines.containsKey(_selectedMedicine!) ? _selectedMedicine : null,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _selectedMedicine != null && medicines.containsKey(_selectedMedicine) ? medicines[_selectedMedicine]!['icon'] : '🧪',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          hintText: 'Select Medicine',
          hintStyle: UnifiedTheme.bodyMedium.copyWith(
            color: UnifiedTheme.tertiaryText,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UnifiedTheme.spacingL,
            vertical: UnifiedTheme.spacingL,
          ),
        ),
        items: medicines.keys.map((medicine) {
          return DropdownMenuItem<String?>(
            value: medicine,
            child: Row(
              children: [
                Text(
                  medicines[medicine]!['icon'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  medicine,
                  style: UnifiedTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedMedicine = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a medicine';
          }
          return null;
        },
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildAnimalDropdown() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.lightBackground, UnifiedTheme.lightBackground.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      child: DropdownButtonFormField<String?>(
        value: _selectedAnimal != null && animals.containsKey(_selectedAnimal!) ? _selectedAnimal : null,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _selectedAnimal != null && animals.containsKey(_selectedAnimal) ? animals[_selectedAnimal]! : '🐄',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          hintText: 'Select Animal Species',
          hintStyle: UnifiedTheme.bodyMedium.copyWith(
            color: UnifiedTheme.tertiaryText,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UnifiedTheme.spacingL,
            vertical: UnifiedTheme.spacingL,
          ),
        ),
        items: animals.keys.map((animal) {
          return DropdownMenuItem<String?>(
            value: animal,
            child: Row(
              children: [
                Text(
                  animals[animal]!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  animal,
                  style: UnifiedTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedAnimal = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an animal species';
          }
          return null;
        },
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildFormDropdown() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.lightBackground, UnifiedTheme.lightBackground.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      child: DropdownButtonFormField<String?>(
        value: _selectedForm != null && medicineForms.containsKey(_selectedForm!) ? _selectedForm : null,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: UnifiedTheme.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _selectedForm != null && medicineForms.containsKey(_selectedForm) ? medicineForms[_selectedForm]! : '💊',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          hintText: 'Select Medicine Form',
          hintStyle: UnifiedTheme.bodyMedium.copyWith(
            color: UnifiedTheme.tertiaryText,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UnifiedTheme.spacingL,
            vertical: UnifiedTheme.spacingL,
          ),
        ),
        items: medicineForms.keys.map((form) {
          return DropdownMenuItem<String?>(
            value: form,
            child: Row(
              children: [
                Text(
                  medicineForms[form]!,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  form,
                  style: UnifiedTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedForm = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a medicine form';
          }
          return null;
        },
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildWeightInput() {
    return Container(
      decoration: BoxDecoration(
        color: UnifiedTheme.lightBackground,
        border: Border.all(color: UnifiedTheme.borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _weightController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter weight in kg',
          hintStyle: UnifiedTheme.bodyMedium.copyWith(
            color: UnifiedTheme.tertiaryText,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UnifiedTheme.spacingL,
            vertical: UnifiedTheme.spacingL,
          ),
        ),
        style: UnifiedTheme.bodyLarge.copyWith(
          color: UnifiedTheme.primaryText,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter weight';
          }
          final weight = double.tryParse(value);
          if (weight == null || weight <= 0) {
            return 'Please enter a valid weight';
          }
          return null;
        },
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildConcentrationInput() {
    return Container(
      decoration: BoxDecoration(
        color: UnifiedTheme.lightBackground,
        border: Border.all(color: UnifiedTheme.borderColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: _concentrationController,
        decoration: InputDecoration(
          hintText: 'e.g. 100 mg/ml',
          hintStyle: UnifiedTheme.bodyMedium.copyWith(
            color: UnifiedTheme.tertiaryText,
          ),
          suffixIcon: GestureDetector(
            onTap: _showConcentrationHelp,
            child: Container(
              margin: const EdgeInsets.all(12),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'i',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UnifiedTheme.spacingL,
            vertical: UnifiedTheme.spacingL,
          ),
        ),
        style: UnifiedTheme.bodyLarge.copyWith(
          color: UnifiedTheme.primaryText,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter concentration';
          }
          return null;
        },
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildStandardDoseDisplay() {
    final medicineData = medicines[_selectedMedicine]!;
    return Container(
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.lightBackground, UnifiedTheme.lightBackground.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: UnifiedTheme.primaryGreen, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Standard Dose',
            style: UnifiedTheme.bodyLarge.copyWith(
              color: UnifiedTheme.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingS),
          Text(
            '${medicineData['standardDose']} ${medicineData['unit']}',
            style: UnifiedTheme.headerSmall.copyWith(
              color: UnifiedTheme.blueAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    final isFormValid = _selectedMedicine != null &&
        _weightController.text.isNotEmpty &&
        _concentrationController.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isFormValid && !_isCalculating) ? _calculateDosage : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? UnifiedTheme.blueAccent : UnifiedTheme.tertiaryText,
          padding: const EdgeInsets.symmetric(vertical: UnifiedTheme.spacingL),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isFormValid ? 8 : 0,
          shadowColor: UnifiedTheme.blueAccent.withOpacity(0.3),
        ),
        child: _isCalculating
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Calculate Dosage',
                style: UnifiedTheme.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildResults() {
    final result = _calculationResult!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.blueAccent.withOpacity(0.1), UnifiedTheme.blueAccent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: UnifiedTheme.blueAccent, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(UnifiedTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: UnifiedTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Dosage Calculation Results',
                  style: UnifiedTheme.headerMedium.copyWith(
                    color: UnifiedTheme.blueAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UnifiedTheme.spacingL),
            
            _buildResultItem('Animal Weight:', '${result['weight']} kg'),
            _buildResultItem('Standard Dose:', result['standardDose']),
            _buildResultItem('Total Dose Required:', '${result['totalDose']} mg'),
            _buildResultItem('Medicine Concentration:', result['concentration']),
            _buildResultItem('Volume to Administer:', '${result['volume']} ml'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: UnifiedTheme.bodyMedium.copyWith(
              color: UnifiedTheme.blueAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: UnifiedTheme.bodyMedium.copyWith(
              color: UnifiedTheme.blueAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _calculateDosage() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
    });

    // Simulate calculation delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      final weight = double.parse(_weightController.text);
      final concentrationText = _concentrationController.text;
      final medicineData = medicines[_selectedMedicine]!;
      
      // Parse concentration (assuming mg/ml format)
      final concentrationMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(concentrationText);
      final concentration = concentrationMatch != null 
          ? double.parse(concentrationMatch.group(1)!) 
          : 100.0; // Default concentration
      
      // Parse standard dose range
      final doseParts = medicineData['standardDose'].split('-');
      final minDose = double.parse(doseParts[0]);
      final maxDose = double.parse(doseParts[1]);
      final avgDose = (minDose + maxDose) / 2;
      
      final totalDose = weight * avgDose; // mg
      final volume = totalDose / concentration; // ml
      
      setState(() {
        _calculationResult = {
          'weight': weight.toStringAsFixed(1),
          'standardDose': '${medicineData['standardDose']} ${medicineData['unit']}',
          'totalDose': totalDose.toStringAsFixed(2),
          'concentration': '$concentration mg/ml',
          'volume': volume.toStringAsFixed(2),
        };
        _isCalculating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dosage calculated successfully!'),
          backgroundColor: UnifiedTheme.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _showConcentrationHelp() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: UnifiedTheme.borderColor)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.help_outline,
                    color: UnifiedTheme.primaryGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'How to Find Medicine Concentration',
                    style: UnifiedTheme.headerMedium.copyWith(
                      color: UnifiedTheme.primaryText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: UnifiedTheme.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: UnifiedTheme.borderColor),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.medical_services,
                              size: 48,
                              color: UnifiedTheme.primaryGreen,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Medicine Bottle Label',
                              style: UnifiedTheme.headerMedium.copyWith(
                                color: UnifiedTheme.primaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: UnifiedTheme.goldAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: UnifiedTheme.goldAccent),
                              ),
                              child: Text(
                                '150mg/ml',
                                style: UnifiedTheme.bodyMedium.copyWith(
                                  color: UnifiedTheme.goldAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Look for the concentration value on your medicine bottle or vial label. It\'s usually written as "mg/ml", "mg/g", or as a percentage.',
                      style: UnifiedTheme.bodyMedium.copyWith(
                        color: UnifiedTheme.secondaryText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}