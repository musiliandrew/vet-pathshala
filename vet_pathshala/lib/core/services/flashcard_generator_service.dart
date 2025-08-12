import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/flashcard_model.dart';
import '../../shared/models/note_model.dart';

class FlashcardGeneratorService {
  static final FlashcardGeneratorService _instance = FlashcardGeneratorService._internal();
  factory FlashcardGeneratorService() => _instance;
  FlashcardGeneratorService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate flashcards from note content using rule-based approach
  /// In production, this would integrate with AI services like OpenAI
  Future<List<FlashcardModel>> generateFlashcardsFromNote({
    required String userId,
    required NoteModel note,
    int maxCards = 10,
  }) async {
    try {
      debugPrint('🎯 Generating flashcards from note: ${note.title}');
      
      final flashcards = <FlashcardModel>[];
      final content = note.content;
      
      // Method 1: Extract definition-based flashcards
      flashcards.addAll(await _extractDefinitionFlashcards(
        userId: userId,
        noteId: note.id,
        content: content,
        category: note.categoryId,
      ));

      // Method 2: Extract list-based flashcards
      flashcards.addAll(await _extractListFlashcards(
        userId: userId,
        noteId: note.id,
        content: content,
        category: note.categoryId,
      ));

      // Method 3: Extract question-based flashcards
      flashcards.addAll(await _extractQuestionFlashcards(
        userId: userId,
        noteId: note.id,
        content: content,
        category: note.categoryId,
      ));

      // Method 4: Extract key concept flashcards
      flashcards.addAll(await _extractKeyConceptFlashcards(
        userId: userId,
        noteId: note.id,
        content: content,
        category: note.categoryId,
      ));

      // Limit the number of cards and prioritize by quality
      final prioritizedCards = _prioritizeFlashcards(flashcards, maxCards);

      debugPrint('✅ Generated ${prioritizedCards.length} flashcards');
      return prioritizedCards;

    } catch (e) {
      debugPrint('❌ Error generating flashcards: $e');
      return [];
    }
  }

  /// Extract definition-based flashcards (e.g., "X is defined as Y")
  Future<List<FlashcardModel>> _extractDefinitionFlashcards({
    required String userId,
    required String noteId,
    required String content,
    required String category,
  }) async {
    final flashcards = <FlashcardModel>[];
    final now = DateTime.now();

    // Patterns for definitions
    final definitionPatterns = [
      RegExp(r'([A-Z][a-zA-Z\s]+)\s+is\s+defined\s+as\s+([^.!?]+[.!?])', caseSensitive: false),
      RegExp(r'([A-Z][a-zA-Z\s]+)\s+is\s+([^.!?]+[.!?])', caseSensitive: false),
      RegExp(r'([A-Z][a-zA-Z\s]+):\s*([^.\n]+)', caseSensitive: false),
      RegExp(r'\*\*([^*]+)\*\*:\s*([^.\n]+)', caseSensitive: false), // Markdown bold
    ];

    for (final pattern in definitionPatterns) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        if (match.groupCount >= 2) {
          final term = match.group(1)!.trim();
          final definition = match.group(2)!.trim();
          
          if (term.length > 3 && definition.length > 10) {
            final flashcard = FlashcardModel(
              id: _generateId(),
              userId: userId,
              noteId: noteId,
              question: 'What is $term?',
              answer: definition,
              category: category,
              difficulty: _assessDifficulty(term, definition),
              createdAt: now,
              lastReviewed: now,
              tags: ['definition', 'auto-generated'],
            );
            flashcards.add(flashcard);
          }
        }
      }
    }

    return flashcards;
  }

  /// Extract list-based flashcards (e.g., numbered or bulleted lists)
  Future<List<FlashcardModel>> _extractListFlashcards({
    required String userId,
    required String noteId,
    required String content,
    required String category,
  }) async {
    final flashcards = <FlashcardModel>[];
    final now = DateTime.now();

    // Find lists with headers
    final listPattern = RegExp(
      r'([A-Z][^:\n]+):\s*\n((?:\s*[-*•]\s*[^\n]+\n?)+)',
      multiLine: true,
      caseSensitive: false,
    );

    final matches = listPattern.allMatches(content);
    for (final match in matches) {
      final header = match.group(1)!.trim();
      final listContent = match.group(2)!.trim();
      
      final items = listContent.split(RegExp(r'\n\s*[-*•]\s*'))
          .where((item) => item.trim().isNotEmpty)
          .map((item) => item.trim().replaceAll(RegExp(r'^\s*[-*•]\s*'), ''))
          .toList();

      if (items.length >= 2 && items.length <= 8) {
        final flashcard = FlashcardModel(
          id: _generateId(),
          userId: userId,
          noteId: noteId,
          question: 'List the main points about: $header',
          answer: items.map((item) => '• $item').join('\n'),
          category: category,
          difficulty: items.length > 5 ? 'hard' : 'medium',
          createdAt: now,
          lastReviewed: now,
          tags: ['list', 'auto-generated'],
        );
        flashcards.add(flashcard);

        // Also create individual item flashcards for longer lists
        if (items.length >= 4) {
          for (int i = 0; i < min(items.length, 3); i++) {
            final item = items[i];
            if (item.length > 10) {
              final itemCard = FlashcardModel(
                id: _generateId(),
                userId: userId,
                noteId: noteId,
                question: 'What is one key point about $header?',
                answer: item,
                category: category,
                difficulty: 'easy',
                createdAt: now,
                lastReviewed: now,
                tags: ['list-item', 'auto-generated'],
              );
              flashcards.add(itemCard);
            }
          }
        }
      }
    }

    return flashcards;
  }

  /// Extract question-based flashcards from existing questions in content
  Future<List<FlashcardModel>> _extractQuestionFlashcards({
    required String userId,
    required String noteId,
    required String content,
    required String category,
  }) async {
    final flashcards = <FlashcardModel>[];
    final now = DateTime.now();

    // Look for Q&A patterns
    final qaPattern = RegExp(
      r'Q(?:uestion)?\s*:?\s*([^?\n]+\?)\s*A(?:nswer)?\s*:?\s*([^.\n]+)',
      caseSensitive: false,
      multiLine: true,
    );

    final matches = qaPattern.allMatches(content);
    for (final match in matches) {
      final question = match.group(1)!.trim();
      final answer = match.group(2)!.trim();
      
      if (question.length > 5 && answer.length > 5) {
        final flashcard = FlashcardModel(
          id: _generateId(),
          userId: userId,
          noteId: noteId,
          question: question,
          answer: answer,
          category: category,
          difficulty: _assessDifficulty(question, answer),
          createdAt: now,
          lastReviewed: now,
          tags: ['qa', 'auto-generated'],
        );
        flashcards.add(flashcard);
      }
    }

    return flashcards;
  }

  /// Extract key concept flashcards from emphasized text
  Future<List<FlashcardModel>> _extractKeyConceptFlashcards({
    required String userId,
    required String noteId,
    required String content,
    required String category,
  }) async {
    final flashcards = <FlashcardModel>[];
    final now = DateTime.now();

    // Extract bold/emphasized terms with context
    final emphasisPatterns = [
      RegExp(r'\*\*([^*]+)\*\*([^.!?\n]{10,})', caseSensitive: false), // **term** context
      RegExp(r'\*([^*]+)\*([^.!?\n]{10,})', caseSensitive: false), // *term* context
      RegExp(r'`([^`]+)`([^.!?\n]{10,})', caseSensitive: false), // `term` context
    ];

    for (final pattern in emphasisPatterns) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        final term = match.group(1)!.trim();
        final context = match.group(2)!.trim();
        
        if (term.length > 2 && context.length > 15) {
          final flashcard = FlashcardModel(
            id: _generateId(),
            userId: userId,
            noteId: noteId,
            question: 'Explain: $term',
            answer: context.length > 200 ? '${context.substring(0, 200)}...' : context,
            category: category,
            difficulty: _assessDifficulty(term, context),
            createdAt: now,
            lastReviewed: now,
            tags: ['concept', 'auto-generated'],
          );
          flashcards.add(flashcard);
        }
      }
    }

    return flashcards;
  }

  /// Assess difficulty based on content complexity
  String _assessDifficulty(String question, String answer) {
    final combinedLength = question.length + answer.length;
    final wordCount = (question.split(' ').length + answer.split(' ').length);
    
    // Check for complex terms (medical/scientific)
    final complexTerms = RegExp(r'\b[A-Z][a-z]+(?:ology|pathy|osis|itis|ectomy|oma)\b');
    final hasComplexTerms = complexTerms.hasMatch(question + answer);
    
    if (hasComplexTerms || combinedLength > 200 || wordCount > 40) {
      return 'hard';
    } else if (combinedLength > 100 || wordCount > 20) {
      return 'medium';
    }
    return 'easy';
  }

  /// Prioritize flashcards by quality and remove duplicates
  List<FlashcardModel> _prioritizeFlashcards(List<FlashcardModel> flashcards, int maxCards) {
    // Remove near-duplicates
    final uniqueCards = <FlashcardModel>[];
    for (final card in flashcards) {
      final isDuplicate = uniqueCards.any((existing) =>
          _calculateSimilarity(existing.question, card.question) > 0.8 ||
          _calculateSimilarity(existing.answer, card.answer) > 0.8
      );
      
      if (!isDuplicate) {
        uniqueCards.add(card);
      }
    }

    // Sort by quality (length, complexity, etc.)
    uniqueCards.sort((a, b) {
      final scoreA = _calculateQualityScore(a);
      final scoreB = _calculateQualityScore(b);
      return scoreB.compareTo(scoreA); // Higher score first
    });

    return uniqueCards.take(maxCards).toList();
  }

  /// Calculate similarity between two strings (simple Jaccard similarity)
  double _calculateSimilarity(String text1, String text2) {
    final words1 = text1.toLowerCase().split(' ').toSet();
    final words2 = text2.toLowerCase().split(' ').toSet();
    final intersection = words1.intersection(words2);
    final union = words1.union(words2);
    
    return union.isEmpty ? 0.0 : intersection.length / union.length;
  }

  /// Calculate quality score for flashcard
  double _calculateQualityScore(FlashcardModel card) {
    double score = 0.0;
    
    // Length scoring (prefer medium-length content)
    final questionLength = card.question.length;
    final answerLength = card.answer.length;
    
    if (questionLength >= 10 && questionLength <= 100) score += 2.0;
    if (answerLength >= 20 && answerLength <= 300) score += 3.0;
    
    // Preference for certain types
    if (card.tags.contains('definition')) score += 1.5;
    if (card.tags.contains('qa')) score += 1.0;
    if (card.tags.contains('concept')) score += 0.5;
    
    // Difficulty bonus (medium difficulty preferred)
    if (card.difficulty == 'medium') score += 1.0;
    else if (card.difficulty == 'easy') score += 0.5;
    
    return score;
  }

  /// Save flashcards to Firestore
  Future<bool> saveFlashcardsToFirestore(List<FlashcardModel> flashcards) async {
    try {
      final batch = _firestore.batch();
      
      for (final flashcard in flashcards) {
        final docRef = _firestore.collection('flashcards').doc(flashcard.id);
        batch.set(docRef, flashcard.toFirestore());
      }
      
      await batch.commit();
      debugPrint('✅ Saved ${flashcards.length} flashcards to Firestore');
      return true;
    } catch (e) {
      debugPrint('❌ Error saving flashcards: $e');
      return false;
    }
  }

  /// Generate unique ID for flashcards
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString().padLeft(3, '0');
  }

  /// Load user's flashcards from Firestore
  Future<List<FlashcardModel>> getUserFlashcards(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('flashcards')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FlashcardModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading flashcards: $e');
      return [];
    }
  }

  /// Get flashcards for a specific note
  Future<List<FlashcardModel>> getFlashcardsForNote(String userId, String noteId) async {
    try {
      final snapshot = await _firestore
          .collection('flashcards')
          .where('userId', isEqualTo: userId)
          .where('noteId', isEqualTo: noteId)
          .get();

      return snapshot.docs
          .map((doc) => FlashcardModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading flashcards for note: $e');
      return [];
    }
  }
}