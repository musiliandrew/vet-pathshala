import 'package:cloud_firestore/cloud_firestore.dart';

class PYPPaper {
  final String id;
  final String title;
  final String subject;
  final String topic;
  final int year;
  final String examType; // 'university', 'competitive', 'mock'
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<String> tags;
  final String pdfUrl;
  final String thumbnailUrl;
  final int questions;
  final int duration; // in minutes
  final int maxMarks;
  final bool isPremium;
  final int coinCost;
  final DateTime uploadDate;
  final int downloads;
  final double rating;

  PYPPaper({
    required this.id,
    required this.title,
    required this.subject,
    required this.topic,
    required this.year,
    required this.examType,
    required this.difficulty,
    required this.tags,
    required this.pdfUrl,
    required this.thumbnailUrl,
    required this.questions,
    required this.duration,
    required this.maxMarks,
    this.isPremium = false,
    this.coinCost = 0,
    required this.uploadDate,
    this.downloads = 0,
    this.rating = 0.0,
  });

  factory PYPPaper.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PYPPaper.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  factory PYPPaper.fromJson(Map<String, dynamic> json) {
    return PYPPaper(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      topic: json['topic'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      examType: json['examType'] ?? 'university',
      difficulty: json['difficulty'] ?? 'medium',
      tags: List<String>.from(json['tags'] ?? []),
      pdfUrl: json['pdfUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      questions: json['questions'] ?? 0,
      duration: json['duration'] ?? 180,
      maxMarks: json['maxMarks'] ?? 100,
      isPremium: json['isPremium'] ?? false,
      coinCost: json['coinCost'] ?? 0,
      uploadDate: json['uploadDate'] is Timestamp 
          ? (json['uploadDate'] as Timestamp).toDate()
          : DateTime.parse(json['uploadDate'] ?? DateTime.now().toIso8601String()),
      downloads: json['downloads'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'topic': topic,
      'year': year,
      'examType': examType,
      'difficulty': difficulty,
      'tags': tags,
      'pdfUrl': pdfUrl,
      'thumbnailUrl': thumbnailUrl,
      'questions': questions,
      'duration': duration,
      'maxMarks': maxMarks,
      'isPremium': isPremium,
      'coinCost': coinCost,
      'uploadDate': uploadDate.toIso8601String(),
      'downloads': downloads,
      'rating': rating,
    };
  }
}

class PYPCategory {
  final String id;
  final String name;
  final String icon;
  final List<PYPSubject> subjects;
  final int totalPapers;

  PYPCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.subjects,
    this.totalPapers = 0,
  });

  factory PYPCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PYPCategory(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '📚',
      subjects: (data['subjects'] as List<dynamic>?)?.map((s) => PYPSubject.fromJson(s)).toList() ?? [],
      totalPapers: data['totalPapers'] ?? 0,
    );
  }
}

class PYPSubject {
  final String id;
  final String name;
  final String categoryId;
  final List<String> topics;
  final Map<int, int> yearWisePapers; // year -> paper count
  final int totalPapers;

  PYPSubject({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.topics,
    required this.yearWisePapers,
    this.totalPapers = 0,
  });

  factory PYPSubject.fromJson(Map<String, dynamic> json) {
    return PYPSubject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
      topics: List<String>.from(json['topics'] ?? []),
      yearWisePapers: Map<int, int>.from(json['yearWisePapers'] ?? {}),
      totalPapers: json['totalPapers'] ?? 0,
    );
  }
}