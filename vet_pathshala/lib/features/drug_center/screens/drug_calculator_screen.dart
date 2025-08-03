import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/drug_model.dart';
import '../../../shared/models/user_model.dart';
import '../providers/drug_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../coins/services/coin_service.dart';

class DrugCalculatorScreen extends StatefulWidget {
  final DrugModel drug;

  const DrugCalculatorScreen({
    super.key,
    required this.drug,
  });

  @override
  State<DrugCalculatorScreen> createState() => _DrugCalculatorScreenState();
}

class _DrugCalculatorScreenState extends State<DrugCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _speciesController = TextEditingController();
  
  String _selectedWeightUnit = 'kg';
  String _selectedSpecies = '';
  Map<String, dynamic>? _calculationResult;
  bool _isCalculating = false;
  bool _hasCalculated = false;
  
  final List<String> _weightUnits = ['kg', 'lbs', 'g'];
  final List<String> _commonSpecies = [
    'Dogs', 'Cats', 'Horses', 'Cattle', 'Sheep', 'Goats', 'Pigs', 'Bird', 'Rabbit', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.drug.targetSpecies.isNotEmpty) {
      final targetSpecies = widget.drug.targetSpecies.first;
      if (_commonSpecies.contains(targetSpecies)) {
        _selectedSpecies = targetSpecies;
      } else {
        // Fallback to empty string if target species not in our list
        _selectedSpecies = '';
      }
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Drug Calculator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drug Info Header
              _buildDrugInfoHeader(),
              const SizedBox(height: 24),

              // Coin Cost Warning
              _buildCoinCostWarning(),
              const SizedBox(height: 24),

              // Calculator Form
              _buildCalculatorForm(),
              const SizedBox(height: 24),

              // Calculate Button
              _buildCalculateButton(),
              const SizedBox(height: 24),

              // Results
              if (_calculationResult != null) ...[
                _buildCalculationResults(),
                const SizedBox(height: 24),
              ],

              // Save Calculation Button
              if (_hasCalculated) _buildSaveCalculationButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrugInfoHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_services,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.drug.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.drug.dosageForm} ${widget.drug.strength}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.drug.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinCostWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Feature - 5 Coins Required',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This dosage calculator requires 5 coins to use. Coins will be deducted when you calculate.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Animal Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Species Selection
              Text(
                'Species *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _selectedSpecies.isEmpty || !_commonSpecies.contains(_selectedSpecies) ? null : _selectedSpecies,
                decoration: InputDecoration(
                  hintText: 'Select animal species',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                items: _commonSpecies.map((species) {
                  return DropdownMenuItem<String?>(
                    value: species,
                    child: Text(species),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecies = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a species';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Weight Input
              Text(
                'Animal Weight *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter weight',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter weight';
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) {
                          return 'Enter valid weight';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String?>(
                      value: _selectedWeightUnit,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      items: _weightUnits.map((unit) {
                        return DropdownMenuItem<String?>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWeightUnit = value ?? 'kg';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Current Dosage Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.info,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Standard Dosage',
                          style: TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.drug.dosage,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final currentUser = authProvider.currentUser;
        final hasEnoughCoins = currentUser != null && currentUser.coins >= 5;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (!_isCalculating && hasEnoughCoins) ? _calculateDosage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasEnoughCoins ? AppColors.primary : AppColors.textTertiary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.calculate,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        hasEnoughCoins 
                            ? 'Calculate Dosage (5 🪙)'
                            : 'Insufficient Coins (5 🪙 required)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

  Widget _buildCalculationResults() {
    final result = _calculationResult!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Dosage Calculation Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Animal Info
            _buildResultSection(
              'Animal Information',
              [
                'Species: ${result['species']}',
                'Weight: ${result['animalWeight']} ${result['weightUnit']} (${result['weightInKg'].toStringAsFixed(1)} kg)',
              ],
            ),

            const SizedBox(height: 16),

            // Dosage Results
            _buildResultSection(
              'Recommended Dosage',
              [
                'Single Dose: ${result['minDose'].toStringAsFixed(2)} - ${result['maxDose'].toStringAsFixed(2)} ${result['doseUnit']}',
                'Frequency: ${result['frequency']} times daily',
                'Daily Total: ${result['dailyMinDose'].toStringAsFixed(2)} - ${result['dailyMaxDose'].toStringAsFixed(2)} ${result['doseUnit']}',
              ],
            ),

            const SizedBox(height: 16),

            // Recommendations
            if (result['recommendations'] != null && (result['recommendations'] as List).isNotEmpty)
              _buildResultSection(
                'Recommendations',
                List<String>.from(result['recommendations']),
              ),

            const SizedBox(height: 16),

            // Warnings
            if (result['warnings'] != null && (result['warnings'] as List).isNotEmpty)
              _buildResultSection(
                'Important Warnings',
                List<String>.from(result['warnings']),
                isWarning: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String title, List<String> items, {bool isWarning = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isWarning ? AppColors.error : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isWarning ? Icons.warning : Icons.check,
                size: 16,
                color: isWarning ? AppColors.error : AppColors.success,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    color: isWarning ? AppColors.error : AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildSaveCalculationButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _saveCalculation,
        icon: const Icon(Icons.save),
        label: const Text('Save Calculation'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
        ),
      ),
    );
  }

  void _calculateDosage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCalculating = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final drugProvider = context.read<DrugProvider>();
      
      // Check if user has enough coins
      if (authProvider.currentUser == null || authProvider.currentUser!.coins < 5) {
        _showInsufficientCoinsDialog();
        return;
      }

      // Deduct coins using the coin service
      final success = await CoinService.processDrugCalculatorPayment(authProvider.currentUser!.id);
      
      if (!success) {
        _showInsufficientCoinsDialog();
        return;
      }

      final weight = double.parse(_weightController.text);
      
      final result = drugProvider.calculateDosage(
        drug: widget.drug,
        animalWeight: weight,
        weightUnit: _selectedWeightUnit,
        species: _selectedSpecies,
        indication: widget.drug.indication,
      );

      setState(() {
        _calculationResult = result;
        _hasCalculated = true;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dosage calculated successfully! 5 coins deducted.'),
          backgroundColor: AppColors.success,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error calculating dosage: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isCalculating = false;
      });
    }
  }

  void _saveCalculation() async {
    if (_calculationResult == null) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final drugProvider = context.read<DrugProvider>();
      
      if (authProvider.currentUser == null) return;

      final calculation = DrugCalculation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        drugId: widget.drug.id,
        calculationType: 'dosage',
        inputs: {
          'animalWeight': double.parse(_weightController.text),
          'weightUnit': _selectedWeightUnit,
          'species': _selectedSpecies,
        },
        results: _calculationResult!,
        animalSpecies: _selectedSpecies,
        animalWeight: double.parse(_weightController.text),
        weightUnit: _selectedWeightUnit,
        calculatedAt: DateTime.now(),
        calculatedBy: authProvider.currentUser!.id,
      );

      await drugProvider.saveCalculation(
        userId: authProvider.currentUser!.id,
        calculation: calculation,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calculation saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving calculation: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showInsufficientCoinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Coins'),
        content: const Text(
          'You need 5 coins to use the drug calculator. '
          'Earn coins by completing quizzes or purchase them in the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to coin purchase screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coin purchase feature coming soon!'),
                ),
              );
            },
            child: const Text('Get Coins'),
          ),
        ],
      ),
    );
  }

}