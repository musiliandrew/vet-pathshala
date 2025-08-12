import 'package:cloud_firestore/cloud_firestore.dart';

class EBook {
  final String id;
  final String title;
  final String author;
  final String description;
  final String category;
  final String? coverImageUrl;
  final String? pdfUrl;
  final int totalPages;
  final double fileSize; // MB
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final bool isPremium;
  final DateTime publishedDate;
  final DateTime createdAt;
  final String language;
  final String difficulty; // 'beginner', 'intermediate', 'advanced'

  EBook({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.category,
    this.coverImageUrl,
    this.pdfUrl,
    required this.totalPages,
    required this.fileSize,
    this.tags = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isPremium = false,
    required this.publishedDate,
    required this.createdAt,
    this.language = 'English',
    this.difficulty = 'intermediate',
  });

  factory EBook.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EBook(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      coverImageUrl: data['coverImageUrl'],
      pdfUrl: data['pdfUrl'],
      totalPages: data['totalPages'] ?? 0,
      fileSize: (data['fileSize'] ?? 0).toDouble(),
      tags: List<String>.from(data['tags'] ?? []),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      publishedDate: (data['publishedDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      language: data['language'] ?? 'English',
      difficulty: data['difficulty'] ?? 'intermediate',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'category': category,
      'coverImageUrl': coverImageUrl,
      'pdfUrl': pdfUrl,
      'totalPages': totalPages,
      'fileSize': fileSize,
      'tags': tags,
      'rating': rating,
      'reviewCount': reviewCount,
      'isPremium': isPremium,
      'publishedDate': Timestamp.fromDate(publishedDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'language': language,
      'difficulty': difficulty,
    };
  }

  String get fileSizeDisplay {
    if (fileSize < 1) return '${(fileSize * 1000).toInt()} KB';
    return '${fileSize.toStringAsFixed(1)} MB';
  }

  String get estimatedReadTime {
    final minutes = (totalPages * 2.5).round(); // Assuming 2.5 minutes per page
    if (minutes < 60) return '$minutes min';
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  String get difficultyDisplay {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Intermediate';
    }
  }
}

class ReadingProgress {
  final String id;
  final String userId;
  final String ebookId;
  final int currentPage;
  final int totalPages;
  final DateTime lastReadAt;
  final int timeSpent; // minutes
  final List<String> bookmarks;
  final Map<String, String> notes; // page -> note content

  ReadingProgress({
    required this.id,
    required this.userId,
    required this.ebookId,
    required this.currentPage,
    required this.totalPages,
    required this.lastReadAt,
    this.timeSpent = 0,
    this.bookmarks = const [],
    this.notes = const {},
  });

  factory ReadingProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReadingProgress(
      id: doc.id,
      userId: data['userId'] ?? '',
      ebookId: data['ebookId'] ?? '',
      currentPage: data['currentPage'] ?? 1,
      totalPages: data['totalPages'] ?? 0,
      lastReadAt: (data['lastReadAt'] as Timestamp).toDate(),
      timeSpent: data['timeSpent'] ?? 0,
      bookmarks: List<String>.from(data['bookmarks'] ?? []),
      notes: Map<String, String>.from(data['notes'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ebookId': ebookId,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'timeSpent': timeSpent,
      'bookmarks': bookmarks,
      'notes': notes,
    };
  }

  double get progressPercentage => totalPages > 0 ? currentPage / totalPages : 0.0;
  bool get isCompleted => currentPage >= totalPages;
  bool get isStarted => currentPage > 1;

  String get progressDisplay {
    return '${(progressPercentage * 100).toInt()}% • Page $currentPage of $totalPages';
  }

  String get timeSpentDisplay {
    if (timeSpent < 60) return '${timeSpent}m';
    final hours = (timeSpent / 60).floor();
    final minutes = timeSpent % 60;
    return '${hours}h ${minutes}m';
  }
}

class EBookCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int bookCount;
  final String? imageUrl;

  EBookCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.bookCount = 0,
    this.imageUrl,
  });

  factory EBookCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EBookCategory(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'] ?? 'book',
      bookCount: data['bookCount'] ?? 0,
      imageUrl: data['imageUrl'],
    );
  }

  static List<EBookCategory> getDefaultCategories() {
    return [
      EBookCategory(
        id: 'anatomy',
        name: 'Anatomy & Physiology',
        description: 'Animal anatomy and physiological systems',
        iconName: 'anatomy',
        bookCount: 12,
      ),
      EBookCategory(
        id: 'surgery',
        name: 'Surgery',
        description: 'Surgical procedures and techniques',
        iconName: 'surgery',
        bookCount: 8,
      ),
      EBookCategory(
        id: 'medicine',
        name: 'Internal Medicine',
        description: 'Diagnosis and treatment of diseases',
        iconName: 'medicine',
        bookCount: 15,
      ),
      EBookCategory(
        id: 'pharmacology',
        name: 'Pharmacology',
        description: 'Drug knowledge and interactions',
        iconName: 'pharmacy',
        bookCount: 10,
      ),
      EBookCategory(
        id: 'nutrition',
        name: 'Animal Nutrition',
        description: 'Feeding and nutritional requirements',
        iconName: 'nutrition',
        bookCount: 6,
      ),
      EBookCategory(
        id: 'reproduction',
        name: 'Reproduction',
        description: 'Breeding and reproductive health',
        iconName: 'reproduction',
        bookCount: 7,
      ),
    ];
  }
}

class EBookReview {
  final String id;
  final String userId;
  final String ebookId;
  final String userName;
  final double rating;
  final String review;
  final DateTime createdAt;
  final List<String> helpful; // user IDs who found this helpful

  EBookReview({
    required this.id,
    required this.userId,
    required this.ebookId,
    required this.userName,
    required this.rating,
    required this.review,
    required this.createdAt,
    this.helpful = const [],
  });

  factory EBookReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EBookReview(
      id: doc.id,
      userId: data['userId'] ?? '',
      ebookId: data['ebookId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      rating: (data['rating'] ?? 0).toDouble(),
      review: data['review'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      helpful: List<String>.from(data['helpful'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ebookId': ebookId,
      'userName': userName,
      'rating': rating,
      'review': review,
      'createdAt': Timestamp.fromDate(createdAt),
      'helpful': helpful,
    };
  }

  int get helpfulCount => helpful.length;
  bool isHelpfulBy(String userId) => helpful.contains(userId);
}