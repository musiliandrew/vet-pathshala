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
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with dark green theme
            _buildHeader(context),
            
            // Main content
            Expanded(
              child: _buildMainContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [UnifiedTheme.primaryGreen, UnifiedTheme.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: UnifiedTheme.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(UnifiedTheme.spacingL),
        child: Column(
          children: [
            // Header row with title and filter
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: UnifiedTheme.spacingM),
                Expanded(
                  child: Text(
                    'Drug Index',
                    style: UnifiedTheme.headerLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showFiltersBottomSheet,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Consumer<DrugProvider>(
                      builder: (context, drugProvider, child) {
                        final hasActiveFilters = drugProvider.selectedCategory != null ||
                            drugProvider.selectedSpecies != null ||
                            drugProvider.isVeterinaryOnly != null;
                        
                        return Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.filter_list,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            if (hasActiveFilters)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: UnifiedTheme.goldAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UnifiedTheme.spacingM),
            
            // Subtitle
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Comprehensive veterinary drug database',
                style: UnifiedTheme.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          margin: const EdgeInsets.all(UnifiedTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
            border: Border.all(color: UnifiedTheme.borderColor),
            boxShadow: UnifiedTheme.cardShadow,
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search drugs by name, generic, or indication...',
              hintStyle: UnifiedTheme.bodyMedium.copyWith(
                color: UnifiedTheme.tertiaryText,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: UnifiedTheme.primaryGreen,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        context.read<DrugProvider>().searchDrugs('');
                      },
                      icon: Icon(
                        Icons.clear,
                        color: UnifiedTheme.secondaryText,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: UnifiedTheme.spacingM,
                vertical: UnifiedTheme.spacingM,
              ),
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
              margin: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL),
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
                  GestureDetector(
                    onTap: drugProvider.clearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: UnifiedTheme.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: UnifiedTheme.redAccent),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear_all,
                            size: 16,
                            color: UnifiedTheme.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Clear All',
                            style: UnifiedTheme.bodySmall.copyWith(
                              color: UnifiedTheme.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: UnifiedTheme.spacingM),

        // Drug List
        Expanded(
          child: Consumer<DrugProvider>(
            builder: (context, drugProvider, child) {
              if (drugProvider.isLoading && drugProvider.drugs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              UnifiedTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: UnifiedTheme.spacingL),
                      Text(
                        'Loading drugs...',
                        style: UnifiedTheme.bodyLarge.copyWith(
                          color: UnifiedTheme.primaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (drugProvider.error != null) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(UnifiedTheme.spacingL),
                    padding: const EdgeInsets.all(UnifiedTheme.spacingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
                      border: Border.all(color: UnifiedTheme.redAccent.withOpacity(0.3)),
                      boxShadow: UnifiedTheme.cardShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: UnifiedTheme.redAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            size: 32,
                            color: UnifiedTheme.redAccent,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingM),
                        Text(
                          'Error loading drugs',
                          style: UnifiedTheme.headerMedium.copyWith(
                            color: UnifiedTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingS),
                        Text(
                          drugProvider.error!,
                          textAlign: TextAlign.center,
                          style: UnifiedTheme.bodyMedium.copyWith(
                            color: UnifiedTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingL),
                        ElevatedButton(
                          onPressed: () {
                            drugProvider.clearError();
                            drugProvider.loadDrugs(refresh: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UnifiedTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (drugProvider.drugs.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(UnifiedTheme.spacingL),
                    padding: const EdgeInsets.all(UnifiedTheme.spacingL),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
                      border: Border.all(color: UnifiedTheme.borderColor),
                      boxShadow: UnifiedTheme.cardShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            size: 40,
                            color: UnifiedTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingL),
                        Text(
                          'No drugs found',
                          style: UnifiedTheme.headerMedium.copyWith(
                            color: UnifiedTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingS),
                        Text(
                          'Try adjusting your search or filters',
                          style: UnifiedTheme.bodyMedium.copyWith(
                            color: UnifiedTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingL),
                        ElevatedButton(
                          onPressed: () {
                            drugProvider.seedSampleData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UnifiedTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
                            ),
                          ),
                          child: const Text('Load Sample Data'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => drugProvider.loadDrugs(refresh: true),
                color: UnifiedTheme.primaryGreen,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(UnifiedTheme.spacingL),
                  itemCount: drugProvider.drugs.length + 
                      (drugProvider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= drugProvider.drugs.length) {
                      return Container(
                        padding: const EdgeInsets.all(UnifiedTheme.spacingL),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              UnifiedTheme.primaryGreen,
                            ),
                          ),
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
    );
  }


  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: UnifiedTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: UnifiedTheme.primaryGreen),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: UnifiedTheme.bodySmall.copyWith(
                color: UnifiedTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close,
                size: 16,
                color: UnifiedTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugCard(DrugModel drug) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
            border: Border.all(color: UnifiedTheme.borderColor),
            boxShadow: UnifiedTheme.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DrugDetailScreen(drug: drug),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
              child: Padding(
                padding: const EdgeInsets.all(UnifiedTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with drug icon and bookmark
                    Row(
                      children: [
                        // Drug icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [UnifiedTheme.primaryGreen, UnifiedTheme.lightGreen],
                            ),
                            borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
                          ),
                          child: const Icon(
                            Icons.medication,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: UnifiedTheme.spacingM),
                        
                        // Drug name and brand
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                drug.name,
                                style: UnifiedTheme.headerSmall.copyWith(
                                  color: UnifiedTheme.primaryText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (drug.brandName.isNotEmpty && drug.brandName != drug.name)
                                Text(
                                  drug.brandName,
                                  style: UnifiedTheme.bodyMedium.copyWith(
                                    color: UnifiedTheme.secondaryText,
                                    fontSize: 13,
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
                              return GestureDetector(
                                onTap: () {
                                  drugProvider.toggleBookmark(
                                    authProvider.currentUser!.id,
                                    drug.id,
                                  );
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isBookmarked 
                                        ? UnifiedTheme.goldAccent.withOpacity(0.1)
                                        : UnifiedTheme.lightBackground,
                                    borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                                    border: Border.all(
                                      color: isBookmarked 
                                          ? UnifiedTheme.goldAccent
                                          : UnifiedTheme.borderColor,
                                    ),
                                  ),
                                  child: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: isBookmarked 
                                        ? UnifiedTheme.goldAccent 
                                        : UnifiedTheme.tertiaryText,
                                    size: 18,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: UnifiedTheme.spacingM),

                    // Category, Form, and VET badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: UnifiedTheme.primaryGreen.withOpacity(0.3)),
                          ),
                          child: Text(
                            _formatCategoryName(drug.category),
                            style: UnifiedTheme.bodySmall.copyWith(
                              color: UnifiedTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.lightBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: UnifiedTheme.borderColor),
                          ),
                          child: Text(
                            '${drug.dosageForm} ${drug.strength}',
                            style: UnifiedTheme.bodySmall.copyWith(
                              color: UnifiedTheme.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (drug.isVeterinarySpecific)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [UnifiedTheme.blueAccent, UnifiedTheme.blueAccent.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'VETERINARY',
                              style: UnifiedTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: UnifiedTheme.spacingM),

                    // Indication
                    Text(
                      drug.indication,
                      style: UnifiedTheme.bodyMedium.copyWith(
                        color: UnifiedTheme.primaryText,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Target species (if veterinary)
                    if (drug.isVeterinarySpecific && drug.targetSpecies.isNotEmpty) ...[
                      const SizedBox(height: UnifiedTheme.spacingS),
                      Row(
                        children: [
                          Icon(
                            Icons.pets,
                            size: 14,
                            color: UnifiedTheme.secondaryText,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Target: ${drug.targetSpecies.join(', ')}',
                              style: UnifiedTheme.bodySmall.copyWith(
                                color: UnifiedTheme.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Bottom row with price and action button
                    const SizedBox(height: UnifiedTheme.spacingM),
                    Container(
                      padding: const EdgeInsets.only(top: UnifiedTheme.spacingS),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: UnifiedTheme.borderColor)),
                      ),
                      child: Row(
                        children: [
                          if (drug.price > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: UnifiedTheme.goldAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '\$${drug.price.toStringAsFixed(2)}',
                                style: UnifiedTheme.bodyMedium.copyWith(
                                  color: UnifiedTheme.goldAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [UnifiedTheme.primaryGreen, UnifiedTheme.lightGreen],
                              ),
                              borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DrugDetailScreen(drug: drug),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Details',
                                        style: UnifiedTheme.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, UnifiedTheme.lightBackground],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: UnifiedTheme.primaryGreen.withOpacity(0.3),
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
                        style: UnifiedTheme.headerMedium.copyWith(
                          color: UnifiedTheme.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          context.read<DrugProvider>().clearFilters();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: UnifiedTheme.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
                            border: Border.all(color: UnifiedTheme.redAccent.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Clear All',
                            style: UnifiedTheme.bodyMedium.copyWith(
                              color: UnifiedTheme.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
      margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingL),
      padding: const EdgeInsets.all(UnifiedTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
        border: Border.all(color: UnifiedTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: UnifiedTheme.headerSmall.copyWith(
              color: UnifiedTheme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: UnifiedTheme.spacingS),
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