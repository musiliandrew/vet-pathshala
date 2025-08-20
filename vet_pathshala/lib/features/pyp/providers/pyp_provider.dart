import 'package:flutter/material.dart';
import '../models/pyp_model.dart';
import '../services/pyp_service.dart';

class PYPProvider extends ChangeNotifier {
  final PYPService _pypService = PYPService();
  
  List<PYPCategory> _categories = [];
  List<PYPPaper> _papers = [];
  List<PYPPaper> _filteredPapers = [];
  
  String _selectedCategoryId = '';
  String _selectedSubjectId = '';
  String _selectedTopic = '';
  int _selectedYear = 0;
  String _searchQuery = '';
  String _sortBy = 'year'; // year, rating, downloads
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PYPCategory> get categories => _categories;
  List<PYPPaper> get papers => _papers;
  List<PYPPaper> get filteredPapers => _filteredPapers;
  String get selectedCategoryId => _selectedCategoryId;
  String get selectedSubjectId => _selectedSubjectId;
  String get selectedTopic => _selectedTopic;
  int get selectedYear => _selectedYear;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get available years
  List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => currentYear - index);
  }

  // Initialize PYP data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadCategories();
      await _loadPapers();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load PYP data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> _loadCategories() async {
    _categories = await _pypService.getCategories();
    notifyListeners();
  }

  // Load papers
  Future<void> _loadPapers() async {
    _papers = await _pypService.getPapers();
    notifyListeners();
  }

  // Set category filter
  void setCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    _selectedSubjectId = '';
    _selectedTopic = '';
    _applyFilters();
    notifyListeners();
  }

  // Set subject filter
  void setSubject(String subjectId) {
    _selectedSubjectId = subjectId;
    _selectedTopic = '';
    _applyFilters();
    notifyListeners();
  }

  // Set topic filter
  void setTopic(String topic) {
    _selectedTopic = topic;
    _applyFilters();
    notifyListeners();
  }

  // Set year filter
  void setYear(int year) {
    _selectedYear = year;
    _applyFilters();
    notifyListeners();
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Set sort option
  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _selectedCategoryId = '';
    _selectedSubjectId = '';
    _selectedTopic = '';
    _selectedYear = 0;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Apply filters and sorting
  void _applyFilters() {
    _filteredPapers = _papers.where((paper) {
      // Category filter
      if (_selectedCategoryId.isNotEmpty) {
        final category = _categories.firstWhere(
          (cat) => cat.id == _selectedCategoryId,
          orElse: () => PYPCategory(id: '', name: '', icon: '', subjects: []),
        );
        
        if (category.id.isNotEmpty) {
          final hasSubject = category.subjects.any((subject) => 
            subject.name.toLowerCase() == paper.subject.toLowerCase()
          );
          if (!hasSubject) return false;
        }
      }

      // Subject filter
      if (_selectedSubjectId.isNotEmpty) {
        if (!paper.subject.toLowerCase().contains(_selectedSubjectId.toLowerCase())) {
          return false;
        }
      }

      // Topic filter
      if (_selectedTopic.isNotEmpty) {
        if (!paper.topic.toLowerCase().contains(_selectedTopic.toLowerCase())) {
          return false;
        }
      }

      // Year filter
      if (_selectedYear != 0) {
        if (paper.year != _selectedYear) return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!paper.title.toLowerCase().contains(query) &&
            !paper.subject.toLowerCase().contains(query) &&
            !paper.topic.toLowerCase().contains(query) &&
            !paper.tags.any((tag) => tag.toLowerCase().contains(query))) {
          return false;
        }
      }

      return true;
    }).toList();

    // Apply sorting
    _filteredPapers.sort((a, b) {
      switch (_sortBy) {
        case 'year':
          return b.year.compareTo(a.year);
        case 'rating':
          return b.rating.compareTo(a.rating);
        case 'downloads':
          return b.downloads.compareTo(a.downloads);
        case 'title':
          return a.title.compareTo(b.title);
        default:
          return b.year.compareTo(a.year);
      }
    });
  }

  // Get papers by subject
  List<PYPPaper> getPapersBySubject(String subject) {
    return _papers.where((paper) => 
      paper.subject.toLowerCase() == subject.toLowerCase()
    ).toList();
  }

  // Get papers by year
  List<PYPPaper> getPapersByYear(int year) {
    return _papers.where((paper) => paper.year == year).toList();
  }

  // Download paper
  Future<bool> downloadPaper(String paperId) async {
    try {
      final success = await _pypService.downloadPaper(paperId);
      if (success) {
        // Update download count
        final paperIndex = _papers.indexWhere((p) => p.id == paperId);
        if (paperIndex >= 0) {
          _papers[paperIndex] = PYPPaper(
            id: _papers[paperIndex].id,
            title: _papers[paperIndex].title,
            subject: _papers[paperIndex].subject,
            topic: _papers[paperIndex].topic,
            year: _papers[paperIndex].year,
            examType: _papers[paperIndex].examType,
            difficulty: _papers[paperIndex].difficulty,
            tags: _papers[paperIndex].tags,
            pdfUrl: _papers[paperIndex].pdfUrl,
            thumbnailUrl: _papers[paperIndex].thumbnailUrl,
            questions: _papers[paperIndex].questions,
            duration: _papers[paperIndex].duration,
            maxMarks: _papers[paperIndex].maxMarks,
            isPremium: _papers[paperIndex].isPremium,
            coinCost: _papers[paperIndex].coinCost,
            uploadDate: _papers[paperIndex].uploadDate,
            downloads: _papers[paperIndex].downloads + 1,
            rating: _papers[paperIndex].rating,
          );
          _applyFilters();
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('Failed to download paper: $e');
      return false;
    }
  }

  // Rate paper
  Future<void> ratePaper(String paperId, double rating) async {
    try {
      await _pypService.ratePaper(paperId, rating);
      // Update local data
      await _loadPapers();
      _applyFilters();
    } catch (e) {
      _setError('Failed to rate paper: $e');
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }
}