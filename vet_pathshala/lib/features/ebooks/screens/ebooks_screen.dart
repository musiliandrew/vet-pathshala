import 'package:flutter/material.dart';
import '../../../core/theme/unified_theme.dart';
import '../models/ebook_model.dart';

class EBooksScreen extends StatefulWidget {
  const EBooksScreen({super.key});

  @override
  State<EBooksScreen> createState() => _EBooksScreenState();
}

class _EBooksScreenState extends State<EBooksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedDifficulty = 'all';
  List<EBook> _filteredBooks = [];
  List<EBook> _allBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    
    // Simulate loading books from Firestore
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data for demonstration
    _allBooks = _getMockBooks();
    _filteredBooks = _allBooks;
    
    setState(() => _isLoading = false);
  }

  List<EBook> _getMockBooks() {
    return [
      EBook(
        id: '1',
        title: 'Veterinary Anatomy Atlas',
        author: 'Dr. Smith & Dr. Johnson',
        description: 'Comprehensive atlas of veterinary anatomy with detailed illustrations and explanations.',
        category: 'anatomy',
        totalPages: 450,
        fileSize: 15.2,
        tags: ['anatomy', 'illustrations', 'reference'],
        rating: 4.8,
        reviewCount: 124,
        isPremium: true,
        publishedDate: DateTime(2023, 1, 15),
        createdAt: DateTime.now(),
        difficulty: 'intermediate',
      ),
      EBook(
        id: '2',
        title: 'Small Animal Surgery Guide',
        author: 'Dr. Martinez',
        description: 'Step-by-step guide to common small animal surgical procedures.',
        category: 'surgery',
        totalPages: 320,
        fileSize: 8.7,
        tags: ['surgery', 'procedures', 'guide'],
        rating: 4.6,
        reviewCount: 89,
        isPremium: false,
        publishedDate: DateTime(2023, 3, 10),
        createdAt: DateTime.now(),
        difficulty: 'advanced',
      ),
      EBook(
        id: '3',
        title: 'Veterinary Pharmacology Basics',
        author: 'Dr. Chen & Dr. Patel',
        description: 'Essential pharmacology concepts for veterinary students and practitioners.',
        category: 'pharmacology',
        totalPages: 280,
        fileSize: 6.3,
        tags: ['pharmacology', 'drugs', 'basics'],
        rating: 4.7,
        reviewCount: 67,
        isPremium: false,
        publishedDate: DateTime(2023, 5, 22),
        createdAt: DateTime.now(),
        difficulty: 'beginner',
      ),
      EBook(
        id: '4',
        title: 'Animal Nutrition Handbook',
        author: 'Dr. Williams',
        description: 'Complete guide to animal nutrition across different species.',
        category: 'nutrition',
        totalPages: 380,
        fileSize: 12.1,
        tags: ['nutrition', 'feeding', 'handbook'],
        rating: 4.5,
        reviewCount: 45,
        isPremium: true,
        publishedDate: DateTime(2023, 7, 8),
        createdAt: DateTime.now(),
        difficulty: 'intermediate',
      ),
    ];
  }

  void _filterBooks() {
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        final matchesSearch = _searchController.text.isEmpty ||
            book.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            book.author.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            book.tags.any((tag) => tag.toLowerCase().contains(_searchController.text.toLowerCase()));

        final matchesCategory = _selectedCategory == 'all' || book.category == _selectedCategory;

        final matchesDifficulty = _selectedDifficulty == 'all' || book.difficulty == _selectedDifficulty;

        return matchesSearch && matchesCategory && matchesDifficulty;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('E-Books'),
        backgroundColor: UnifiedTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: UnifiedTheme.primaryGreen,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'All Books'),
                Tab(text: 'My Library'),
                Tab(text: 'Categories'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllBooksTab(),
          _buildMyLibraryTab(),
          _buildCategoriesTab(),
        ],
      ),
    );
  }

  Widget _buildAllBooksTab() {
    return Column(
      children: [
        // Search and Filters
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search books, authors, topics...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (_) => _filterBooks(),
              ),
              
              const SizedBox(height: 12),
              
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Category', _selectedCategory, [
                      'all', 'anatomy', 'surgery', 'medicine', 'pharmacology', 'nutrition'
                    ]),
                    const SizedBox(width: 8),
                    _buildFilterChip('Difficulty', _selectedDifficulty, [
                      'all', 'beginner', 'intermediate', 'advanced'
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Books list
        Expanded(
          child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _filteredBooks.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredBooks.length,
                      itemBuilder: (context, index) {
                        return _buildBookCard(_filteredBooks[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildMyLibraryTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Your Library is Empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Download books to read offline',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final categories = EBookCategory.getDefaultCategories();
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildFilterChip(String label, String selectedValue, List<String> options) {
    return PopupMenuButton<String>(
      child: Chip(
        label: Text(
          '$label: ${selectedValue == "all" ? "All" : selectedValue}',
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: Colors.grey.shade200,
        deleteIcon: selectedValue != 'all' ? const Icon(Icons.clear, size: 16) : null,
        onDeleted: selectedValue != 'all' ? () {
          setState(() {
            if (label == 'Category') _selectedCategory = 'all';
            if (label == 'Difficulty') _selectedDifficulty = 'all';
          });
          _filterBooks();
        } : null,
      ),
      onSelected: (value) {
        setState(() {
          if (label == 'Category') _selectedCategory = value;
          if (label == 'Difficulty') _selectedDifficulty = value;
        });
        _filterBooks();
      },
      itemBuilder: (context) => options.map((option) => PopupMenuItem(
        value: option,
        child: Text(option == 'all' ? 'All' : option),
      )).toList(),
    );
  }

  Widget _buildBookCard(EBook book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showBookDetails(book),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.book, size: 40, color: Colors.grey),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Book details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Premium badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (book.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: UnifiedTheme.goldAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Author
                    Text(
                      book.author,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      book.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Stats
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              ' (${book.reviewCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Pages
                        Text(
                          '${book.totalPages} pages',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // File size
                        Text(
                          book.fileSizeDisplay,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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

  Widget _buildCategoryCard(EBookCategory category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedCategory = category.id;
            _tabController.animateTo(0); // Switch to All Books tab
          });
          _filterBooks();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: UnifiedTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.iconName),
                      color: UnifiedTheme.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${category.bookCount}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                category.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Text(
                category.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No books found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'anatomy':
        return Icons.pets;
      case 'surgery':
        return Icons.medical_services;
      case 'medicine':
        return Icons.local_hospital;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'nutrition':
        return Icons.restaurant;
      case 'reproduction':
        return Icons.favorite;
      default:
        return Icons.book;
    }
  }

  void _showBookDetails(EBook book) {
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
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Book info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 120,
                            height: 160,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.book, size: 60, color: Colors.grey),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.author,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 20, color: Colors.orange.shade400),
                                  const SizedBox(width: 4),
                                  Text('${book.rating} (${book.reviewCount} reviews)'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.pages, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text('${book.totalPages} pages'),
                                  const SizedBox(width: 12),
                                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 4),
                                  Text(book.estimatedReadTime),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      book.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: book.isPremium ? null : () {
                              // Implement read action
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening book reader...')),
                              );
                            },
                            icon: const Icon(Icons.menu_book),
                            label: Text(book.isPremium ? 'Premium Required' : 'Read Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: UnifiedTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Implement download action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Download started...')),
                            );
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}