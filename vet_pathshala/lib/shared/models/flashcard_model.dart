import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardModel {
  final String id;
  final String userId;
  final String noteId;
  final String question;
  final String answer;
  final String category;
  final String difficulty; // easy, medium, hard
  final DateTime createdAt;
  final DateTime lastReviewed;
  final int reviewCount;
  final double confidence; // 0.0 to 1.0
  final List<String> tags;
  final bool isFavorite;
  final String? imageUrl;

  FlashcardModel({
    required this.id,
    required this.userId,
    required this.noteId,
    required this.question,
    required this.answer,
    required this.category,
    this.difficulty = 'medium',
    required this.createdAt,
    required this.lastReviewed,
    this.reviewCount = 0,
    this.confidence = 0.5,
    this.tags = const [],
    this.isFavorite = false,
    this.imageUrl,
  });

  factory FlashcardModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      noteId: data['noteId'] ?? '',
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'medium',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastReviewed: (data['lastReviewed'] as Timestamp).toDate(),
      reviewCount: data['reviewCount'] ?? 0,
      confidence: (data['confidence'] ?? 0.5).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      isFavorite: data['isFavorite'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'noteId': noteId,
      'question': question,
      'answer': answer,
      'category': category,
      'difficulty': difficulty,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastReviewed': Timestamp.fromDate(lastReviewed),
      'reviewCount': reviewCount,
      'confidence': confidence,
      'tags': tags,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
    };
  }

  FlashcardModel copyWith({
    String? id,
    String? userId,
    String? noteId,
    String? question,
    String? answer,
    String? category,
    String? difficulty,
    DateTime? createdAt,
    DateTime? lastReviewed,
    int? reviewCount,
    double? confidence,
    List<String>? tags,
    bool? isFavorite,
    String? imageUrl,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      noteId: noteId ?? this.noteId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
      confidence: confidence ?? this.confidence,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // Helper methods for spaced repetition
  bool get isDue {
    final now = DateTime.now();
    final daysSinceReview = now.difference(lastReviewed).inDays;
    
    // Spaced repetition intervals based on confidence
    if (confidence < 0.3) return daysSinceReview >= 1; // Daily review for low confidence
    if (confidence < 0.6) return daysSinceReview >= 3; // Every 3 days
    if (confidence < 0.8) return daysSinceReview >= 7; // Weekly
    return daysSinceReview >= 30; // Monthly for high confidence
  }

  String get difficultyIcon {
    switch (difficulty) {
      case 'easy':
        return '🟢';
      case 'hard':
        return '🔴';
      default:
        return '🟡';
    }
  }

  String get confidenceLabel {
    if (confidence < 0.3) return 'Need Practice';
    if (confidence < 0.6) return 'Learning';
    if (confidence < 0.8) return 'Good';
    return 'Mastered';
  }
}

class FlashcardSet {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<String> flashcardIds;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final int studyCount;

  FlashcardSet({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.flashcardIds,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.studyCount = 0,
  });

  factory FlashcardSet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardSet(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      flashcardIds: List<String>.from(data['flashcardIds'] ?? []),
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isPublic: data['isPublic'] ?? false,
      studyCount: data['studyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'flashcardIds': flashcardIds,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'studyCount': studyCount,
    };
  }
}

class FlashcardReview {
  final String id;
  final String userId;
  final String flashcardId;
  final DateTime reviewedAt;
  final bool wasCorrect;
  final double responseTime; // in seconds
  final double previousConfidence;
  final double newConfidence;

  FlashcardReview({
    required this.id,
    required this.userId,
    required this.flashcardId,
    required this.reviewedAt,
    required this.wasCorrect,
    required this.responseTime,
    required this.previousConfidence,
    required this.newConfidence,
  });

  factory FlashcardReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardReview(
      id: doc.id,
      userId: data['userId'] ?? '',
      flashcardId: data['flashcardId'] ?? '',
      reviewedAt: (data['reviewedAt'] as Timestamp).toDate(),
      wasCorrect: data['wasCorrect'] ?? false,
      responseTime: (data['responseTime'] ?? 0.0).toDouble(),
      previousConfidence: (data['previousConfidence'] ?? 0.5).toDouble(),
      newConfidence: (data['newConfidence'] ?? 0.5).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'flashcardId': flashcardId,
      'reviewedAt': Timestamp.fromDate(reviewedAt),
      'wasCorrect': wasCorrect,
      'responseTime': responseTime,
      'previousConfidence': previousConfidence,
      'newConfidence': newConfidence,
    };
  }
}