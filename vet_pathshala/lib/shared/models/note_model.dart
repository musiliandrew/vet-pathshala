import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final String subjectId;
  final String topicId;
  final List<String> targetRoles; // ['doctor', 'pharmacist', 'farmer']
  final String? imageUrl;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int readCount;
  final int likeCount;
  final String authorId;
  final Map<String, dynamic>? metadata;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.subjectId,
    required this.topicId,
    required this.targetRoles,
    this.imageUrl,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isPublished = true,
    this.readCount = 0,
    this.likeCount = 0,
    required this.authorId,
    this.metadata,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'subjectId': subjectId,
      'topicId': topicId,
      'targetRoles': targetRoles,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublished': isPublished,
      'readCount': readCount,
      'likeCount': likeCount,
      'authorId': authorId,
      'metadata': metadata,
    };
  }

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      categoryId: data['categoryId'] ?? '',
      subjectId: data['subjectId'] ?? '',
      topicId: data['topicId'] ?? '',
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? true,
      readCount: data['readCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      authorId: data['authorId'] ?? '',
      metadata: data['metadata'],
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? categoryId,
    String? subjectId,
    String? topicId,
    List<String>? targetRoles,
    String? imageUrl,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    int? readCount,
    int? likeCount,
    String? authorId,
    Map<String, dynamic>? metadata,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId ?? this.categoryId,
      subjectId: subjectId ?? this.subjectId,
      topicId: topicId ?? this.topicId,
      targetRoles: targetRoles ?? this.targetRoles,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      readCount: readCount ?? this.readCount,
      likeCount: likeCount ?? this.likeCount,
      authorId: authorId ?? this.authorId,
      metadata: metadata ?? this.metadata,
    );
  }
}

class UserNoteInteraction {
  final String id;
  final String userId;
  final String noteId;
  final bool isBookmarked;
  final bool isLiked;
  final bool isRead;
  final List<StickyNote> stickyNotes;
  final List<Highlight> highlights;
  final List<Flashcard> flashcards;
  final DateTime lastReadAt;
  final int readProgress; // Percentage 0-100

  const UserNoteInteraction({
    required this.id,
    required this.userId,
    required this.noteId,
    this.isBookmarked = false,
    this.isLiked = false,
    this.isRead = false,
    this.stickyNotes = const [],
    this.highlights = const [],
    this.flashcards = const [],
    required this.lastReadAt,
    this.readProgress = 0,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'noteId': noteId,
      'isBookmarked': isBookmarked,
      'isLiked': isLiked,
      'isRead': isRead,
      'stickyNotes': stickyNotes.map((note) => note.toMap()).toList(),
      'highlights': highlights.map((highlight) => highlight.toMap()).toList(),
      'flashcards': flashcards.map((card) => card.toMap()).toList(),
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'readProgress': readProgress,
    };
  }

  factory UserNoteInteraction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserNoteInteraction(
      id: doc.id,
      userId: data['userId'] ?? '',
      noteId: data['noteId'] ?? '',
      isBookmarked: data['isBookmarked'] ?? false,
      isLiked: data['isLiked'] ?? false,
      isRead: data['isRead'] ?? false,
      stickyNotes: (data['stickyNotes'] as List?)
          ?.map((note) => StickyNote.fromMap(note))
          .toList() ?? [],
      highlights: (data['highlights'] as List?)
          ?.map((highlight) => Highlight.fromMap(highlight))
          .toList() ?? [],
      flashcards: (data['flashcards'] as List?)
          ?.map((card) => Flashcard.fromMap(card))
          .toList() ?? [],
      lastReadAt: (data['lastReadAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readProgress: data['readProgress'] ?? 0,
    );
  }
}

class StickyNote {
  final String id;
  final String content;
  final int position; // Character position in note content
  final DateTime createdAt;
  final String color; // Hex color code

  const StickyNote({
    required this.id,
    required this.content,
    required this.position,
    required this.createdAt,
    this.color = '#FFEB3B', // Default yellow
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'position': position,
      'createdAt': Timestamp.fromDate(createdAt),
      'color': color,
    };
  }

  factory StickyNote.fromMap(Map<String, dynamic> map) {
    return StickyNote(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      position: map['position'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      color: map['color'] ?? '#FFEB3B',
    );
  }
}

class Highlight {
  final String id;
  final int startPosition;
  final int endPosition;
  final String selectedText;
  final String color;
  final DateTime createdAt;

  const Highlight({
    required this.id,
    required this.startPosition,
    required this.endPosition,
    required this.selectedText,
    this.color = '#FFFF00', // Default yellow highlight
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'selectedText': selectedText,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'] ?? '',
      startPosition: map['startPosition'] ?? 0,
      endPosition: map['endPosition'] ?? 0,
      selectedText: map['selectedText'] ?? '',
      color: map['color'] ?? '#FFFF00',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Flashcard {
  final String id;
  final String front; // Question/Term
  final String back; // Answer/Definition
  final String selectedText; // Original highlighted text
  final DateTime createdAt;
  final int reviewCount;
  final DateTime? lastReviewedAt;

  const Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.selectedText,
    required this.createdAt,
    this.reviewCount = 0,
    this.lastReviewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'selectedText': selectedText,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewCount': reviewCount,
      'lastReviewedAt': lastReviewedAt != null 
          ? Timestamp.fromDate(lastReviewedAt!)
          : null,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? '',
      front: map['front'] ?? '',
      back: map['back'] ?? '',
      selectedText: map['selectedText'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reviewCount: map['reviewCount'] ?? 0,
      lastReviewedAt: (map['lastReviewedAt'] as Timestamp?)?.toDate(),
    );
  }
}