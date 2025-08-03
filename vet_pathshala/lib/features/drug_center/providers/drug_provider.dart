import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/drug_model.dart';
import '../services/drug_service.dart';

class DrugProvider with ChangeNotifier {
  // State variables
  List<DrugModel> _drugs = [];
  List<DrugModel> _filteredDrugs = [];
  List<String> _categories = [];
  List<String> _targetSpecies = [];
  List<String> _bookmarkedDrugIds = [];
  List<DrugCalculation> _calculations = [];
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  DocumentSnapshot? _lastDocument;
  bool _hasMoreData = true;

  // Filter state
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedSpecies;
  bool? _isVeterinaryOnly;
  
  // Getters
  List<DrugModel> get drugs => _filteredDrugs;
  List<String> get categories => _categories;
  List<String> get targetSpecies => _targetSpecies;
  List<String> get bookmarkedDrugIds => _bookmarkedDrugIds;
  List<DrugCalculation> get calculations => _calculations;
  
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get error => _error;

  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  String? get selectedSpecies => _selectedSpecies;
  bool? get isVeterinaryOnly => _isVeterinaryOnly;

  // Initialize provider
  Future<void> initialize() async {
    await loadCategories();
    await loadTargetSpecies();
    await loadDrugs();
  }

  // Load drugs with filters
  Future<void> loadDrugs({bool refresh = false}) async {
    if (_isLoading) return;

    try {
      if (refresh) {
        _isLoading = true;
        _lastDocument = null;
        _hasMoreData = true;
        _drugs.clear();
        _filteredDrugs.clear();
        notifyListeners();
      }

      final drugs = await DrugService.getDrugs(
        limit: 20,
        lastDocument: _lastDocument,
        category: _selectedCategory,
        searchTerm: _searchQuery.isNotEmpty ? _searchQuery : null,
        isVeterinarySpecific: _isVeterinaryOnly,
        targetSpecies: _selectedSpecies != null ? [_selectedSpecies!] : null,
      );

      if (drugs.isNotEmpty) {
        if (refresh) {
          _drugs = drugs;
        } else {
          _drugs.addAll(drugs);
        }
        
        // Update last document for pagination
        if (drugs.length == 20) {
          // This is a simplified approach - in a real app, you'd get the actual document
          _hasMoreData = true;
        } else {
          _hasMoreData = false;
        }
      } else {
        _hasMoreData = false;
      }

      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more drugs (pagination)
  Future<void> loadMoreDrugs() async {
    if (_isLoadingMore || !_hasMoreData) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      final drugs = await DrugService.getDrugs(
        limit: 20,
        lastDocument: _lastDocument,
        category: _selectedCategory,
        searchTerm: _searchQuery.isNotEmpty ? _searchQuery : null,
        isVeterinarySpecific: _isVeterinaryOnly,
        targetSpecies: _selectedSpecies != null ? [_selectedSpecies!] : null,
      );

      if (drugs.isNotEmpty) {
        _drugs.addAll(drugs);
        _applyFilters();
        
        if (drugs.length < 20) {
          _hasMoreData = false;
        }
      } else {
        _hasMoreData = false;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await DrugService.getDrugCategories();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading categories: $e');
      }
    }
  }

  // Load target species
  Future<void> loadTargetSpecies() async {
    try {
      _targetSpecies = await DrugService.getTargetSpecies();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading target species: $e');
      }
    }
  }

  // Load user bookmarks
  Future<void> loadBookmarks(String userId) async {
    try {
      _bookmarkedDrugIds = await DrugService.getUserBookmarks(userId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading bookmarks: $e');
      }
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String userId, String drugId) async {
    try {
      await DrugService.toggleBookmark(userId, drugId);
      
      // Update local state
      if (_bookmarkedDrugIds.contains(drugId)) {
        _bookmarkedDrugIds.remove(drugId);
      } else {
        _bookmarkedDrugIds.add(drugId);
      }
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check if drug is bookmarked
  bool isDrugBookmarked(String drugId) {
    return _bookmarkedDrugIds.contains(drugId);
  }

  // Search drugs
  void searchDrugs(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    loadDrugs(refresh: true);
  }

  // Filter by species
  void filterBySpecies(String? species) {
    _selectedSpecies = species;
    loadDrugs(refresh: true);
  }

  // Filter veterinary only
  void filterVeterinaryOnly(bool? veterinaryOnly) {
    _isVeterinaryOnly = veterinaryOnly;
    loadDrugs(refresh: true);
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedSpecies = null;
    _isVeterinaryOnly = null;
    loadDrugs(refresh: true);
  }

  // Apply local filters
  void _applyFilters() {
    _filteredDrugs = List.from(_drugs);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      _filteredDrugs = _filteredDrugs.where((drug) {
        return drug.name.toLowerCase().contains(searchLower) ||
               drug.genericName.toLowerCase().contains(searchLower) ||
               drug.brandName.toLowerCase().contains(searchLower) ||
               drug.indication.toLowerCase().contains(searchLower) ||
               drug.category.toLowerCase().contains(searchLower);
      }).toList();
    }
  }

  // Get drug by ID
  Future<DrugModel?> getDrugById(String drugId) async {
    try {
      return await DrugService.getDrugById(drugId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Drug calculation methods
  Map<String, dynamic> calculateDosage({
    required DrugModel drug,
    required double animalWeight,
    required String weightUnit,
    required String species,
    String? indication,
  }) {
    try {
      return DrugService.calculateDosage(
        drug: drug,
        animalWeight: animalWeight,
        weightUnit: weightUnit,
        species: species,
        indication: indication,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Save calculation
  Future<void> saveCalculation({
    required String userId,
    required DrugCalculation calculation,
  }) async {
    try {
      await DrugService.saveCalculation(
        userId: userId,
        calculation: calculation,
      );
      
      // Add to local calculations
      _calculations.insert(0, calculation);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Load user calculations
  Future<void> loadCalculations(String userId) async {
    try {
      _calculations = await DrugService.getUserCalculations(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get bookmarked drugs
  Future<List<DrugModel>> getBookmarkedDrugs(String userId) async {
    try {
      return await DrugService.getBookmarkedDrugs(userId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Seed sample data (for development)
  Future<void> seedSampleData() async {
    try {
      await DrugService.seedSampleDrugs();
      await loadDrugs(refresh: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}