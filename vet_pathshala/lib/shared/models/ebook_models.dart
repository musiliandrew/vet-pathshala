import 'package:cloud_firestore/cloud_firestore.dart';

enum EbookCategory {
  anatomy,
  physiology,
  pathology,
  pharmacology,
  surgery,
  general_medicine,
  public_health,
  animal_husbandry
}

enum EbookType {
  textbook,
  reference,
  manual,
  guide,
  research_paper,
  case_study
}

enum AccessLevel {
  free,
  premium,
  subscription
}

class EbookModel {
  final String id;
  final String title;
  final String description;
  final String author;
  final String? publisher;
  final String coverImageUrl;
  final String pdfUrl;
  final EbookCategory category;
  final EbookType type;
  final AccessLevel accessLevel;
  final int coinCost;
  final List<String> targetRoles;
  final int totalPages;
  final String language;
  final DateTime publishedDate;
  final DateTime uploadedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;
  final double rating;
  final int downloadCount;

  EbookModel({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    this.publisher,
    required this.coverImageUrl,
    required this.pdfUrl,
    required this.category,
    required this.type,
    required this.accessLevel,
    this.coinCost = 0,
    this.targetRoles = const [],
    this.totalPages = 0,
    this.language = 'en',
    required this.publishedDate,
    required this.uploadedAt,
    this.isActive = true,
    this.metadata = const {},
    this.rating = 0.0,
    this.downloadCount = 0,
  });

  factory EbookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EbookModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      author: data['author'] ?? '',
      publisher: data['publisher'],
      coverImageUrl: data['coverImageUrl'] ?? '',
      pdfUrl: data['pdfUrl'] ?? '',
      category: EbookCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => EbookCategory.general_medicine,
      ),
      type: EbookType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => EbookType.textbook,
      ),
      accessLevel: AccessLevel.values.firstWhere(
        (e) => e.name == data['accessLevel'],
        orElse: () => AccessLevel.free,
      ),
      coinCost: data['coinCost'] ?? 0,
      targetRoles: List<String>.from(data['targetRoles'] ?? []),
      totalPages: data['totalPages'] ?? 0,
      language: data['language'] ?? 'en',
      publishedDate: (data['publishedDate'] as Timestamp).toDate(),
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      metadata: data['metadata'] ?? {},
      rating: (data['rating'] ?? 0.0).toDouble(),
      downloadCount: data['downloadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'publisher': publisher,
      'coverImageUrl': coverImageUrl,
      'pdfUrl': pdfUrl,
      'category': category.name,
      'type': type.name,
      'accessLevel': accessLevel.name,
      'coinCost': coinCost,
      'targetRoles': targetRoles,
      'totalPages': totalPages,
      'language': language,
      'publishedDate': Timestamp.fromDate(publishedDate),
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'isActive': isActive,
      'metadata': metadata,
      'rating': rating,
      'downloadCount': downloadCount,
    };
  }

  bool get isPremium => accessLevel != AccessLevel.free;
  bool get isDownloadable => accessLevel == AccessLevel.free || coinCost > 0;
}

class UserEbookModel {
  final String id;
  final String userId;
  final String ebookId;
  final DateTime accessedAt;
  final DateTime? downloadedAt;
  final int currentPage;
  final double readingProgress; // 0.0 to 1.0
  final bool isBookmarked;
  final bool isDownloaded;
  final DateTime lastReadAt;
  final int totalReadingTime; // in minutes
  final Map<String, dynamic> readingData;

  UserEbookModel({
    required this.id,
    required this.userId,
    required this.ebookId,
    required this.accessedAt,
    this.downloadedAt,
    this.currentPage = 1,
    this.readingProgress = 0.0,
    this.isBookmarked = false,
    this.isDownloaded = false,
    required this.lastReadAt,
    this.totalReadingTime = 0,
    this.readingData = const {},
  });

  factory UserEbookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserEbookModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      ebookId: data['ebookId'] ?? '',
      accessedAt: (data['accessedAt'] as Timestamp).toDate(),
      downloadedAt: (data['downloadedAt'] as Timestamp?)?.toDate(),
      currentPage: data['currentPage'] ?? 1,
      readingProgress: (data['readingProgress'] ?? 0.0).toDouble(),
      isBookmarked: data['isBookmarked'] ?? false,
      isDownloaded: data['isDownloaded'] ?? false,
      lastReadAt: (data['lastReadAt'] as Timestamp).toDate(),
      totalReadingTime: data['totalReadingTime'] ?? 0,
      readingData: data['readingData'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ebookId': ebookId,
      'accessedAt': Timestamp.fromDate(accessedAt),
      'downloadedAt': downloadedAt != null ? Timestamp.fromDate(downloadedAt!) : null,
      'currentPage': currentPage,
      'readingProgress': readingProgress,
      'isBookmarked': isBookmarked,
      'isDownloaded': isDownloaded,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'totalReadingTime': totalReadingTime,
      'readingData': readingData,
    };
  }
}

class EbookAnnotationModel {
  final String id;
  final String userId;
  final String ebookId;
  final int pageNumber;
  final String type; // 'highlight', 'note', 'bookmark'
  final String content;
  final String? selectedText;
  final Map<String, dynamic> position; // x, y coordinates, selection bounds
  final String color;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPrivate;

  EbookAnnotationModel({
    required this.id,
    required this.userId,
    required this.ebookId,
    required this.pageNumber,
    required this.type,
    required this.content,
    this.selectedText,
    this.position = const {},
    this.color = '#FFEB3B',
    required this.createdAt,
    this.updatedAt,
    this.isPrivate = true,
  });

  factory EbookAnnotationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EbookAnnotationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      ebookId: data['ebookId'] ?? '',
      pageNumber: data['pageNumber'] ?? 1,
      type: data['type'] ?? 'note',
      content: data['content'] ?? '',
      selectedText: data['selectedText'],
      position: data['position'] ?? {},
      color: data['color'] ?? '#FFEB3B',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isPrivate: data['isPrivate'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ebookId': ebookId,
      'pageNumber': pageNumber,
      'type': type,
      'content': content,
      'selectedText': selectedText,
      'position': position,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isPrivate': isPrivate,
    };
  }
}

class EbookBookmarkModel {
  final String id;
  final String userId;
  final String ebookId;
  final int pageNumber;
  final String title;
  final String? note;
  final DateTime createdAt;

  EbookBookmarkModel({
    required this.id,
    required this.userId,
    required this.ebookId,
    required this.pageNumber,
    required this.title,
    this.note,
    required this.createdAt,
  });

  factory EbookBookmarkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EbookBookmarkModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      ebookId: data['ebookId'] ?? '',
      pageNumber: data['pageNumber'] ?? 1,
      title: data['title'] ?? '',
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ebookId': ebookId,
      'pageNumber': pageNumber,
      'title': title,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class EbookReviewModel {
  final String id;
  final String userId;
  final String ebookId;
  final double rating; // 1.0 to 5.0
  final String? review;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;

  EbookReviewModel({
    required this.id,
    required this.userId,
    required this.ebookId,
    required this.rating,
    this.review,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
  });

  factory EbookReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EbookReviewModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      ebookId: data['ebookId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      review: data['review'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ebookId': ebookId,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isVerified': isVerified,
    };
  }
}