import 'package:flutter/foundation.dart';
import '../models/ebook_models.dart';
import '../models/user_model.dart';
import '../services/ebook_service.dart';

class EbookProvider with ChangeNotifier {
  final EbookService _ebookService = EbookService();
  
  // State variables
  List<EbookModel> _ebooks = [];
  List<EbookModel> _featuredEbooks = [];
  List<UserEbookModel> _userEbooks = [];
  List<EbookAnnotationModel> _annotations = [];
  List<EbookBookmarkModel> _bookmarks = [];
  List<EbookReviewModel> _reviews = [];
  
  bool _isLoading = false;
  bool _isLoadingFeatured = false;
  bool _isLoadingUserEbooks = false;
  String _error = '';
  
  EbookCategory? _selectedCategory;
  EbookType? _selectedType;
  String _searchQuery = '';

  // Getters
  List<EbookModel> get ebooks => _ebooks;
  List<EbookModel> get featuredEbooks => _featuredEbooks;
  List<UserEbookModel> get userEbooks => _userEbooks;
  List<EbookAnnotationModel> get annotations => _annotations;
  List<EbookBookmarkModel> get bookmarks => _bookmarks;
  List<EbookReviewModel> get reviews => _reviews;
  
  bool get isLoading => _isLoading;
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingUserEbooks => _isLoadingUserEbooks;
  String get error => _error;
  
  EbookCategory? get selectedCategory => _selectedCategory;
  EbookType? get selectedType => _selectedType;
  String get searchQuery => _searchQuery;

  // Load ebooks with filters
  Future<void> loadEbooks({
    EbookCategory? category,
    EbookType? type,
    String? targetRole,
    AccessLevel? accessLevel,
    int limit = 20,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final ebooks = await _ebookService.getEbooks(
        category: category,
        type: type,
        targetRole: targetRole,
        accessLevel: accessLevel,
        limit: limit,
      );

      _ebooks = ebooks;
      _selectedCategory = category;
      _selectedType = type;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load featured ebooks
  Future<void> loadFeaturedEbooks(String? targetRole, {int limit = 10}) async {
    try {
      _isLoadingFeatured = true;
      notifyListeners();

      final featuredEbooks = await _ebookService.getFeaturedEbooks(targetRole, limit: limit);
      _featuredEbooks = featuredEbooks;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  // Search ebooks
  Future<void> searchEbooks({
    required String query,
    String? targetRole,
    EbookCategory? category,
    int limit = 20,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      _searchQuery = query;
      notifyListeners();

      if (query.isEmpty) {
        await loadEbooks(category: category, targetRole: targetRole, limit: limit);
        return;
      }

      final searchResults = await _ebookService.searchEbooks(
        query: query,
        targetRole: targetRole,
        category: category,
        limit: limit,
      );

      _ebooks = searchResults;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user's ebooks
  Future<void> loadUserEbooks(String userId) async {
    try {
      _isLoadingUserEbooks = true;
      notifyListeners();

      final userEbooks = await _ebookService.getUserEbooks(userId);
      _userEbooks = userEbooks;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingUserEbooks = false;
      notifyListeners();
    }
  }

  // Access/purchase ebook
  Future<UserEbookModel?> accessEbook(String userId, String ebookId) async {
    try {
      final userEbook = await _ebookService.accessEbook(userId, ebookId);
      
      // Update local state
      final existingIndex = _userEbooks.indexWhere(
        (ue) => ue.userId == userId && ue.ebookId == ebookId,
      );
      
      if (existingIndex >= 0) {
        _userEbooks[existingIndex] = userEbook;
      } else {
        _userEbooks.insert(0, userEbook);
      }
      
      notifyListeners();
      return userEbook;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Purchase ebook with coins
  Future<bool> purchaseEbook(String userId, String ebookId, int coinCost) async {
    try {
      await _ebookService.purchaseEbook(userId, ebookId, coinCost);
      
      // Automatically access the ebook after purchase
      await accessEbook(userId, ebookId);
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update reading progress
  Future<void> updateReadingProgress({
    required String userId,
    required String ebookId,
    required int currentPage,
    required double progress,
    int? readingTimeMinutes,
  }) async {
    try {
      await _ebookService.updateReadingProgress(
        userId: userId,
        ebookId: ebookId,
        currentPage: currentPage,
        progress: progress,
        readingTimeMinutes: readingTimeMinutes,
      );

      // Update local state
      final userEbookIndex = _userEbooks.indexWhere(
        (ue) => ue.userId == userId && ue.ebookId == ebookId,
      );

      if (userEbookIndex >= 0) {
        final updatedUserEbook = UserEbookModel(
          id: _userEbooks[userEbookIndex].id,
          userId: _userEbooks[userEbookIndex].userId,
          ebookId: _userEbooks[userEbookIndex].ebookId,
          accessedAt: _userEbooks[userEbookIndex].accessedAt,
          downloadedAt: _userEbooks[userEbookIndex].downloadedAt,
          currentPage: currentPage,
          readingProgress: progress,
          isBookmarked: _userEbooks[userEbookIndex].isBookmarked,
          isDownloaded: _userEbooks[userEbookIndex].isDownloaded,
          lastReadAt: DateTime.now(),
          totalReadingTime: _userEbooks[userEbookIndex].totalReadingTime + (readingTimeMinutes ?? 0),
          readingData: _userEbooks[userEbookIndex].readingData,
        );
        
        _userEbooks[userEbookIndex] = updatedUserEbook;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Toggle bookmark for ebook
  Future<void> toggleBookmark(String userId, String ebookId) async {
    try {
      await _ebookService.toggleBookmark(userId, ebookId);
      
      // Update local state
      final userEbookIndex = _userEbooks.indexWhere(
        (ue) => ue.userId == userId && ue.ebookId == ebookId,
      );

      if (userEbookIndex >= 0) {
        final current = _userEbooks[userEbookIndex];
        final updated = UserEbookModel(
          id: current.id,
          userId: current.userId,
          ebookId: current.ebookId,
          accessedAt: current.accessedAt,
          downloadedAt: current.downloadedAt,
          currentPage: current.currentPage,
          readingProgress: current.readingProgress,
          isBookmarked: !current.isBookmarked,
          isDownloaded: current.isDownloaded,
          lastReadAt: current.lastReadAt,
          totalReadingTime: current.totalReadingTime,
          readingData: current.readingData,
        );
        
        _userEbooks[userEbookIndex] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Annotation management
  Future<void> loadAnnotations({
    required String userId,
    required String ebookId,
    int? pageNumber,
  }) async {
    try {
      final annotations = await _ebookService.getAnnotations(
        userId: userId,
        ebookId: ebookId,
        pageNumber: pageNumber,
      );
      
      _annotations = annotations;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addAnnotation(EbookAnnotationModel annotation) async {
    try {
      final annotationId = await _ebookService.addAnnotation(annotation);
      
      final annotationWithId = EbookAnnotationModel(
        id: annotationId,
        userId: annotation.userId,
        ebookId: annotation.ebookId,
        pageNumber: annotation.pageNumber,
        type: annotation.type,
        content: annotation.content,
        selectedText: annotation.selectedText,
        position: annotation.position,
        color: annotation.color,
        createdAt: annotation.createdAt,
        updatedAt: annotation.updatedAt,
        isPrivate: annotation.isPrivate,
      );
      
      _annotations.insert(0, annotationWithId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateAnnotation(String annotationId, String content) async {
    try {
      await _ebookService.updateAnnotation(annotationId, content);
      
      final index = _annotations.indexWhere((a) => a.id == annotationId);
      if (index >= 0) {
        final updated = EbookAnnotationModel(
          id: _annotations[index].id,
          userId: _annotations[index].userId,
          ebookId: _annotations[index].ebookId,
          pageNumber: _annotations[index].pageNumber,
          type: _annotations[index].type,
          content: content,
          selectedText: _annotations[index].selectedText,
          position: _annotations[index].position,
          color: _annotations[index].color,
          createdAt: _annotations[index].createdAt,
          updatedAt: DateTime.now(),
          isPrivate: _annotations[index].isPrivate,
        );
        
        _annotations[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteAnnotation(String annotationId) async {
    try {
      await _ebookService.deleteAnnotation(annotationId);
      
      _annotations.removeWhere((a) => a.id == annotationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Bookmark management
  Future<void> loadBookmarks({
    required String userId,
    required String ebookId,
  }) async {
    try {
      final bookmarks = await _ebookService.getBookmarks(
        userId: userId,
        ebookId: ebookId,
      );
      
      _bookmarks = bookmarks;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addBookmark(EbookBookmarkModel bookmark) async {
    try {
      final bookmarkId = await _ebookService.addBookmark(bookmark);
      
      final bookmarkWithId = EbookBookmarkModel(
        id: bookmarkId,
        userId: bookmark.userId,
        ebookId: bookmark.ebookId,
        pageNumber: bookmark.pageNumber,
        title: bookmark.title,
        note: bookmark.note,
        createdAt: bookmark.createdAt,
      );
      
      _bookmarks.insert(0, bookmarkWithId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _ebookService.deleteBookmark(bookmarkId);
      
      _bookmarks.removeWhere((b) => b.id == bookmarkId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Reviews
  Future<void> loadReviews(String ebookId, {int limit = 10}) async {
    try {
      final reviews = await _ebookService.getEbookReviews(ebookId, limit: limit);
      _reviews = reviews;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addOrUpdateReview(EbookReviewModel review) async {
    try {
      await _ebookService.addOrUpdateReview(review);
      
      // Reload reviews to get updated data
      await loadReviews(review.ebookId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check access to ebook
  Future<bool> hasAccessToEbook(String userId, String ebookId) async {
    try {
      return await _ebookService.hasAccessToEbook(userId, ebookId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Get specific ebook
  Future<EbookModel?> getEbookById(String ebookId) async {
    try {
      return await _ebookService.getEbookById(ebookId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Utility methods
  void clearError() {
    _error = '';
    notifyListeners();
  }

  void setSelectedCategory(EbookCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedType(EbookType? type) {
    _selectedType = type;
    notifyListeners();
  }

  UserEbookModel? getUserEbook(String userId, String ebookId) {
    try {
      return _userEbooks.firstWhere(
        (ue) => ue.userId == userId && ue.ebookId == ebookId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get reading statistics
  Map<String, dynamic> getReadingStatistics(String userId) {
    final userEbooksForUser = _userEbooks.where((ue) => ue.userId == userId).toList();
    
    final totalEbooks = userEbooksForUser.length;
    final completedEbooks = userEbooksForUser.where((ue) => ue.readingProgress >= 1.0).length;
    final inProgressEbooks = userEbooksForUser.where(
      (ue) => ue.readingProgress > 0 && ue.readingProgress < 1.0,
    ).length;
    final totalReadingTime = userEbooksForUser.fold<int>(
      0,
      (sum, ue) => sum + ue.totalReadingTime,
    );
    final averageProgress = userEbooksForUser.isEmpty 
      ? 0.0 
      : userEbooksForUser.fold<double>(
          0.0,
          (sum, ue) => sum + ue.readingProgress,
        ) / totalEbooks;

    return {
      'totalEbooks': totalEbooks,
      'completedEbooks': completedEbooks,
      'inProgressEbooks': inProgressEbooks,
      'totalReadingTime': totalReadingTime,
      'averageProgress': averageProgress,
    };
  }
}