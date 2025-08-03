import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/unified_theme.dart';
import '../../../shared/models/drug_model.dart';
import '../providers/drug_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'drug_detail_screen.dart';

class DrugIndexScreen extends StatefulWidget {
  const DrugIndexScreen({super.key});

  @override
  State<DrugIndexScreen> createState() => _DrugIndexScreenState();
}

class _DrugIndexScreenState extends State<DrugIndexScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupScrollListener();
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final drugProvider = context.read<DrugProvider>();
      final authProvider = context.read<AuthProvider>();
      
      drugProvider.initialize();
      if (authProvider.currentUser != null) {
        drugProvider.loadBookmarks(authProvider.currentUser!.id);
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        context.read<DrugProvider>().loadMoreDrugs();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Drug Index',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showFiltersBottomSheet,
            icon: Consumer<DrugProvider>(
              builder: (context, drugProvider, child) {
                final hasActiveFilters = drugProvider.selectedCategory != null ||
                    drugProvider.selectedSpecies != null ||
                    drugProvider.isVeterinaryOnly != null;
                
                return Stack(
                  children: [
                    const Icon(Icons.filter_list),
                    if (hasActiveFilters)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: UnifiedTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search drugs by name, generic, or indication...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            context.read<DrugProvider>().searchDrugs('');
                          },
                          icon: const Icon(Icons.clear),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: UnifiedTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: UnifiedTheme.primaryGreen),
                  ),
                  filled: true,
                  fillColor: UnifiedTheme.surfaceColor,
                ),
                onChanged: (value) {
                  context.read<DrugProvider>().searchDrugs(value);
                },
              ),
            ),

            // Active Filters Chips
            Consumer<DrugProvider>(
              builder: (context, drugProvider, child) {
                final hasActiveFilters = drugProvider.selectedCategory != null ||
                    drugProvider.selectedSpecies != null ||
                    drugProvider.isVeterinaryOnly != null;

                if (!hasActiveFilters) return const SizedBox.shrink();

                return Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (drugProvider.selectedCategory != null)
                        _buildFilterChip(
                          label: _formatCategoryName(drugProvider.selectedCategory!),
                          onDeleted: () => drugProvider.filterByCategory(null),
                        ),
                      if (drugProvider.selectedSpecies != null)
                        _buildFilterChip(
                          label: drugProvider.selectedSpecies!,
                          onDeleted: () => drugProvider.filterBySpecies(null),
                        ),
                      if (drugProvider.isVeterinaryOnly == true)
                        _buildFilterChip(
                          label: 'Veterinary Only',
                          onDeleted: () => drugProvider.filterVeterinaryOnly(null),
                        ),
                      const SizedBox(width: 8),
                      ActionChip(
                        label: const Text(
                          'Clear All',
                          style: TextStyle(color: UnifiedTheme.redAccent),
                        ),
                        onPressed: drugProvider.clearFilters,
                        backgroundColor: UnifiedTheme.redAccent.withOpacity(0.1),
                        side: const BorderSide(color: UnifiedTheme.redAccent),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Drug List
            Expanded(
              child: Consumer<DrugProvider>(
                builder: (context, drugProvider, child) {
                  if (drugProvider.isLoading && drugProvider.drugs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading drugs...'),
                        ],
                      ),
                    );
                  }

                  if (drugProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: UnifiedTheme.redAccent,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading drugs',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            drugProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: UnifiedTheme.secondaryText),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              drugProvider.clearError();
                              drugProvider.loadDrugs(refresh: true);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (drugProvider.drugs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.medical_services_outlined,
                            size: 64,
                            color: UnifiedTheme.tertiaryText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No drugs found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(color: UnifiedTheme.secondaryText),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              // Seed sample data for development
                              drugProvider.seedSampleData();
                            },
                            child: const Text('Load Sample Data'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => drugProvider.loadDrugs(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: drugProvider.drugs.length + 
                          (drugProvider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= drugProvider.drugs.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final drug = drugProvider.drugs[index];
                        return _buildDrugCard(drug);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool value) {
          if (!value) {
            onDeleted();
          }
        },
        onDeleted: onDeleted,
        deleteIcon: const Icon(Icons.close, size: 16),
        backgroundColor: UnifiedTheme.primaryGreen.withOpacity(0.1),
        selectedColor: UnifiedTheme.primaryGreen.withOpacity(0.2),
        labelStyle: const TextStyle(color: UnifiedTheme.primaryGreen),
        deleteIconColor: UnifiedTheme.primaryGreen,
        side: const BorderSide(color: UnifiedTheme.primaryGreen),
        selected: true,
      ),
    );
  }

  Widget _buildDrugCard(DrugModel drug) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DrugDetailScreen(drug: drug),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              drug.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (drug.brandName.isNotEmpty && drug.brandName != drug.name)
                              Text(
                                drug.brandName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: UnifiedTheme.secondaryText,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Bookmark button
                      if (authProvider.currentUser != null)
                        Consumer<DrugProvider>(
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
                                color: isBookmarked ? UnifiedTheme.goldAccent : UnifiedTheme.tertiaryText,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category and Form
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatCategoryName(drug.category),
                          style: const TextStyle(
                            color: UnifiedTheme.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: UnifiedTheme.tertiaryText.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${drug.dosageForm} ${drug.strength}',
                          style: const TextStyle(
                            color: UnifiedTheme.secondaryText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (drug.isVeterinarySpecific)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'VET',
                            style: TextStyle(
                              color: UnifiedTheme.primaryGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Indication
                  Text(
                    drug.indication,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Target species (if veterinary)
                  if (drug.isVeterinarySpecific && drug.targetSpecies.isNotEmpty)
                    Text(
                      'Target: ${drug.targetSpecies.join(', ')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: UnifiedTheme.secondaryText,
                      ),
                    ),

                  // Price and action row
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (drug.price > 0)
                        Text(
                          '\$${drug.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: UnifiedTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DrugDetailScreen(drug: drug),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline, size: 16),
                        label: const Text('Details'),
                        style: TextButton.styleFrom(
                          foregroundColor: UnifiedTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFiltersBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: UnifiedTheme.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: UnifiedTheme.tertiaryText,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Filter Drugs',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          context.read<DrugProvider>().clearFilters();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Filters
                Expanded(
                  child: Consumer<DrugProvider>(
                    builder: (context, drugProvider, child) {
                      return ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Category filter
                          _buildFilterSection(
                            'Category',
                            DropdownButton<String?>(
                              value: drugProvider.selectedCategory,
                              hint: const Text('All Categories'),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All Categories'),
                                ),
                                ...drugProvider.categories.toSet().map((category) =>
                                  DropdownMenuItem<String?>(
                                    value: category,
                                    child: Text(_formatCategoryName(category)),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                drugProvider.filterByCategory(value);
                              },
                            ),
                          ),

                          // Species filter
                          _buildFilterSection(
                            'Target Species',
                            DropdownButton<String?>(
                              value: drugProvider.selectedSpecies,
                              hint: const Text('All Species'),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All Species'),
                                ),
                                ...drugProvider.targetSpecies.toSet().map((species) =>
                                  DropdownMenuItem<String?>(
                                    value: species,
                                    child: Text(species),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                drugProvider.filterBySpecies(value);
                              },
                            ),
                          ),

                          // Veterinary only filter
                          _buildFilterSection(
                            'Drug Type',
                            SwitchListTile(
                              title: const Text('Veterinary Specific Only'),
                              subtitle: const Text('Show only veterinary drugs'),
                              value: drugProvider.isVeterinaryOnly ?? false,
                              onChanged: (value) {
                                drugProvider.filterVeterinaryOnly(value ? true : null);
                              },
                              activeColor: UnifiedTheme.primaryGreen,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
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