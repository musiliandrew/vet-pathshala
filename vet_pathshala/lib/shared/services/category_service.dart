import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../../core/utils/firebase_availability.dart';

class CategoryService {
  static const String _collection = 'categories';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get default categories (fallback when backend is not available)
  List<CategoryModel> getDefaultCategories() {
    return [
      const CategoryModel(
        id: 'q_bank',
        name: 'Q Bank',
        label: 'Q Bank',
        iconData: Icons.quiz,
        iconCode: 'quiz',
        route: '/question_bank',
        order: 1,
      ),
      const CategoryModel(
        id: 'short_notes',
        name: 'Short Notes',
        label: 'Short Notes',
        iconData: Icons.note_alt,
        iconCode: 'note',
        route: '/short_notes',
        order: 2,
      ),
      const CategoryModel(
        id: 'lectures',
        name: 'Lectures',
        label: 'Lectures',
        iconData: Icons.video_library,
        iconCode: 'video',
        route: '/lectures',
        order: 3,
      ),
      const CategoryModel(
        id: 'gamification',
        name: 'Gamification',
        label: 'Gamification',
        iconData: Icons.gamepad,
        iconCode: 'game',
        route: '/gamification',
        order: 4,
      ),
      const CategoryModel(
        id: 'drug_centre',
        name: 'Drug Centre',
        label: 'Drug Centre',
        iconData: Icons.medication,
        iconCode: 'medication',
        route: '/drug_center',
        order: 5,
      ),
      const CategoryModel(
        id: 'quiz_pyp',
        name: 'Quiz & PYP',
        label: 'Quiz & PYP',
        iconData: Icons.quiz_outlined,
        iconCode: 'quiz_outlined',
        route: '/quiz',
        order: 6,
      ),
    ];
  }

  // Fetch categories from Firebase
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      if (!FirebaseAvailability.isAvailable) {
        print('🔥 Firebase not available, returning default categories');
        return getDefaultCategories();
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('📂 No categories found in Firestore, returning defaults');
        return getDefaultCategories();
      }

      final categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();

      print('✅ Loaded ${categories.length} categories from Firestore');
      return categories;
    } catch (e) {
      print('❌ Error fetching categories: $e');
      return getDefaultCategories();
    }
  }

  // Add a new category to Firebase
  Future<bool> addCategory(CategoryModel category) async {
    try {
      if (!FirebaseAvailability.isAvailable) {
        print('🔥 Firebase not available, cannot add category');
        return false;
      }

      await _firestore.collection(_collection).doc(category.id).set(category.toJson());
      print('✅ Category added successfully: ${category.name}');
      return true;
    } catch (e) {
      print('❌ Error adding category: $e');
      return false;
    }
  }

  // Update an existing category
  Future<bool> updateCategory(CategoryModel category) async {
    try {
      if (!FirebaseAvailability.isAvailable) {
        print('🔥 Firebase not available, cannot update category');
        return false;
      }

      await _firestore.collection(_collection).doc(category.id).update(category.toJson());
      print('✅ Category updated successfully: ${category.name}');
      return true;
    } catch (e) {
      print('❌ Error updating category: $e');
      return false;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      if (!FirebaseAvailability.isAvailable) {
        print('🔥 Firebase not available, cannot delete category');
        return false;
      }

      await _firestore.collection(_collection).doc(categoryId).delete();
      print('✅ Category deleted successfully: $categoryId');
      return true;
    } catch (e) {
      print('❌ Error deleting category: $e');
      return false;
    }
  }

  // Toggle category active status
  Future<bool> toggleCategoryStatus(String categoryId, bool isActive) async {
    try {
      if (!FirebaseAvailability.isAvailable) {
        print('🔥 Firebase not available, cannot toggle category status');
        return false;
      }

      await _firestore.collection(_collection).doc(categoryId).update({
        'isActive': isActive,
      });
      print('✅ Category status toggled: $categoryId -> $isActive');
      return true;
    } catch (e) {
      print('❌ Error toggling category status: $e');
      return false;
    }
  }

  // Reorder categories
  Future<bool> reorderCategories(List<CategoryModel> categories) async {
    try {
      if (!FirebaseAvailability.isAvailable) {
        print('🔥 Firebase not available, cannot reorder categories');
        return false;
      }

      final batch = _firestore.batch();
      for (int i = 0; i < categories.length; i++) {
        final docRef = _firestore.collection(_collection).doc(categories[i].id);
        batch.update(docRef, {'order': i + 1});
      }
      await batch.commit();
      print('✅ Categories reordered successfully');
      return true;
    } catch (e) {
      print('❌ Error reordering categories: $e');
      return false;
    }
  }

  // Listen to category changes in real-time
  Stream<List<CategoryModel>> watchCategories() {
    if (!FirebaseAvailability.isAvailable) {
      return Stream.value(getDefaultCategories());
    }

    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return getDefaultCategories();
      }

      return snapshot.docs
          .map((doc) => CategoryModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    }).handleError((error) {
      print('❌ Error watching categories: $error');
      return getDefaultCategories();
    });
  }
}