import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum InteractionType { like, bookmark, report, view, share }

class UserInteractionModel {
  final String id;
  final String userId;
  final String contentId;
  final String contentType; // 'question', 'note', 'lecture'
  final InteractionType type;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  UserInteractionModel({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.contentType,
    required this.type,
    required this.createdAt,
    this.metadata,
  });

  factory UserInteractionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserInteractionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      contentId: data['contentId'] ?? '',
      contentType: data['contentType'] ?? '',
      type: InteractionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => InteractionType.view,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'contentId': contentId,
      'contentType': contentType,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }
}

class UserInteractionService extends ChangeNotifier {
  static final UserInteractionService _instance = UserInteractionService._internal();
  factory UserInteractionService() => _instance;
  UserInteractionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for interactions to avoid redundant Firebase calls
  final Map<String, Map<InteractionType, bool>> _interactionCache = {};
  final Map<String, Map<InteractionType, int>> _countCache = {};

  /// Record a user interaction
  Future<bool> recordInteraction({
    required String userId,
    required String contentId,
    required String contentType,
    required InteractionType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final cacheKey = '${userId}_$contentId';
      
      // Check if interaction already exists (for likes, bookmarks)
      if (type == InteractionType.like || type == InteractionType.bookmark) {
        final existing = await _getExistingInteraction(userId, contentId, type);
        if (existing != null) {
          // Remove existing interaction (toggle off)
          await _firestore.collection('interactions').doc(existing.id).delete();
          
          // Update cache
          _interactionCache[cacheKey] ??= {};
          _interactionCache[cacheKey]![type] = false;
          
          // Update count cache
          await _updateCountCache(contentId, type, -1);
          
          debugPrint('🔄 Removed ${type.name} interaction for $contentType: $contentId');
          notifyListeners();
          return false; // Indicates interaction was removed
        }
      }

      // Create new interaction
      final interaction = UserInteractionModel(
        id: _generateId(),
        userId: userId,
        contentId: contentId,
        contentType: contentType,
        type: type,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      await _firestore
          .collection('interactions')
          .doc(interaction.id)
          .set(interaction.toFirestore());

      // Update cache
      _interactionCache[cacheKey] ??= {};
      _interactionCache[cacheKey]![type] = true;
      
      // Update count cache
      await _updateCountCache(contentId, type, 1);

      debugPrint('✅ Recorded ${type.name} interaction for $contentType: $contentId');
      notifyListeners();
      return true; // Indicates interaction was added

    } catch (e) {
      debugPrint('❌ Error recording interaction: $e');
      return false;
    }
  }

  /// Get existing interaction
  Future<UserInteractionModel?> _getExistingInteraction(
    String userId,
    String contentId,
    InteractionType type,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('interactions')
          .where('userId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .where('type', isEqualTo: type.name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserInteractionModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting existing interaction: $e');
      return null;
    }
  }

  /// Check if user has interacted with content
  Future<bool> hasUserInteracted({
    required String userId,
    required String contentId,
    required InteractionType type,
  }) async {
    final cacheKey = '${userId}_$contentId';
    
    // Check cache first
    if (_interactionCache[cacheKey]?.containsKey(type) == true) {
      return _interactionCache[cacheKey]![type]!;
    }

    try {
      final interaction = await _getExistingInteraction(userId, contentId, type);
      final hasInteraction = interaction != null;

      // Update cache
      _interactionCache[cacheKey] ??= {};
      _interactionCache[cacheKey]![type] = hasInteraction;

      return hasInteraction;
    } catch (e) {
      debugPrint('❌ Error checking interaction: $e');
      return false;
    }
  }

  /// Get interaction count for content
  Future<int> getInteractionCount({
    required String contentId,
    required InteractionType type,
  }) async {
    final cacheKey = '${contentId}_${type.name}';
    
    // Check cache first
    if (_countCache[contentId]?.containsKey(type) == true) {
      return _countCache[contentId]![type]!;
    }

    try {
      final snapshot = await _firestore
          .collection('interactions')
          .where('contentId', isEqualTo: contentId)
          .where('type', isEqualTo: type.name)
          .get();

      final count = snapshot.docs.length;

      // Update cache
      _countCache[contentId] ??= {};
      _countCache[contentId]![type] = count;

      return count;
    } catch (e) {
      debugPrint('❌ Error getting interaction count: $e');
      return 0;
    }
  }

  /// Update count cache
  Future<void> _updateCountCache(String contentId, InteractionType type, int delta) async {
    _countCache[contentId] ??= {};
    final currentCount = _countCache[contentId]![type] ?? 
                         await getInteractionCount(contentId: contentId, type: type);
    _countCache[contentId]![type] = (currentCount + delta).clamp(0, double.infinity).toInt();
  }

  /// Like content
  Future<bool> likeContent({
    required String userId,
    required String contentId,
    required String contentType,
  }) async {
    return await recordInteraction(
      userId: userId,
      contentId: contentId,
      contentType: contentType,
      type: InteractionType.like,
    );
  }

  /// Bookmark content
  Future<bool> bookmarkContent({
    required String userId,
    required String contentId,
    required String contentType,
  }) async {
    return await recordInteraction(
      userId: userId,
      contentId: contentId,
      contentType: contentType,
      type: InteractionType.bookmark,
    );
  }

  /// Report content
  Future<bool> reportContent({
    required String userId,
    required String contentId,
    required String contentType,
    required String reason,
    String? description,
  }) async {
    return await recordInteraction(
      userId: userId,
      contentId: contentId,
      contentType: contentType,
      type: InteractionType.report,
      metadata: {
        'reason': reason,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// View content (for analytics)
  Future<bool> viewContent({
    required String userId,
    required String contentId,
    required String contentType,
    int? duration,
  }) async {
    return await recordInteraction(
      userId: userId,
      contentId: contentId,
      contentType: contentType,
      type: InteractionType.view,
      metadata: {
        'duration': duration,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Share content
  Future<bool> shareContent({
    required String userId,
    required String contentId,
    required String contentType,
    String? platform,
  }) async {
    return await recordInteraction(
      userId: userId,
      contentId: contentId,
      contentType: contentType,
      type: InteractionType.share,
      metadata: {
        'platform': platform,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get user's bookmarked content
  Future<List<String>> getUserBookmarks(String userId, String contentType) async {
    try {
      final snapshot = await _firestore
          .collection('interactions')
          .where('userId', isEqualTo: userId)
          .where('contentType', isEqualTo: contentType)
          .where('type', isEqualTo: InteractionType.bookmark.name)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['contentId'] as String)
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting user bookmarks: $e');
      return [];
    }
  }

  /// Get user's liked content
  Future<List<String>> getUserLikes(String userId, String contentType) async {
    try {
      final snapshot = await _firestore
          .collection('interactions')
          .where('userId', isEqualTo: userId)
          .where('contentType', isEqualTo: contentType)
          .where('type', isEqualTo: InteractionType.like.name)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['contentId'] as String)
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting user likes: $e');
      return [];
    }
  }

  /// Clear cache
  void clearCache() {
    _interactionCache.clear();
    _countCache.clear();
    debugPrint('🧹 Interaction cache cleared');
  }

  /// Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}