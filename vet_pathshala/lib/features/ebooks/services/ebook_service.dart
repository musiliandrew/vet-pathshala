import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../shared/models/ebook_models.dart';
import '../../../core/utils/firebase_availability.dart';

class EbookService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<EbookModel>> getEbooks({
    String? userRole,
    EbookCategory? category,
    EbookType? type,
    AccessLevel? accessLevel,
    int limit = 20,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('📚 EbookService: Fetching ebooks with filters');
      
      Query query = _firestore
          .collection('ebooks')
          .where('isActive', isEqualTo: true);

      if (userRole != null) {
        query = query.where('targetRoles', arrayContains: userRole);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (accessLevel != null) {
        query = query.where('accessLevel', isEqualTo: accessLevel.name);
      }

      final snapshot = await query
          .orderBy('rating', descending: true)
          .orderBy('downloadCount', descending: true)
          .limit(limit)
          .get();

      final ebooks = snapshot.docs
          .map((doc) => EbookModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ EbookService: Retrieved ${ebooks.length} ebooks');
      return ebooks;
    } catch (e) {
      debugPrint('❌ EbookService: Error fetching ebooks: $e');
      throw Exception('Failed to fetch ebooks: $e');
    }
  }

  Future<EbookModel?> getEbookById(String ebookId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('📚 EbookService: Fetching ebook: $ebookId');
      
      final doc = await _firestore
          .collection('ebooks')
          .doc(ebookId)
          .get();

      if (doc.exists) {
        final ebook = EbookModel.fromFirestore(doc);
        debugPrint('✅ EbookService: Ebook found: ${ebook.title}');
        return ebook;
      }

      debugPrint('⚠️ EbookService: Ebook not found: $ebookId');
      return null;
    } catch (e) {
      debugPrint('❌ EbookService: Error fetching ebook: $e');
      throw Exception('Failed to fetch ebook: $e');
    }
  }

  Future<List<EbookModel>> searchEbooks({
    required String query,
    String? userRole,
    EbookCategory? category,
    int limit = 20,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🔍 EbookService: Searching ebooks for: $query');
      
      Query firestoreQuery = _firestore
          .collection('ebooks')
          .where('isActive', isEqualTo: true);

      if (userRole != null) {
        firestoreQuery = firestoreQuery.where('targetRoles', arrayContains: userRole);
      }

      if (category != null) {
        firestoreQuery = firestoreQuery.where('category', isEqualTo: category.name);
      }

      final snapshot = await firestoreQuery.limit(100).get();
      
      final ebooks = snapshot.docs
          .map((doc) => EbookModel.fromFirestore(doc))
          .where((ebook) =>
              ebook.title.toLowerCase().contains(query.toLowerCase()) ||
              ebook.description.toLowerCase().contains(query.toLowerCase()) ||
              ebook.author.toLowerCase().contains(query.toLowerCase()))
          .take(limit)
          .toList();

      debugPrint('✅ EbookService: Search found ${ebooks.length} ebooks');
      return ebooks;
    } catch (e) {
      debugPrint('❌ EbookService: Error searching ebooks: $e');
      throw Exception('Failed to search ebooks: $e');
    }
  }

  Future<List<EbookModel>> getFeaturedEbooks(String? userRole, {int limit = 10}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('⭐ EbookService: Fetching featured ebooks for role: $userRole');
      
      Query query = _firestore
          .collection('ebooks')
          .where('isActive', isEqualTo: true);

      if (userRole != null) {
        query = query.where('targetRoles', arrayContains: userRole);
      }

      final snapshot = await query
          .orderBy('rating', descending: true)
          .orderBy('downloadCount', descending: true)
          .limit(limit)
          .get();

      final ebooks = snapshot.docs
          .map((doc) => EbookModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ EbookService: Retrieved ${ebooks.length} featured ebooks');
      return ebooks;
    } catch (e) {
      debugPrint('❌ EbookService: Error fetching featured ebooks: $e');
      throw Exception('Failed to fetch featured ebooks: $e');
    }
  }

  Future<UserEbookModel?> getUserEbookProgress(String userId, String ebookId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('📖 EbookService: Fetching reading progress for user: $userId, ebook: $ebookId');
      
      final snapshot = await _firestore
          .collection('user_ebook_progress')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final progress = UserEbookModel.fromFirestore(snapshot.docs.first);
        debugPrint('✅ EbookService: Reading progress found: ${progress.readingProgress * 100}%');
        return progress;
      }

      debugPrint('⚠️ EbookService: No reading progress found');
      return null;
    } catch (e) {
      debugPrint('❌ EbookService: Error fetching reading progress: $e');
      throw Exception('Failed to fetch reading progress: $e');
    }
  }

  Future<UserEbookModel> updateReadingProgress({
    required String userId,
    required String ebookId,
    required int currentPage,
    required double readingProgress,
    int? additionalReadingTime,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('📖 EbookService: Updating reading progress - Page: $currentPage, Progress: ${readingProgress * 100}%');
      
      final existingProgress = await getUserEbookProgress(userId, ebookId);
      
      if (existingProgress != null) {
        // Update existing progress
        final updateData = {
          'currentPage': currentPage,
          'readingProgress': readingProgress,
          'lastReadAt': FieldValue.serverTimestamp(),
        };

        if (additionalReadingTime != null) {
          updateData['totalReadingTime'] = FieldValue.increment(additionalReadingTime);
        }

        await _firestore
            .collection('user_ebook_progress')
            .doc(existingProgress.id)
            .update(updateData);

        final updatedProgress = UserEbookModel(
          id: existingProgress.id,
          userId: userId,
          ebookId: ebookId,
          accessedAt: existingProgress.accessedAt,
          downloadedAt: existingProgress.downloadedAt,
          currentPage: currentPage,
          readingProgress: readingProgress,
          isBookmarked: existingProgress.isBookmarked,
          isDownloaded: existingProgress.isDownloaded,
          lastReadAt: DateTime.now(),
          totalReadingTime: existingProgress.totalReadingTime + (additionalReadingTime ?? 0),
          readingData: existingProgress.readingData,
        );

        debugPrint('✅ EbookService: Reading progress updated');
        notifyListeners();
        return updatedProgress;
      } else {
        // Create new progress record
        final newProgress = UserEbookModel(
          id: '',
          userId: userId,
          ebookId: ebookId,
          accessedAt: DateTime.now(),
          currentPage: currentPage,
          readingProgress: readingProgress,
          lastReadAt: DateTime.now(),
          totalReadingTime: additionalReadingTime ?? 0,
        );

        final docRef = await _firestore
            .collection('user_ebook_progress')
            .add(newProgress.toFirestore());

        // Increment ebook access count
        await _firestore.collection('ebooks').doc(ebookId).update({
          'downloadCount': FieldValue.increment(1),
        });

        final createdProgress = UserEbookModel(
          id: docRef.id,
          userId: userId,
          ebookId: ebookId,
          accessedAt: DateTime.now(),
          currentPage: currentPage,
          readingProgress: readingProgress,
          lastReadAt: DateTime.now(),
          totalReadingTime: additionalReadingTime ?? 0,
        );

        debugPrint('✅ EbookService: Reading progress created with ID: ${docRef.id}');
        notifyListeners();
        return createdProgress;
      }
    } catch (e) {
      debugPrint('❌ EbookService: Error updating reading progress: $e');
      throw Exception('Failed to update reading progress: $e');
    }
  }

  Future<List<UserEbookModel>> getUserReadingHistory(String userId, {int limit = 50}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('📚 EbookService: Fetching reading history for user: $userId');
      
      final snapshot = await _firestore
          .collection('user_ebook_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('lastReadAt', descending: true)
          .limit(limit)
          .get();

      final history = snapshot.docs
          .map((doc) => UserEbookModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ EbookService: Retrieved ${history.length} reading history records');
      return history;
    } catch (e) {
      debugPrint('❌ EbookService: Error fetching reading history: $e');
      throw Exception('Failed to fetch reading history: $e');
    }
  }

  Future<EbookBookmarkModel> addBookmark({
    required String userId,
    required String ebookId,
    required int pageNumber,
    required String title,
    String? note,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🔖 EbookService: Adding bookmark for page: $pageNumber');

      final bookmark = EbookBookmarkModel(
        id: '',
        userId: userId,
        ebookId: ebookId,
        pageNumber: pageNumber,
        title: title,
        note: note,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('ebook_bookmarks')
          .add(bookmark.toFirestore());

      final createdBookmark = EbookBookmarkModel(
        id: docRef.id,
        userId: userId,
        ebookId: ebookId,
        pageNumber: pageNumber,
        title: title,
        note: note,
        createdAt: DateTime.now(),
      );

      debugPrint('✅ EbookService: Bookmark created with ID: ${docRef.id}');
      notifyListeners();
      return createdBookmark;
    } catch (e) {
      debugPrint('❌ EbookService: Error adding bookmark: $e');
      throw Exception('Failed to add bookmark: $e');
    }
  }

  Future<List<EbookBookmarkModel>> getUserBookmarks(String userId, String ebookId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🔖 EbookService: Fetching bookmarks for user: $userId, ebook: $ebookId');
      
      final snapshot = await _firestore
          .collection('ebook_bookmarks')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .orderBy('pageNumber')
          .get();

      final bookmarks = snapshot.docs
          .map((doc) => EbookBookmarkModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ EbookService: Retrieved ${bookmarks.length} bookmarks');
      return bookmarks;
    } catch (e) {
      debugPrint('❌ EbookService: Error fetching bookmarks: $e');
      throw Exception('Failed to fetch bookmarks: $e');
    }
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('🔖 EbookService: Deleting bookmark: $bookmarkId');

      await _firestore
          .collection('ebook_bookmarks')
          .doc(bookmarkId)
          .delete();

      debugPrint('✅ EbookService: Bookmark deleted successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ EbookService: Error deleting bookmark: $e');
      throw Exception('Failed to delete bookmark: $e');
    }
  }

  Future<EbookAnnotationModel> addAnnotation({
    required String userId,
    required String ebookId,
    required int pageNumber,
    required String type,
    required String content,
    String? selectedText,
    Map<String, dynamic>? position,
    String color = '#FFEB3B',
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('✏️ EbookService: Adding annotation - Type: $type, Page: $pageNumber');

      final annotation = EbookAnnotationModel(
        id: '',
        userId: userId,
        ebookId: ebookId,
        pageNumber: pageNumber,
        type: type,
        content: content,
        selectedText: selectedText,
        position: position ?? {},
        color: color,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('ebook_annotations')
          .add(annotation.toFirestore());

      final createdAnnotation = EbookAnnotationModel(
        id: docRef.id,
        userId: userId,
        ebookId: ebookId,
        pageNumber: pageNumber,
        type: type,
        content: content,
        selectedText: selectedText,
        position: position ?? {},
        color: color,
        createdAt: DateTime.now(),
      );

      debugPrint('✅ EbookService: Annotation created with ID: ${docRef.id}');
      notifyListeners();
      return createdAnnotation;
    } catch (e) {
      debugPrint('❌ EbookService: Error adding annotation: $e');
      throw Exception('Failed to add annotation: $e');
    }
  }

  Future<List<EbookAnnotationModel>> getUserAnnotations(String userId, String ebookId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('✏️ EbookService: Fetching annotations for user: $userId, ebook: $ebookId');
      
      final snapshot = await _firestore
          .collection('ebook_annotations')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .orderBy('pageNumber')
          .orderBy('createdAt')
          .get();

      final annotations = snapshot.docs
          .map((doc) => EbookAnnotationModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ EbookService: Retrieved ${annotations.length} annotations');
      return annotations;
    } catch (e) {
      debugPrint('❌ EbookService: Error fetching annotations: $e');
      throw Exception('Failed to fetch annotations: $e');
    }
  }

  Future<void> updateAnnotation(String annotationId, String content) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('✏️ EbookService: Updating annotation: $annotationId');

      await _firestore
          .collection('ebook_annotations')
          .doc(annotationId)
          .update({
            'content': content,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      debugPrint('✅ EbookService: Annotation updated successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ EbookService: Error updating annotation: $e');
      throw Exception('Failed to update annotation: $e');
    }
  }

  Future<void> deleteAnnotation(String annotationId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('✏️ EbookService: Deleting annotation: $annotationId');

      await _firestore
          .collection('ebook_annotations')
          .doc(annotationId)
          .delete();

      debugPrint('✅ EbookService: Annotation deleted successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ EbookService: Error deleting annotation: $e');
      throw Exception('Failed to delete annotation: $e');
    }
  }

  Future<EbookReviewModel> addReview({
    required String userId,
    required String ebookId,
    required double rating,
    String? review,
  }) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('⭐ EbookService: Adding review - Rating: $rating');

      // Check if user already reviewed this ebook
      final existingReview = await _firestore
          .collection('ebook_reviews')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .limit(1)
          .get();

      if (existingReview.docs.isNotEmpty) {
        // Update existing review
        final reviewId = existingReview.docs.first.id;
        await _firestore
            .collection('ebook_reviews')
            .doc(reviewId)
            .update({
              'rating': rating,
              'review': review,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        final updatedReview = EbookReviewModel(
          id: reviewId,
          userId: userId,
          ebookId: ebookId,
          rating: rating,
          review: review,
          createdAt: existingReview.docs.first.data()['createdAt'].toDate(),
          updatedAt: DateTime.now(),
        );

        debugPrint('✅ EbookService: Review updated');
        await _updateEbookRating(ebookId);
        notifyListeners();
        return updatedReview;
      } else {
        // Create new review
        final reviewModel = EbookReviewModel(
          id: '',
          userId: userId,
          ebookId: ebookId,
          rating: rating,
          review: review,
          createdAt: DateTime.now(),
        );

        final docRef = await _firestore
            .collection('ebook_reviews')
            .add(reviewModel.toFirestore());

        final createdReview = EbookReviewModel(
          id: docRef.id,
          userId: userId,
          ebookId: ebookId,
          rating: rating,
          review: review,
          createdAt: DateTime.now(),
        );

        debugPrint('✅ EbookService: Review created with ID: ${docRef.id}');
        await _updateEbookRating(ebookId);
        notifyListeners();
        return createdReview;
      }
    } catch (e) {
      debugPrint('❌ EbookService: Error adding review: $e');
      throw Exception('Failed to add review: $e');
    }
  }

  Future<List<EbookReviewModel>> getEbookReviews(String ebookId, {int limit = 20}) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('⭐ EbookService: Fetching reviews for ebook: $ebookId');
      
      final snapshot = await _firestore
          .collection('ebook_reviews')
          .where('ebookId', isEqualTo: ebookId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final reviews = snapshot.docs
          .map((doc) => EbookReviewModel.fromFirestore(doc))
          .toList();

      debugPrint('✅ EbookService: Retrieved ${reviews.length} reviews');
      return reviews;
    } catch (e) {
      debugPrint('❌ EbookService: Error fetching reviews: $e');
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Future<void> markAsDownloaded(String userId, String ebookId) async {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    try {
      debugPrint('📥 EbookService: Marking ebook as downloaded: $ebookId');

      final existingProgress = await getUserEbookProgress(userId, ebookId);
      
      if (existingProgress != null) {
        await _firestore
            .collection('user_ebook_progress')
            .doc(existingProgress.id)
            .update({
              'isDownloaded': true,
              'downloadedAt': FieldValue.serverTimestamp(),
            });
      } else {
        // Create progress record with download flag
        final progress = UserEbookModel(
          id: '',
          userId: userId,
          ebookId: ebookId,
          accessedAt: DateTime.now(),
          downloadedAt: DateTime.now(),
          isDownloaded: true,
          lastReadAt: DateTime.now(),
        );

        await _firestore
            .collection('user_ebook_progress')
            .add(progress.toFirestore());
      }

      // Increment download count
      await _firestore.collection('ebooks').doc(ebookId).update({
        'downloadCount': FieldValue.increment(1),
      });

      debugPrint('✅ EbookService: Ebook marked as downloaded');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ EbookService: Error marking as downloaded: $e');
      throw Exception('Failed to mark as downloaded: $e');
    }
  }

  Future<bool> hasAccessToEbook(String userId, String ebookId) async {
    try {
      final ebook = await getEbookById(ebookId);
      if (ebook == null) return false;

      // Free ebooks are always accessible
      if (ebook.accessLevel == AccessLevel.free) {
        return true;
      }

      // Check if user has already accessed this ebook
      final userProgress = await getUserEbookProgress(userId, ebookId);
      if (userProgress != null) {
        return true;
      }

      // For premium ebooks, check subscription or coin balance
      // This would integrate with your existing payment/subscription system
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getEbookAnalytics(String ebookId) async {
    try {
      debugPrint('📊 EbookService: Generating analytics for ebook: $ebookId');
      
      final ebook = await getEbookById(ebookId);
      if (ebook == null) return {};

      // Get user progress data for analytics
      final progressSnapshot = await _firestore
          .collection('user_ebook_progress')
          .where('ebookId', isEqualTo: ebookId)
          .get();

      final progressData = progressSnapshot.docs
          .map((doc) => UserEbookModel.fromFirestore(doc))
          .toList();

      final totalReaders = progressData.length;
      final completedReaders = progressData.where((p) => p.readingProgress >= 1.0).length;
      final completionRate = totalReaders > 0 ? completedReaders / totalReaders : 0.0;
      final averageProgress = progressData.isEmpty
          ? 0.0
          : progressData.map((p) => p.readingProgress).reduce((a, b) => a + b) / totalReaders;
      final averageReadingTime = progressData.isEmpty
          ? 0
          : progressData.map((p) => p.totalReadingTime).reduce((a, b) => a + b) ~/ totalReaders;

      final analytics = {
        'totalReaders': totalReaders,
        'completedReaders': completedReaders,
        'completionRate': completionRate,
        'averageProgress': averageProgress,
        'averageReadingTime': averageReadingTime,
        'totalDownloads': ebook.downloadCount,
        'rating': ebook.rating,
        'totalPages': ebook.totalPages,
        'bookmarkCount': await _getBookmarkCount(ebookId),
        'annotationCount': await _getAnnotationCount(ebookId),
      };

      debugPrint('✅ EbookService: Analytics generated');
      return analytics;
    } catch (e) {
      debugPrint('❌ EbookService: Error generating analytics: $e');
      throw Exception('Failed to generate ebook analytics: $e');
    }
  }

  Future<Map<String, dynamic>> getUserReadingStatistics(String userId) async {
    try {
      debugPrint('📊 EbookService: Generating reading statistics for user: $userId');
      
      final progressData = await getUserReadingHistory(userId);
      
      final totalBooksRead = progressData.length;
      final completedBooks = progressData.where((p) => p.readingProgress >= 1.0).length;
      final totalReadingTime = progressData.fold<int>(0, (sum, p) => sum + p.totalReadingTime);
      final averageProgress = progressData.isEmpty
          ? 0.0
          : progressData.map((p) => p.readingProgress).reduce((a, b) => a + b) / totalBooksRead;

      final statistics = {
        'totalBooksRead': totalBooksRead,
        'completedBooks': completedBooks,
        'totalReadingTime': totalReadingTime,
        'averageProgress': averageProgress,
        'completionRate': totalBooksRead > 0 ? completedBooks / totalBooksRead : 0.0,
        'currentlyReading': progressData.where((p) => p.readingProgress > 0 && p.readingProgress < 1.0).length,
        'totalBookmarks': await _getUserBookmarkCount(userId),
        'totalAnnotations': await _getUserAnnotationCount(userId),
      };

      debugPrint('✅ EbookService: Reading statistics generated');
      return statistics;
    } catch (e) {
      debugPrint('❌ EbookService: Error generating reading statistics: $e');
      throw Exception('Failed to generate reading statistics: $e');
    }
  }

  Stream<List<EbookModel>> watchEbooks({
    String? userRole,
    EbookCategory? category,
    int limit = 20,
  }) {
    if (!FirebaseAvailability.isAvailable) {
      throw Exception(FirebaseAvailability.unavailableMessage);
    }

    debugPrint('🔄 EbookService: Starting real-time watch for ebooks');
    
    Query query = _firestore
        .collection('ebooks')
        .where('isActive', isEqualTo: true);

    if (userRole != null) {
      query = query.where('targetRoles', arrayContains: userRole);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final ebooks = snapshot.docs
              .map((doc) => EbookModel.fromFirestore(doc))
              .toList();
          debugPrint('🔄 EbookService: Real-time update - ${ebooks.length} ebooks');
          return ebooks;
        });
  }

  Future<void> _updateEbookRating(String ebookId) async {
    try {
      final reviewsSnapshot = await _firestore
          .collection('ebook_reviews')
          .where('ebookId', isEqualTo: ebookId)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        final reviews = reviewsSnapshot.docs
            .map((doc) => EbookReviewModel.fromFirestore(doc))
            .toList();

        final averageRating = reviews
            .map((r) => r.rating)
            .reduce((a, b) => a + b) / reviews.length;

        await _firestore.collection('ebooks').doc(ebookId).update({
          'rating': averageRating,
        });
      }
    } catch (e) {
      debugPrint('⚠️ EbookService: Could not update ebook rating: $e');
    }
  }

  Future<int> _getBookmarkCount(String ebookId) async {
    try {
      final snapshot = await _firestore
          .collection('ebook_bookmarks')
          .where('ebookId', isEqualTo: ebookId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getAnnotationCount(String ebookId) async {
    try {
      final snapshot = await _firestore
          .collection('ebook_annotations')
          .where('ebookId', isEqualTo: ebookId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getUserBookmarkCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('ebook_bookmarks')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> _getUserAnnotationCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('ebook_annotations')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> toggleBookmarkStatus(String userId, String ebookId) async {
    try {
      final progress = await getUserEbookProgress(userId, ebookId);
      
      if (progress != null) {
        await _firestore
            .collection('user_ebook_progress')
            .doc(progress.id)
            .update({
              'isBookmarked': !progress.isBookmarked,
            });
      } else {
        // Create progress record with bookmark
        final newProgress = UserEbookModel(
          id: '',
          userId: userId,
          ebookId: ebookId,
          accessedAt: DateTime.now(),
          isBookmarked: true,
          lastReadAt: DateTime.now(),
        );

        await _firestore
            .collection('user_ebook_progress')
            .add(newProgress.toFirestore());
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to toggle bookmark status: $e');
    }
  }

  Future<List<EbookModel>> getRecommendedEbooks(String userId, {int limit = 10}) async {
    try {
      // Simple recommendation based on user's reading history
      final readingHistory = await getUserReadingHistory(userId, limit: 50);
      
      // Get categories user has read
      final readCategories = <EbookCategory>{};
      for (final progress in readingHistory) {
        final ebook = await getEbookById(progress.ebookId);
        if (ebook != null) {
          readCategories.add(ebook.category);
        }
      }

      if (readCategories.isEmpty) {
        // Return featured ebooks if no reading history
        return getFeaturedEbooks(null, limit: limit);
      }

      // Get ebooks from preferred categories that user hasn't read
      final readEbookIds = readingHistory.map((p) => p.ebookId).toSet();
      
      Query query = _firestore
          .collection('ebooks')
          .where('isActive', isEqualTo: true)
          .where('category', whereIn: readCategories.map((c) => c.name).toList());

      final snapshot = await query
          .orderBy('rating', descending: true)
          .limit(limit * 2) // Get more to filter out already read
          .get();

      final recommendations = snapshot.docs
          .map((doc) => EbookModel.fromFirestore(doc))
          .where((ebook) => !readEbookIds.contains(ebook.id))
          .take(limit)
          .toList();

      debugPrint('✅ EbookService: Generated ${recommendations.length} recommendations');
      return recommendations;
    } catch (e) {
      debugPrint('❌ EbookService: Error getting recommendations: $e');
      // Fallback to featured ebooks
      return getFeaturedEbooks(null, limit: limit);
    }
  }
}