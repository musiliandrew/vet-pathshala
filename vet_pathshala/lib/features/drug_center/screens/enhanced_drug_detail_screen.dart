import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/drug_model.dart';
import '../providers/drug_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'drug_calculator_screen.dart';

class EnhancedDrugDetailScreen extends StatelessWidget {
  final DrugModel drug;

  const EnhancedDrugDetailScreen({
    super.key,
    required this.drug,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          _buildSliverAppBar(context),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Cards
                  _buildQuickStatsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Drug Composition & Salt Information
                  _buildModernInfoCard(
                    context,
                    'Drug Composition & Salt Information',
                    Icons.science_outlined,
                    UnifiedTheme.blueAccent,
                    [
                      _buildInfoItem('Generic/Salt Name', drug.genericName, Icons.medication),
                      _buildInfoItem('Category', _formatCategoryName(drug.category), Icons.category),
                      _buildInfoItem('Classification', drug.classification, Icons.class_outlined),
                      _buildInfoItem('Dosage Form', drug.dosageForm, Icons.medication_liquid),
                      _buildInfoItem('Strength', drug.strength, Icons.fitness_center),
                      _buildInfoItem('Route', drug.route, Icons.route),
                      _buildExpandableInfoItem('Salt Properties', 
                        'Active pharmaceutical ingredient (API): ${drug.genericName}. This salt is the therapeutically active component responsible for the drug\'s pharmacological effects.',
                        Icons.info_outline),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Veterinary Specific Info
                  if (drug.isVeterinarySpecific) ...[
                    _buildModernInfoCard(
                      context,
                      'Veterinary Information',
                      Icons.pets_outlined,
                      UnifiedTheme.primaryGreen,
                      [
                        _buildInfoItem('Target Species', drug.targetSpecies.join(', '), Icons.pets),
                        if (drug.withdrawalPeriod.isNotEmpty)
                          _buildInfoItem('Withdrawal Period', drug.withdrawalPeriod, Icons.schedule),
                        if (drug.isControlled)
                          _buildInfoItem('Controlled Class', drug.controlledClass, Icons.security),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Clinical Information
                  _buildModernInfoCard(
                    context,
                    'Clinical & Pharmacological Information',
                    Icons.medical_information_outlined,
                    UnifiedTheme.goldAccent,
                    [
                      _buildExpandableInfoItem('Therapeutic Indication', drug.indication, Icons.healing),
                      _buildExpandableInfoItem('Dosage & Administration', drug.dosage, Icons.calculate),
                      _buildExpandableInfoItem('Mechanism of Action', drug.mechanism.isNotEmpty 
                        ? drug.mechanism 
                        : 'The active salt ${drug.genericName} works through specific molecular pathways to achieve therapeutic effects.',
                        Icons.psychology),
                      _buildExpandableInfoItem('Pharmacokinetics', drug.pharmacokinetics.isNotEmpty
                        ? drug.pharmacokinetics
                        : 'Absorption, distribution, metabolism, and excretion properties of ${drug.genericName}.',
                        Icons.timeline),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Safety Information
                  _buildModernInfoCard(
                    context,
                    'Safety Information',
                    Icons.warning_amber_outlined,
                    Colors.orange,
                    [
                      _buildExpandableInfoItem('Contraindications', drug.contraindication, Icons.block),
                      _buildExpandableInfoItem('Side Effects', drug.sideEffects, Icons.error_outline),
                      _buildExpandableInfoItem('Precautions', drug.precautions, Icons.shield),
                      _buildExpandableInfoItem('Drug Interactions', drug.interactions, Icons.compare_arrows),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Storage Information
                  if (drug.storage.isNotEmpty)
                    _buildModernInfoCard(
                      context,
                      'Storage & Handling',
                      Icons.inventory_2_outlined,
                      Colors.grey.shade600,
                      [
                        _buildExpandableInfoItem('Storage Requirements', drug.storage, Icons.thermostat),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: UnifiedTheme.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          drug.genericName.isNotEmpty ? drug.genericName : drug.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                UnifiedTheme.primaryGreen,
                UnifiedTheme.primaryGreen.withOpacity(0.8),
                UnifiedTheme.blueAccent.withOpacity(0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: -30,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              
              // Center content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.medication,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        drug.dosageForm,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
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
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickStatsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          _buildQuickStatCard(
            icon: Icons.category,
            label: 'Category',
            value: _formatCategoryName(drug.category),
            color: UnifiedTheme.blueAccent,
          ),
          const SizedBox(width: 12),
          _buildQuickStatCard(
            icon: Icons.route,
            label: 'Route',
            value: drug.route,
            color: UnifiedTheme.primaryGreen,
          ),
          const SizedBox(width: 12),
          _buildQuickStatCard(
            icon: Icons.pets,
            label: 'Species',
            value: '${drug.targetSpecies.length}',
            color: UnifiedTheme.goldAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoCard(
    BuildContext context,
    String title,
    IconData icon,
    Color accentColor,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withOpacity(0.1),
                  accentColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: UnifiedTheme.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableInfoItem(String label, String value, IconData icon) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            icon,
            size: 20,
            color: Colors.grey.shade600,
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: UnifiedTheme.primaryText,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ),
          ],
          childrenPadding: EdgeInsets.zero,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedTheme.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DrugCalculatorScreen(drug: drug),
                    ),
                  );
                },
                icon: const Icon(Icons.calculate),
                label: const Text('Calculate Dosage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UnifiedTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon!'),
                      backgroundColor: UnifiedTheme.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: UnifiedTheme.primaryGreen,
                  side: const BorderSide(color: UnifiedTheme.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
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