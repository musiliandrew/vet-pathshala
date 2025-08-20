import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ebook_models.dart';

class EbookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ebook Management
  Future<List<EbookModel>> getEbooks({
    EbookCategory? category,
    EbookType? type,
    String? targetRole,
    AccessLevel? accessLevel,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('ebooks')
          .where('isActive', isEqualTo: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (targetRole != null) {
        query = query.where('targetRoles', arrayContains: targetRole);
      }

      if (accessLevel != null) {
        query = query.where('accessLevel', isEqualTo: accessLevel.name);
      }

      final snapshot = await query
          .orderBy('rating', descending: true)
          .orderBy('downloadCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => EbookModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get ebooks: $e');
    }
  }

  Future<EbookModel?> getEbookById(String ebookId) async {
    try {
      final doc = await _firestore.collection('ebooks').doc(ebookId).get();
      
      if (doc.exists) {
        return EbookModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get ebook: $e');
    }
  }

  Future<List<EbookModel>> searchEbooks({
    required String query,
    String? targetRole,
    EbookCategory? category,
    int limit = 20,
  }) async {
    try {
      Query firestoreQuery = _firestore
          .collection('ebooks')
          .where('isActive', isEqualTo: true);

      if (targetRole != null) {
        firestoreQuery = firestoreQuery.where('targetRoles', arrayContains: targetRole);
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

      return ebooks;
    } catch (e) {
      throw Exception('Failed to search ebooks: $e');
    }
  }

  // User Ebook Access
  Future<UserEbookModel> accessEbook(String userId, String ebookId) async {
    try {
      // Check if user already has access
      final existingAccess = await _firestore
          .collection('user_ebooks')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .get();

      if (existingAccess.docs.isNotEmpty) {
        // Update last access time
        final doc = existingAccess.docs.first;
        await doc.reference.update({
          'lastReadAt': FieldValue.serverTimestamp(),
        });
        return UserEbookModel.fromFirestore(doc);
      } else {
        // Create new access record
        final userEbook = UserEbookModel(
          id: '',
          userId: userId,
          ebookId: ebookId,
          accessedAt: DateTime.now(),
          lastReadAt: DateTime.now(),
        );

        final docRef = await _firestore
            .collection('user_ebooks')
            .add(userEbook.toFirestore());

        // Increment download count
        await _firestore.collection('ebooks').doc(ebookId).update({
          'downloadCount': FieldValue.increment(1),
        });

        return userEbook.copyWith(id: docRef.id);
      }
    } catch (e) {
      throw Exception('Failed to access ebook: $e');
    }
  }

  Future<List<UserEbookModel>> getUserEbooks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_ebooks')
          .where('userId', isEqualTo: userId)
          .orderBy('lastReadAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserEbookModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user ebooks: $e');
    }
  }

  Future<void> updateReadingProgress({
    required String userId,
    required String ebookId,
    required int currentPage,
    required double progress,
    int? readingTimeMinutes,
  }) async {
    try {
      final userEbookSnapshot = await _firestore
          .collection('user_ebooks')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .get();

      if (userEbookSnapshot.docs.isNotEmpty) {
        final doc = userEbookSnapshot.docs.first;
        final updateData = {
          'currentPage': currentPage,
          'readingProgress': progress,
          'lastReadAt': FieldValue.serverTimestamp(),
        };

        if (readingTimeMinutes != null) {
          updateData['totalReadingTime'] = FieldValue.increment(readingTimeMinutes);
        }

        await doc.reference.update(updateData);
      }
    } catch (e) {
      throw Exception('Failed to update reading progress: $e');
    }
  }

  Future<void> toggleBookmark(String userId, String ebookId) async {
    try {
      final userEbookSnapshot = await _firestore
          .collection('user_ebooks')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .get();

      if (userEbookSnapshot.docs.isNotEmpty) {
        final doc = userEbookSnapshot.docs.first;
        final currentData = UserEbookModel.fromFirestore(doc);
        
        await doc.reference.update({
          'isBookmarked': !currentData.isBookmarked,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  // Annotations
  Future<String> addAnnotation(EbookAnnotationModel annotation) async {
    try {
      final docRef = await _firestore
          .collection('ebook_annotations')
          .add(annotation.toFirestore());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add annotation: $e');
    }
  }

  Future<List<EbookAnnotationModel>> getAnnotations({
    required String userId,
    required String ebookId,
    int? pageNumber,
  }) async {
    try {
      Query query = _firestore
          .collection('ebook_annotations')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId);

      if (pageNumber != null) {
        query = query.where('pageNumber', isEqualTo: pageNumber);
      }

      final snapshot = await query
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => EbookAnnotationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get annotations: $e');
    }
  }

  Future<void> updateAnnotation(String annotationId, String content) async {
    try {
      await _firestore.collection('ebook_annotations').doc(annotationId).update({
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update annotation: $e');
    }
  }

  Future<void> deleteAnnotation(String annotationId) async {
    try {
      await _firestore.collection('ebook_annotations').doc(annotationId).delete();
    } catch (e) {
      throw Exception('Failed to delete annotation: $e');
    }
  }

  // Bookmarks
  Future<String> addBookmark(EbookBookmarkModel bookmark) async {
    try {
      final docRef = await _firestore
          .collection('ebook_bookmarks')
          .add(bookmark.toFirestore());
      
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  Future<List<EbookBookmarkModel>> getBookmarks({
    required String userId,
    required String ebookId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('ebook_bookmarks')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .orderBy('pageNumber')
          .get();

      return snapshot.docs
          .map((doc) => EbookBookmarkModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get bookmarks: $e');
    }
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _firestore.collection('ebook_bookmarks').doc(bookmarkId).delete();
    } catch (e) {
      throw Exception('Failed to delete bookmark: $e');
    }
  }

  // Reviews
  Future<void> addOrUpdateReview(EbookReviewModel review) async {
    try {
      // Check if user already reviewed this ebook
      final existingReview = await _firestore
          .collection('ebook_reviews')
          .where('userId', isEqualTo: review.userId)
          .where('ebookId', isEqualTo: review.ebookId)
          .get();

      if (existingReview.docs.isNotEmpty) {
        // Update existing review
        await existingReview.docs.first.reference.update({
          'rating': review.rating,
          'review': review.review,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new review
        await _firestore.collection('ebook_reviews').add(review.toFirestore());
      }

      // Update ebook rating
      await _updateEbookRating(review.ebookId);
    } catch (e) {
      throw Exception('Failed to add/update review: $e');
    }
  }

  Future<List<EbookReviewModel>> getEbookReviews(String ebookId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('ebook_reviews')
          .where('ebookId', isEqualTo: ebookId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => EbookReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get ebook reviews: $e');
    }
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
      print('Failed to update ebook rating: $e');
    }
  }

  // Premium Access Check
  Future<bool> hasAccessToEbook(String userId, String ebookId) async {
    try {
      final ebook = await getEbookById(ebookId);
      if (ebook == null) return false;

      // Free ebooks are always accessible
      if (ebook.accessLevel == AccessLevel.free) {
        return true;
      }

      // Check if user has already purchased/accessed
      final userEbook = await _firestore
          .collection('user_ebooks')
          .where('userId', isEqualTo: userId)
          .where('ebookId', isEqualTo: ebookId)
          .get();

      if (userEbook.docs.isNotEmpty) {
        return true;
      }

      // Check premium subscription or coin purchases
      if (ebook.accessLevel == AccessLevel.premium || ebook.accessLevel == AccessLevel.subscription) {
        // This would check user's subscription status or coin balance
        // Implementation depends on your subscription/payment system
        return false;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Purchase/Access Ebook with Coins
  Future<void> purchaseEbook(String userId, String ebookId, int coinCost) async {
    try {
      // This would be a transaction to deduct coins and grant access
      final batch = _firestore.batch();

      // Deduct coins from user
      final userRef = _firestore.collection('users').doc(userId);
      batch.update(userRef, {
        'coins': FieldValue.increment(-coinCost),
      });

      // Create coin transaction record
      final transactionRef = _firestore.collection('coin_transactions').doc();
      batch.set(transactionRef, {
        'userId': userId,
        'amount': -coinCost,
        'type': 'spent',
        'reason': 'Ebook purchase',
        'metadata': {'ebookId': ebookId},
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Grant access to ebook
      final userEbook = UserEbookModel(
        id: '',
        userId: userId,
        ebookId: ebookId,
        accessedAt: DateTime.now(),
        lastReadAt: DateTime.now(),
      );

      final userEbookRef = _firestore.collection('user_ebooks').doc();
      batch.set(userEbookRef, userEbook.toFirestore());

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to purchase ebook: $e');
    }
  }

  // Get featured/recommended ebooks
  Future<List<EbookModel>> getFeaturedEbooks(String? targetRole, {int limit = 10}) async {
    try {
      Query query = _firestore
          .collection('ebooks')
          .where('isActive', isEqualTo: true);

      if (targetRole != null) {
        query = query.where('targetRoles', arrayContains: targetRole);
      }

      final snapshot = await query
          .orderBy('rating', descending: true)
          .orderBy('downloadCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => EbookModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get featured ebooks: $e');
    }
  }
}

// Extension for UserEbookModel
extension UserEbookModelExtension on UserEbookModel {
  UserEbookModel copyWith({
    String? id,
    String? userId,
    String? ebookId,
    DateTime? accessedAt,
    DateTime? downloadedAt,
    int? currentPage,
    double? readingProgress,
    bool? isBookmarked,
    bool? isDownloaded,
    DateTime? lastReadAt,
    int? totalReadingTime,
    Map<String, dynamic>? readingData,
  }) {
    return UserEbookModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      ebookId: ebookId ?? this.ebookId,
      accessedAt: accessedAt ?? this.accessedAt,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      currentPage: currentPage ?? this.currentPage,
      readingProgress: readingProgress ?? this.readingProgress,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      readingData: readingData ?? this.readingData,
    );
  }
}