import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';

class EbooksScreen extends StatefulWidget {
  const EbooksScreen({super.key});

  @override
  State<EbooksScreen> createState() => _EbooksScreenState();
}

class _EbooksScreenState extends State<EbooksScreen> {
  String selectedCategory = 'all';
  String searchQuery = '';
  
  final categories = [
    {'id': 'all', 'name': 'All', 'icon': '📚'},
    {'id': 'veterinary', 'name': 'Veterinary', 'icon': '🐕'},
    {'id': 'pharmacy', 'name': 'Pharmacy', 'icon': '💊'},
    {'id': 'farming', 'name': 'Farming', 'icon': '🌾'},
  ];

  final ebooks = [
    {
      'id': 1,
      'title': 'Veterinary Pathology Fundamentals',
      'author': 'Dr. Sarah Johnson',
      'category': 'veterinary',
      'price': '₹299',
      'originalPrice': '₹499',
      'rating': 4.8,
      'reviews': 156,
      'cover': '📖',
      'description': 'Comprehensive guide to veterinary pathology with detailed case studies',
      'pages': 450,
      'language': 'English',
      'isBundle': false,
    },
    {
      'id': 2,
      'title': 'Modern Drug Formulations',
      'author': 'Prof. Michael Chen',
      'category': 'pharmacy',
      'price': '₹399',
      'originalPrice': '₹699',
      'rating': 4.6,
      'reviews': 89,
      'cover': '💊',
      'description': 'Latest advances in pharmaceutical formulations and drug delivery',
      'pages': 380,
      'language': 'English',
      'isBundle': false,
    },
    {
      'id': 3,
      'title': 'Complete Veterinary Bundle',
      'author': 'Multiple Authors',
      'category': 'veterinary',
      'price': '₹999',
      'originalPrice': '₹2499',
      'rating': 4.9,
      'reviews': 234,
      'cover': '📚',
      'description': 'Complete collection of 15 veterinary textbooks',
      'pages': '6000+',
      'language': 'English',
      'isBundle': true,
    },
    {
      'id': 4,
      'title': 'Animal Nutrition Guide',
      'author': 'Dr. Emily Davis',
      'category': 'farming',
      'price': '₹199',
      'originalPrice': '₹299',
      'rating': 4.5,
      'reviews': 67,
      'cover': '🌾',
      'description': 'Essential nutrition principles for livestock and poultry',
      'pages': 280,
      'language': 'English',
      'isBundle': false,
    },
  ];

  List get filteredEbooks {
    return ebooks.where((book) {
      final matchesCategory = selectedCategory == 'all' || book['category'] == selectedCategory;
      final matchesSearch = book['title'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                          book['author'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UnifiedTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: UnifiedTheme.cardBackground,
              child: Column(
                children: [
                  // Top Header
                  Padding(
                    padding: const EdgeInsets.all(UnifiedTheme.spacingL),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: UnifiedTheme.secondaryText,
                            size: UnifiedTheme.iconM,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'E-book Library',
                            textAlign: TextAlign.center,
                            style: UnifiedTheme.headerSmall,
                          ),
                        ),
                        const Icon(
                          Icons.search,
                          color: UnifiedTheme.secondaryText,
                          size: UnifiedTheme.iconM,
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL, vertical: UnifiedTheme.spacingM),
                    child: Container(
                      decoration: UnifiedTheme.elevatedCardDecoration,
                      child: TextField(
                        decoration: UnifiedTheme.searchInputDecoration.copyWith(
                          hintText: 'Search books, authors...',
                        ),
                        onChanged: (value) => setState(() => searchQuery = value),
                      ),
                    ),
                  ),

                  // Category Tabs
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = selectedCategory == category['id'];
                        
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedCategory = category['id'] as String),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL, vertical: UnifiedTheme.spacingS),
                              decoration: isSelected ? UnifiedTheme.selectedChipDecoration : UnifiedTheme.unselectedChipDecoration,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    category['icon'] as String,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: UnifiedTheme.spacingXS),
                                  Text(
                                    category['name'] as String,
                                    style: UnifiedTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? UnifiedTheme.darkGreen : UnifiedTheme.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: UnifiedTheme.spacingS),
                ],
              ),
            ),

            // Featured Banner
            Container(
              margin: const EdgeInsets.all(UnifiedTheme.spacingL),
              padding: const EdgeInsets.all(UnifiedTheme.spacingL),
              decoration: UnifiedTheme.featureCardDecoration(UnifiedTheme.primaryGreen),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('📚', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'Special Offer',
                              style: UnifiedTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get 40% off on all veterinary bundles',
                          style: UnifiedTheme.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: UnifiedTheme.spacingS),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL, vertical: UnifiedTheme.spacingS),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                          ),
                          child: Text(
                            'View Deals',
                            style: UnifiedTheme.bodyMedium.copyWith(
                              color: UnifiedTheme.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('🎉', style: TextStyle(fontSize: 32)),
                ],
              ),
            ),

            // Books List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingL),
                itemCount: filteredEbooks.length,
                itemBuilder: (context, index) {
                  final book = filteredEbooks[index];
                  return _buildBookCard(book);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return UnifiedTheme.buildCard(
      margin: const EdgeInsets.only(bottom: UnifiedTheme.spacingL),
      padding: const EdgeInsets.all(UnifiedTheme.spacingL),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: UnifiedTheme.lightBorder,
                  borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                ),
                child: Center(
                  child: Text(
                    book['cover'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              
              const SizedBox(width: UnifiedTheme.spacingL),
              
              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book['title'] as String,
                            style: UnifiedTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (book['isBundle'] as bool)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: UnifiedTheme.spacingS, vertical: 2),
                            decoration: BoxDecoration(
                              color: UnifiedTheme.goldAccent,
                              borderRadius: BorderRadius.circular(UnifiedTheme.radiusM),
                            ),
                            child: const Text(
                              'Bundle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: UnifiedTheme.spacingXS),
                    
                    Text(
                      'by ${book['author']}',
                      style: UnifiedTheme.bodySmall.copyWith(
                        color: UnifiedTheme.secondaryText,
                      ),
                    ),
                    
                    const SizedBox(height: UnifiedTheme.spacingS),
                    
                    // Rating
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              Icons.star,
                              size: 12,
                              color: i < (book['rating'] as double).floor() 
                                  ? UnifiedTheme.goldAccent 
                                  : UnifiedTheme.borderColor,
                            );
                          }),
                        ),
                        const SizedBox(width: UnifiedTheme.spacingXS),
                        Text(
                          '${book['rating']} (${book['reviews']})',
                          style: UnifiedTheme.bodySmall.copyWith(
                            color: UnifiedTheme.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: UnifiedTheme.spacingS),
                    
                    // Price
                    Row(
                      children: [
                        Text(
                          book['price'] as String,
                          style: UnifiedTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: UnifiedTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: UnifiedTheme.spacingS),
                        Text(
                          book['originalPrice'] as String,
                          style: UnifiedTheme.bodyMedium.copyWith(
                            color: UnifiedTheme.tertiaryText,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: UnifiedTheme.spacingS),
                    
                    // Quick Info
                    Row(
                      children: [
                        const Text('📄', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: UnifiedTheme.spacingXS),
                        Text(
                          '${book['pages']} pages',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('🌐', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: UnifiedTheme.spacingXS),
                        Text(
                          book['language'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            book['description'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: UnifiedTheme.spacingL),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: UnifiedTheme.spacingM),
                  decoration: BoxDecoration(
                    color: UnifiedTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                  ),
                  child: const Text(
                    'Buy Now',
                    textAlign: TextAlign.center,
                    style: UnifiedTheme.buttonText,
                  ),
                ),
              ),
              const SizedBox(width: UnifiedTheme.spacingS),
              Container(
                padding: const EdgeInsets.all(UnifiedTheme.spacingM),
                decoration: BoxDecoration(
                  border: Border.all(color: UnifiedTheme.borderColor),
                  borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  size: UnifiedTheme.iconS,
                  color: UnifiedTheme.tertiaryText,
                ),
              ),
              const SizedBox(width: UnifiedTheme.spacingS),
              Container(
                padding: const EdgeInsets.all(UnifiedTheme.spacingM),
                decoration: BoxDecoration(
                  border: Border.all(color: UnifiedTheme.borderColor),
                  borderRadius: BorderRadius.circular(UnifiedTheme.radiusS),
                ),
                child: const Icon(
                  Icons.share,
                  size: UnifiedTheme.iconS,
                  color: UnifiedTheme.tertiaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}