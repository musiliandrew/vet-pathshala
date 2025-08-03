import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/drug_model.dart';
import '../providers/drug_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'drug_calculator_screen.dart';

class DrugDetailScreen extends StatelessWidget {
  final DrugModel drug;

  const DrugDetailScreen({
    super.key,
    required this.drug,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                drug.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.medical_services,
                    size: 60,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
            actions: [
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.currentUser == null) {
                    return const SizedBox.shrink();
                  }

                  return Consumer<DrugProvider>(
                    builder: (context, drugProvider, child) {
                      final isBookmarked = drugProvider.isDrugBookmarked(drug.id);
                      return IconButton(
                        onPressed: () {
                          drugProvider.toggleBookmark(
                            authProvider.currentUser!.id,
                            drug.id,
                          );
                        },
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  _buildInfoCard(
                    context,
                    'Basic Information',
                    Icons.info_outline,
                    [
                      _buildInfoRow('Generic Name', drug.genericName),
                      _buildInfoRow('Brand Name', drug.brandName),
                      _buildInfoRow('Category', _formatCategoryName(drug.category)),
                      _buildInfoRow('Classification', drug.classification),
                      _buildInfoRow('Dosage Form', drug.dosageForm),
                      _buildInfoRow('Strength', drug.strength),
                      _buildInfoRow('Route', drug.route),
                      if (drug.manufacturer.isNotEmpty)
                        _buildInfoRow('Manufacturer', drug.manufacturer),
                      if (drug.price > 0)
                        _buildInfoRow('Price', '\$${drug.price.toStringAsFixed(2)}'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Veterinary Specific Info
                  if (drug.isVeterinarySpecific) ...[
                    _buildInfoCard(
                      context,
                      'Veterinary Information',
                      Icons.pets,
                      [
                        _buildInfoRow('Target Species', drug.targetSpecies.join(', ')),
                        if (drug.withdrawalPeriod.isNotEmpty)
                          _buildInfoRow('Withdrawal Period', drug.withdrawalPeriod),
                        if (drug.isControlled)
                          _buildInfoRow('Controlled Class', drug.controlledClass),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Clinical Information
                  _buildInfoCard(
                    context,
                    'Clinical Information',
                    Icons.medical_information,
                    [
                      _buildExpandableInfoRow('Indication', drug.indication),
                      _buildExpandableInfoRow('Dosage', drug.dosage),
                      _buildExpandableInfoRow('Mechanism of Action', drug.mechanism),
                      _buildExpandableInfoRow('Pharmacokinetics', drug.pharmacokinetics),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Safety Information
                  _buildInfoCard(
                    context,
                    'Safety Information',
                    Icons.warning_amber,
                    [
                      _buildExpandableInfoRow('Contraindications', drug.contraindication),
                      _buildExpandableInfoRow('Side Effects', drug.sideEffects),
                      _buildExpandableInfoRow('Precautions', drug.precautions),
                      _buildExpandableInfoRow('Drug Interactions', drug.interactions),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Storage Information
                  if (drug.storage.isNotEmpty)
                    _buildInfoCard(
                      context,
                      'Storage & Handling',
                      Icons.inventory_2,
                      [
                        _buildExpandableInfoRow('Storage Requirements', drug.storage),
                      ],
                    ),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DrugCalculatorScreen(drug: drug),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.calculate, color: Colors.white),
        label: const Text(
          'Calculate Dosage',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
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
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
          childrenPadding: EdgeInsets.zero,
          tilePadding: EdgeInsets.zero,
          dense: true,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  String _formatCategoryName(String category) {
    return category
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}