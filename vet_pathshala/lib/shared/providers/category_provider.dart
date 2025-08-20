import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CategoryProvider() {
    loadCategories();
  }

  // Load categories from backend or use defaults
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _categoryService.fetchCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _categories = _categoryService.getDefaultCategories();
      print('❌ CategoryProvider error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get categories by their active status
  List<CategoryModel> getActiveCategories() {
    return _categories.where((category) => category.isActive).toList();
  }

  // Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  CategoryModel? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => category.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Add a new category
  Future<bool> addCategory(CategoryModel category) async {
    try {
      final success = await _categoryService.addCategory(category);
      if (success) {
        await loadCategories(); // Reload to get updated list
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update an existing category
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      final success = await _categoryService.updateCategory(category);
      if (success) {
        await loadCategories(); // Reload to get updated list
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      final success = await _categoryService.deleteCategory(categoryId);
      if (success) {
        await loadCategories(); // Reload to get updated list
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle category active status
  Future<bool> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      final success = await _categoryService.toggleCategoryStatus(categoryId, isActive);
      if (success) {
        await loadCategories(); // Reload to get updated list
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Reorder categories
  Future<bool> reorderCategories(List<CategoryModel> newOrder) async {
    try {
      final success = await _categoryService.reorderCategories(newOrder);
      if (success) {
        _categories = newOrder;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Start listening to real-time category changes
  void startListening() {
    _categoryService.watchCategories().listen(
      (categories) {
        _categories = categories;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error.toString();
        _categories = _categoryService.getDefaultCategories();
        notifyListeners();
      },
    );
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh categories
  Future<void> refresh() async {
    await loadCategories();
  }
}