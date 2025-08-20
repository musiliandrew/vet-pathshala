import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/enhanced_content_models.dart';

class EnhancedAdminService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Admin verification - check against Firebase user role
  Future<bool> isUserAdmin(String? userId) async {
    if (userId == null) return false;
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;
      final userData = userDoc.data() as Map<String, dynamic>;
      return userData['role'] == 'admin';
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  // VIDEO MANAGEMENT
  Future<String> uploadVideo({
    required String title,
    required String description,
    required String instructor,
    String instructorBio = '',
    required String category,
    String subcategory = '',
    required List<String> targetRoles,
    required String accessLevel,
    int coinCost = 0,
    String difficulty = 'beginner',
    List<String> tags = const [],
    required Uint8List videoFile,
    required String fileName,
    Uint8List? thumbnailFile,
    String? thumbnailFileName,
    String createdBy = 'admin',
  }) async {
    _setLoading(true);
    try {
      // Upload video file to Firebase Storage
      final videoRef = _storage.ref().child('videos/$fileName');
      final videoUploadTask = await videoRef.putData(
        videoFile,
        SettableMetadata(contentType: 'video/mp4'),
      );
      final videoUrl = await videoUploadTask.ref.getDownloadURL();

      // Upload thumbnail if provided
      String? thumbnailUrl;
      if (thumbnailFile != null && thumbnailFileName != null) {
        final thumbnailRef = _storage.ref().child('thumbnails/$thumbnailFileName');
        final thumbnailUploadTask = await thumbnailRef.putData(
          thumbnailFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        thumbnailUrl = await thumbnailUploadTask.ref.getDownloadURL();
      }

      // Create enhanced video model
      final videoModel = EnhancedVideoModel(
        id: '', // Will be set by Firestore
        title: title,
        description: description,
        instructor: instructor,
        instructorBio: instructorBio,
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        qualityUrls: {'720p': videoUrl}, // Initially same URL
        duration: 0, // Will be updated after processing
        category: category,
        subcategory: subcategory,
        targetRoles: targetRoles,
        accessLevel: accessLevel,
        coinCost: coinCost,
        difficulty: difficulty,
        tags: tags,
        chapters: [],
        subtitles: [],
        isActive: true,
        featured: false,
        publishedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: createdBy,
        stats: VideoStats(),
      );

      // Save to Firestore
      final docRef = await _firestore.collection('videos').add(videoModel.toFirestore());
      
      debugPrint('✅ Video uploaded successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error uploading video: $e');
      throw Exception('Failed to upload video: $e');
    } finally {
      _setLoading(false);
    }
  }

  // QUESTION MANAGEMENT
  Future<String> addQuestion({
    required String question,
    required String questionType,
    List<String> options = const [],
    required String correctAnswer,
    required String explanation,
    required String category,
    String subcategory = '',
    required String subject,
    required String topic,
    String difficulty = 'easy',
    required List<String> targetRoles,
    List<String> tags = const [],
    Uint8List? imageFile,
    String? imageFileName,
    String createdBy = 'admin',
  }) async {
    _setLoading(true);
    try {
      // Upload question image if provided
      String? imageUrl;
      if (imageFile != null && imageFileName != null) {
        final imageRef = _storage.ref().child('question-images/$imageFileName');
        final imageUploadTask = await imageRef.putData(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        imageUrl = await imageUploadTask.ref.getDownloadURL();
      }

      // Create enhanced question model
      final questionModel = EnhancedQuestionModel(
        id: '', // Will be set by Firestore
        question: question,
        questionType: questionType,
        options: options,
        correctAnswer: correctAnswer,
        explanation: explanation,
        category: category,
        subcategory: subcategory,
        subject: subject,
        topic: topic,
        difficulty: difficulty,
        targetRoles: targetRoles,
        tags: tags,
        imageUrl: imageUrl,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: createdBy,
        stats: QuestionStats(),
      );

      // Save to Firestore
      final docRef = await _firestore.collection('questions').add(questionModel.toFirestore());
      
      debugPrint('✅ Question added successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error adding question: $e');
      throw Exception('Failed to add question: $e');
    } finally {
      _setLoading(false);
    }
  }

  // EBOOK MANAGEMENT
  Future<String> uploadEbook({
    required String title,
    required String author,
    required String description,
    required String category,
    String subcategory = '',
    required List<String> targetRoles,
    required String accessLevel,
    int coinCost = 0,
    int pages = 0,
    String language = 'en',
    List<String> tags = const [],
    required Uint8List pdfFile,
    required String pdfFileName,
    Uint8List? coverImageFile,
    String? coverImageFileName,
    String createdBy = 'admin',
  }) async {
    _setLoading(true);
    try {
      // Upload PDF file
      final pdfRef = _storage.ref().child('ebooks/$pdfFileName');
      final pdfUploadTask = await pdfRef.putData(
        pdfFile,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final pdfUrl = await pdfUploadTask.ref.getDownloadURL();

      // Upload cover image if provided
      String? coverImageUrl;
      if (coverImageFile != null && coverImageFileName != null) {
        final coverRef = _storage.ref().child('ebook-covers/$coverImageFileName');
        final coverUploadTask = await coverRef.putData(
          coverImageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        coverImageUrl = await coverUploadTask.ref.getDownloadURL();
      }

      // Create enhanced ebook model
      final ebookModel = EnhancedEbookModel(
        id: '', // Will be set by Firestore
        title: title,
        author: author,
        description: description,
        coverImageUrl: coverImageUrl,
        pdfUrl: pdfUrl,
        category: category,
        subcategory: subcategory,
        targetRoles: targetRoles,
        accessLevel: accessLevel,
        coinCost: coinCost,
        pages: pages,
        language: language,
        tags: tags,
        chapters: [],
        isActive: true,
        featured: false,
        publishedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: createdBy,
        stats: EbookStats(),
      );

      // Save to Firestore
      final docRef = await _firestore.collection('ebooks').add(ebookModel.toFirestore());
      
      debugPrint('✅ Ebook uploaded successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error uploading ebook: $e');
      throw Exception('Failed to upload ebook: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ANALYTICS AND REPORTING
  Future<Map<String, dynamic>> getComprehensiveAnalytics() async {
    try {
      final results = <String, dynamic>{};

      // Get user statistics
      final usersQuery = await _firestore.collection('users').get();
      final totalUsers = usersQuery.docs.length;
      final activeUsers = usersQuery.docs.where((doc) {
        final data = doc.data();
        final lastLogin = data['lastLoginAt'] as Timestamp?;
        if (lastLogin == null) return false;
        return DateTime.now().difference(lastLogin.toDate()).inDays <= 30;
      }).length;

      results['users'] = {
        'total': totalUsers,
        'active': activeUsers,
        'roles': _getUsersByRole(usersQuery.docs),
        'plans': _getUsersByPlan(usersQuery.docs),
      };

      // Get content statistics from your existing collections
      final lecturesQuery = await _firestore.collection('lectures').get();
      final questionsQuery = await _firestore.collection('questions').get();
      final notesQuery = await _firestore.collection('notes').get();

      results['content'] = {
        'videos': lecturesQuery.docs.length,
        'questions': questionsQuery.docs.length,
        'ebooks': notesQuery.docs.length,
        'totalViews': _calculateTotalViews(lecturesQuery.docs),
        'totalAttempts': _calculateTotalAttempts(questionsQuery.docs),
      };

      // Get engagement statistics
      final progressQuery = await _firestore.collection('userProgress').get();
      final totalProgress = progressQuery.docs.length;
      final completedContent = progressQuery.docs.where((doc) => 
        doc.data()['completed'] == true
      ).length;

      results['engagement'] = {
        'totalProgress': totalProgress,
        'completedContent': completedContent,
        'completionRate': totalProgress > 0 ? (completedContent / totalProgress * 100).round() : 0,
      };

      return results;
    } catch (e) {
      debugPrint('❌ Error getting analytics: $e');
      throw Exception('Failed to get analytics: $e');
    }
  }

  // CONTENT MANAGEMENT OPERATIONS
  Future<void> toggleContentStatus(String collection, String documentId, bool isActive) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Content status updated: $collection/$documentId -> $isActive');
    } catch (e) {
      debugPrint('❌ Error updating content status: $e');
      throw Exception('Failed to update content status: $e');
    }
  }

  Future<void> featureContent(String collection, String documentId, bool featured) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        'featured': featured,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Content featured status updated: $collection/$documentId -> $featured');
    } catch (e) {
      debugPrint('❌ Error updating featured status: $e');
      throw Exception('Failed to update featured status: $e');
    }
  }

  Future<void> deleteContent(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      debugPrint('✅ Content deleted: $collection/$documentId');
    } catch (e) {
      debugPrint('❌ Error deleting content: $e');
      throw Exception('Failed to delete content: $e');
    }
  }

  // GET CONTENT LISTS FOR MANAGEMENT
  Stream<List<EnhancedVideoModel>> getVideosStream() {
    // Try both 'videos' and 'lectures' collections for backward compatibility
    return _firestore
        .collection('lectures') // Use your existing collection name
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EnhancedVideoModel.fromFirestore(doc))
            .toList())
        .handleError((error) {
          debugPrint('Error getting videos from lectures collection: $error');
          // Fallback to videos collection
          return _firestore
              .collection('videos')
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((snapshot) => snapshot.docs
                  .map((doc) => EnhancedVideoModel.fromFirestore(doc))
                  .toList());
        });
  }

  Stream<List<EnhancedQuestionModel>> getQuestionsStream() {
    return _firestore
        .collection('questions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EnhancedQuestionModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<EnhancedEbookModel>> getEbooksStream() {
    return _firestore
        .collection('ebooks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EnhancedEbookModel.fromFirestore(doc))
            .toList());
  }

  // UPDATE CONTENT METHODS
  Future<void> updateVideo(String videoId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('videos').doc(videoId).update(updates);
      debugPrint('✅ Video updated: $videoId');
    } catch (e) {
      debugPrint('❌ Error updating video: $e');
      throw Exception('Failed to update video: $e');
    }
  }

  Future<void> updateQuestion(String questionId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('questions').doc(questionId).update(updates);
      debugPrint('✅ Question updated: $questionId');
    } catch (e) {
      debugPrint('❌ Error updating question: $e');
      throw Exception('Failed to update question: $e');
    }
  }

  Future<void> updateEbook(String ebookId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('ebooks').doc(ebookId).update(updates);
      debugPrint('✅ Ebook updated: $ebookId');
    } catch (e) {
      debugPrint('❌ Error updating ebook: $e');
      throw Exception('Failed to update ebook: $e');
    }
  }

  // SEARCH AND FILTER METHODS
  Future<List<Map<String, dynamic>>> searchContent({
    required String query,
    String? contentType,
    String? category,
    int limit = 50,
  }) async {
    try {
      final results = <Map<String, dynamic>>[];

      if (contentType == null || contentType == 'videos') {
        // Search in lectures collection (your existing data)
        final lecturesQuery = await _firestore
            .collection('lectures')
            .limit(limit)
            .get();

        for (final doc in lecturesQuery.docs) {
          final data = doc.data();
          if (_matchesSearch(data, query, category)) {
            results.add({
              'id': doc.id,
              'type': 'video',
              'title': data['title'],
              'description': data['description'],
              'category': data['category'],
              'instructor': data['instructor'] ?? data['author'] ?? 'Unknown',
              'thumbnailUrl': data['thumbnailUrl'],
            });
          }
        }
      }

      if (contentType == null || contentType == 'questions') {
        final questionsQuery = await _firestore
            .collection('questions')
            .limit(limit)
            .get();

        for (final doc in questionsQuery.docs) {
          final data = doc.data();
          if (_matchesSearch(data, query, category)) {
            results.add({
              'id': doc.id,
              'type': 'question',
              'question': data['question'] ?? data['questionText'],
              'category': data['category'],
              'subject': data['subject'] ?? data['category'],
              'topic': data['topic'] ?? data['category'],
            });
          }
        }
      }

      if (contentType == null || contentType == 'ebooks') {
        // Search in notes collection (your existing data) 
        final notesQuery = await _firestore
            .collection('notes')
            .limit(limit)
            .get();

        for (final doc in notesQuery.docs) {
          final data = doc.data();
          if (_matchesSearch(data, query, category)) {
            results.add({
              'id': doc.id,
              'type': 'ebook',
              'title': data['title'],
              'author': data['author'] ?? data['authorId'] ?? 'Unknown',
              'description': data['description'] ?? data['content'],
              'category': data['category'],
              'coverImageUrl': data['coverImageUrl'],
            });
          }
        }
      }

      return results;
    } catch (e) {
      debugPrint('❌ Error searching content: $e');
      throw Exception('Failed to search content: $e');
    }
  }

  // HELPER METHODS
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Map<String, int> _getUsersByRole(List<QueryDocumentSnapshot> docs) {
    final roles = <String, int>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userRole = data['role'] as String? ?? 'unknown';
      roles[userRole] = (roles[userRole] ?? 0) + 1;
    }
    return roles;
  }

  Map<String, int> _getUsersByPlan(List<QueryDocumentSnapshot> docs) {
    final plans = <String, int>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final plan = data['plan'] as String? ?? 'free';
      plans[plan] = (plans[plan] ?? 0) + 1;
    }
    return plans;
  }

  int _calculateTotalViews(List<QueryDocumentSnapshot> videoDocs) {
    int totalViews = 0;
    for (final doc in videoDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final stats = data['stats'] as Map<String, dynamic>?;
      if (stats != null) {
        totalViews += (stats['views'] as int?) ?? 0;
      }
    }
    return totalViews;
  }

  int _calculateTotalAttempts(List<QueryDocumentSnapshot> questionDocs) {
    int totalAttempts = 0;
    for (final doc in questionDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final stats = data['stats'] as Map<String, dynamic>?;
      if (stats != null) {
        totalAttempts += (stats['attempts'] as int?) ?? 0;
      }
    }
    return totalAttempts;
  }

  bool _matchesSearch(Map<String, dynamic> data, String query, String? category) {
    final queryLower = query.toLowerCase();
    
    // Check category filter first
    if (category != null && data['category'] != category) {
      return false;
    }

    // Check text fields for query match
    final searchFields = [
      data['title']?.toString(),
      data['description']?.toString(),
      data['question']?.toString(),
      data['instructor']?.toString(),
      data['author']?.toString(),
      data['subject']?.toString(),
      data['topic']?.toString(),
    ];

    for (final field in searchFields) {
      if (field != null && field.toLowerCase().contains(queryLower)) {
        return true;
      }
    }

    // Check tags
    final tags = data['tags'] as List<dynamic>?;
    if (tags != null) {
      for (final tag in tags) {
        if (tag.toString().toLowerCase().contains(queryLower)) {
          return true;
        }
      }
    }

    return false;
  }
}