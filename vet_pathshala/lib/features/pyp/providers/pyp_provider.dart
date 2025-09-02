import 'package:flutter/material.dart';
import '../../../shared/models/test_series_models.dart';
import '../models/pyp_model.dart';
import '../services/pyp_service.dart';

class PYPProvider extends ChangeNotifier {
  List<PYPModel> _pyps = [];
  List<PYPModel> _filteredPyps = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  int _selectedYear = 0;
  String _sortBy = 'year';

  // Getters
  List<PYPModel> get pyps => _pyps;
  List<PYPModel> get filteredPyps => _filteredPyps;
  List<PYPModel> get papers => _pyps; // Alias for backward compatibility
  List<PYPModel> get filteredPapers => _filteredPyps; // Alias for backward compatibility
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  int get selectedYear => _selectedYear;
  String get sortBy => _sortBy;
  
  // Mock categories for backward compatibility
  List<dynamic> get categories => [
    {'id': 'vet_anatomy', 'name': 'Veterinary Anatomy'},
    {'id': 'animal_physiology', 'name': 'Animal Physiology'},
    {'id': 'vet_medicine', 'name': 'Veterinary Medicine'},
    {'id': 'vet_pathology', 'name': 'Veterinary Pathology'},
    {'id': 'animal_breeding', 'name': 'Animal Breeding'},
  ];

  // Get available years
  List<int> get availableYears {
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => currentYear - index);
  }

  // Initialize PYP data
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadPYPs();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load PYP data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load PYPs
  Future<void> _loadPYPs() async {
    final pypService = PYPService();
    final papers = await pypService.getPapers();
    // Convert PYPPaper to PYPModel format
    _pyps = papers.map((paper) => PYPModel(
      id: paper.id,
      title: paper.title,
      year: paper.year,
      examType: paper.examType.toUpperCase(),
      category: paper.subject,
      targetRole: 'doctor', // Default for now
      uploadedAt: paper.uploadDate,
      questionIds: [],
      totalQuestions: paper.questions,
      totalMarks: paper.maxMarks,
      duration: paper.duration,
      isActive: true,
      paperUrl: paper.pdfUrl,
      metadata: {
        'subject': paper.subject,
        'topic': paper.topic,
        'difficulty': paper.difficulty,
        'tags': paper.tags,
        'downloads': paper.downloads,
        'rating': paper.rating,
      },
    )).toList();
    notifyListeners();
  }

  // Public method to load PYPs with role filter
  Future<void> loadPYPs(String userRole) async {
    _setLoading(true);
    try {
      await _loadPYPs();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load PYPs: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get PYPs for specific year
  Future<List<PYPModel>> getPYPsForYear(int year) async {
    try {
      return _pyps.where((pyp) => pyp.year == year).toList();
    } catch (e) {
      print('Error getting PYPs for year $year: $e');
      return [];
    }
  }

  // Get PYP count for year
  int getPYPCountForYear(int year) {
    return _pyps.where((pyp) => pyp.year == year).length;
  }

  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Set year filter
  void setYear(int year) {
    _selectedYear = year;
    _applyFilters();
    notifyListeners();
  }

  // Set sort option
  void setSortBy(String sortOption) {
    _sortBy = sortOption;
    _applyFilters();
    notifyListeners();
  }

  // Set subject filter (mock implementation)
  void setSubject(String subject) {
    // Mock implementation for backward compatibility
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedYear = 0;
    _sortBy = 'year';
    _applyFilters();
    notifyListeners();
  }

  // Get papers by year
  List<PYPModel> getPapersByYear(int year) {
    return _pyps.where((pyp) => pyp.year == year).toList();
  }

  // Download paper (mock implementation)
  Future<bool> downloadPaper(String paperId) async {
    try {
      // Mock implementation - in real app, would download PDF
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      _setError('Failed to download paper: $e');
      return false;
    }
  }

  // Rate paper (mock implementation)
  Future<void> ratePaper(String paperId, double rating) async {
    try {
      // Mock implementation - in real app, would save rating to Firebase
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _setError('Failed to rate paper: $e');
    }
  }

  // Apply filters and sorting
  void _applyFilters() {
    _filteredPyps = _pyps.where((pyp) {
      // Year filter
      if (_selectedYear > 0 && pyp.year != _selectedYear) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return pyp.title.toLowerCase().contains(query) ||
               pyp.category.toLowerCase().contains(query) ||
               (pyp.metadata['topics'] as List<dynamic>? ?? [])
                   .any((topic) => topic.toString().toLowerCase().contains(query));
      }

      return true;
    }).toList();

    // Apply sorting
    _filteredPyps.sort((a, b) {
      switch (_sortBy) {
        case 'year':
          return b.year.compareTo(a.year);
        case 'title':
          return a.title.compareTo(b.title);
        default:
          return b.year.compareTo(a.year);
      }
    });

    notifyListeners();
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