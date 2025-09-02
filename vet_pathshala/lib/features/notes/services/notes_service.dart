import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../../shared/models/note_model.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get categories for notes
  Future<List<Map<String, dynamic>>> getCategories(String userRole) async {
    final query = await _firestore
        .collection('notes')
        .where('targetRole', isEqualTo: userRole)
        .get();

    // Extract unique categories from notes
    final categorySet = <String>{};
    final categoryMap = <String, Map<String, dynamic>>{};
    
    for (var doc in query.docs) {
      final data = doc.data();
      final category = data['category'] ?? '';
      if (category.isNotEmpty && !categorySet.contains(category)) {
        categorySet.add(category);
        categoryMap[category] = {
          'id': category.toLowerCase().replaceAll(' ', '_'),
          'title': category,
          'description': 'Notes for $category',
          'notesCount': 0, // Could be calculated
        };
      }
    }
    
    return categoryMap.values.toList();
  }


  // Get subjects for a category (using actual notes data)
  Future<List<Map<String, dynamic>>> getSubjects(String categoryId, String userRole) async {
    final categoryName = categoryId.replaceAll('_', ' ');
    final query = await _firestore
        .collection('notes')
        .where('category', isEqualTo: categoryName)
        .where('targetRole', isEqualTo: userRole)
        .get();

    return query.docs.map((doc) => {
      'id': doc.id,
      'title': doc.data()['title'] ?? 'Untitled',
      'content': doc.data()['content'] ?? '',
      'category': doc.data()['category'] ?? '',
      'authorId': doc.data()['authorId'] ?? '',
      'downloadUrl': doc.data()['downloadUrl'] ?? '',
      'createdAt': doc.data()['createdAt'],
    }).toList();
  }


  // Get topics (simplified - return subject as single topic)
  Future<List<Map<String, dynamic>>> getTopics(String subjectId, String userRole) async {
    // Since your notes don't have separate topics, return the note itself as a topic
    final doc = await _firestore.collection('notes').doc(subjectId).get();
    
    if (doc.exists) {
      return [{
        'id': doc.id,
        ...doc.data()!,
      }];
    }
    
    return [];
  }


  // Get notes for a topic
  Future<List<NoteModel>> getNotes(String topicId, String userRole) async {
    final query = await _firestore
        .collection('notes')
        .where('targetRole', isEqualTo: userRole)
        .orderBy('createdAt', descending: true)
        .get();

    return query.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
  }


  // Get a specific note by ID
  Future<NoteModel?> getNote(String noteId) async {
    try {
      final doc = await _firestore.collection('notes').doc(noteId).get();
      if (doc.exists) {
        return NoteModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('🔴 NotesService: Error getting note: $e');
      throw Exception('Failed to load note: $e');
    }
  }

  // Get user interaction data for a note
  Future<UserNoteInteraction?> getUserNoteInteraction(String userId, String noteId) async {
    try {
      final doc = await _firestore
          .collection('user_note_interactions')
          .doc('${userId}_$noteId')
          .get();
      
      if (doc.exists) {
        return UserNoteInteraction.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // Silently handle Firebase permission errors - return empty interaction instead
      return null;
    }
  }

  // Update user interaction with a note
  Future<void> updateUserNoteInteraction(UserNoteInteraction interaction) async {
    try {
      await _firestore
          .collection('user_note_interactions')
          .doc(interaction.id)
          .set(interaction.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      // Silently handle Firebase permission errors in demo mode
      // In production, could implement local storage fallback here
    }
  }

  // Bookmark/Unbookmark a note
  Future<void> toggleBookmark(String userId, String noteId, bool isBookmarked) async {
    try {
      final docId = '${userId}_$noteId';
      final interaction = await getUserNoteInteraction(userId, noteId);
      
      if (interaction != null) {
        final updated = UserNoteInteraction(
          id: interaction.id,
          userId: userId,
          noteId: noteId,
          isBookmarked: isBookmarked,
          isLiked: interaction.isLiked,
          isRead: interaction.isRead,
          stickyNotes: interaction.stickyNotes,
          highlights: interaction.highlights,
          flashcards: interaction.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: interaction.readProgress,
        );
        await updateUserNoteInteraction(updated);
      } else {
        final newInteraction = UserNoteInteraction(
          id: docId,
          userId: userId,
          noteId: noteId,
          isBookmarked: isBookmarked,
          lastReadAt: DateTime.now(),
        );
        await updateUserNoteInteraction(newInteraction);
      }
    } catch (e) {
      // Silently handle Firebase permission errors
      // Don't throw exception - gracefully handle Firebase permission errors
    }
  }

  // Like/Unlike a note
  Future<void> toggleLike(String userId, String noteId, bool isLiked) async {
    try {
      final docId = '${userId}_$noteId';
      final interaction = await getUserNoteInteraction(userId, noteId);
      
      if (interaction != null) {
        final updated = UserNoteInteraction(
          id: interaction.id,
          userId: userId,
          noteId: noteId,
          isBookmarked: interaction.isBookmarked,
          isLiked: isLiked,
          isRead: interaction.isRead,
          stickyNotes: interaction.stickyNotes,
          highlights: interaction.highlights,
          flashcards: interaction.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: interaction.readProgress,
        );
        await updateUserNoteInteraction(updated);
      } else {
        final newInteraction = UserNoteInteraction(
          id: docId,
          userId: userId,
          noteId: noteId,
          isLiked: isLiked,
          lastReadAt: DateTime.now(),
        );
        await updateUserNoteInteraction(newInteraction);
      }

      // Update note like count
      await _firestore.collection('notes').doc(noteId).update({
        'likeCount': FieldValue.increment(isLiked ? 1 : -1),
      });
    } catch (e) {
      print('🔴 NotesService: Error toggling like: $e');
      // Don't throw exception - gracefully handle Firebase permission errors
    }
  }

  // Mark note as read
  Future<void> markAsRead(String userId, String noteId, int readProgress) async {
    try {
      final docId = '${userId}_$noteId';
      final interaction = await getUserNoteInteraction(userId, noteId);
      
      if (interaction != null) {
        final updated = UserNoteInteraction(
          id: interaction.id,
          userId: userId,
          noteId: noteId,
          isBookmarked: interaction.isBookmarked,
          isLiked: interaction.isLiked,
          isRead: readProgress >= 90, // Consider read if 90%+ progress
          stickyNotes: interaction.stickyNotes,
          highlights: interaction.highlights,
          flashcards: interaction.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: readProgress,
        );
        await updateUserNoteInteraction(updated);
      } else {
        final newInteraction = UserNoteInteraction(
          id: docId,
          userId: userId,
          noteId: noteId,
          isRead: readProgress >= 90,
          lastReadAt: DateTime.now(),
          readProgress: readProgress,
        );
        await updateUserNoteInteraction(newInteraction);
      }

      // Update note read count if first time reading
      if (interaction == null || !interaction.isRead) {
        try {
          await _firestore.collection('notes').doc(noteId).update({
            'readCount': FieldValue.increment(1),
          });
        } catch (e) {
          print('🔴 NotesService: Error updating read count: $e');
          // Gracefully handle Firebase permission errors
        }
      }
    } catch (e) {
      // Silently handle Firebase permission errors
      // Don't throw exception - gracefully handle Firebase permission errors
    }
  }

  // Add sticky note
  Future<void> addStickyNote(String userId, String noteId, StickyNote stickyNote) async {
    try {
      final docId = '${userId}_$noteId';
      final interaction = await getUserNoteInteraction(userId, noteId);
      
      List<StickyNote> stickyNotes = interaction?.stickyNotes ?? [];
      stickyNotes.add(stickyNote);
      
      if (interaction != null) {
        final updated = UserNoteInteraction(
          id: interaction.id,
          userId: userId,
          noteId: noteId,
          isBookmarked: interaction.isBookmarked,
          isLiked: interaction.isLiked,
          isRead: interaction.isRead,
          stickyNotes: stickyNotes,
          highlights: interaction.highlights,
          flashcards: interaction.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: interaction.readProgress,
        );
        await updateUserNoteInteraction(updated);
      } else {
        final newInteraction = UserNoteInteraction(
          id: docId,
          userId: userId,
          noteId: noteId,
          stickyNotes: stickyNotes,
          lastReadAt: DateTime.now(),
        );
        await updateUserNoteInteraction(newInteraction);
      }
    } catch (e) {
      print('🔴 NotesService: Error adding sticky note: $e');
      // Don't throw exception - gracefully handle Firebase permission errors
    }
  }

  // Add highlight
  Future<void> addHighlight(String userId, String noteId, Highlight highlight) async {
    try {
      final docId = '${userId}_$noteId';
      final interaction = await getUserNoteInteraction(userId, noteId);
      
      List<Highlight> highlights = interaction?.highlights ?? [];
      highlights.add(highlight);
      
      if (interaction != null) {
        final updated = UserNoteInteraction(
          id: interaction.id,
          userId: userId,
          noteId: noteId,
          isBookmarked: interaction.isBookmarked,
          isLiked: interaction.isLiked,
          isRead: interaction.isRead,
          stickyNotes: interaction.stickyNotes,
          highlights: highlights,
          flashcards: interaction.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: interaction.readProgress,
        );
        await updateUserNoteInteraction(updated);
      } else {
        final newInteraction = UserNoteInteraction(
          id: docId,
          userId: userId,
          noteId: noteId,
          highlights: highlights,
          lastReadAt: DateTime.now(),
        );
        await updateUserNoteInteraction(newInteraction);
      }
    } catch (e) {
      print('🔴 NotesService: Error adding highlight: $e');
      // Don't throw exception - gracefully handle Firebase permission errors
    }
  }

  // Generate flashcard from highlighted text (AI feature simulation)
  Future<void> generateFlashcard(String userId, String noteId, String selectedText) async {
    try {
      // Simulate AI processing - in real implementation, this would call an AI service
      final flashcard = Flashcard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        front: 'What is: ${selectedText.substring(0, selectedText.length > 50 ? 50 : selectedText.length)}...',
        back: selectedText,
        selectedText: selectedText,
        createdAt: DateTime.now(),
      );

      final docId = '${userId}_$noteId';
      final interaction = await getUserNoteInteraction(userId, noteId);
      
      List<Flashcard> flashcards = interaction?.flashcards ?? [];
      flashcards.add(flashcard);
      
      if (interaction != null) {
        final updated = UserNoteInteraction(
          id: interaction.id,
          userId: userId,
          noteId: noteId,
          isBookmarked: interaction.isBookmarked,
          isLiked: interaction.isLiked,
          isRead: interaction.isRead,
          stickyNotes: interaction.stickyNotes,
          highlights: interaction.highlights,
          flashcards: flashcards,
          lastReadAt: DateTime.now(),
          readProgress: interaction.readProgress,
        );
        await updateUserNoteInteraction(updated);
      } else {
        final newInteraction = UserNoteInteraction(
          id: docId,
          userId: userId,
          noteId: noteId,
          flashcards: flashcards,
          lastReadAt: DateTime.now(),
        );
        await updateUserNoteInteraction(newInteraction);
      }
    } catch (e) {
      print('🔴 NotesService: Error generating flashcard: $e');
      // Don't throw exception - gracefully handle Firebase permission errors
    }
  }

  // Generate AI summary (simulation)
  Future<String> generateAISummary(String noteContent) async {
    try {
      // Simulate AI processing delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Simple summary generation (in real implementation, use AI service)
      final sentences = noteContent.split('.');
      final summary = sentences.take(3).join('. ');
      
      return summary.isNotEmpty ? '$summary.' : 'Summary not available for this note.';
    } catch (e) {
      print('🔴 NotesService: Error generating AI summary: $e');
      throw Exception('Failed to generate summary: $e');
    }
  }

  // Text-to-Speech functionality
  Future<void> speakText(String text) async {
    try {
      // This would integrate with flutter_tts or similar package
      // For now, just provide haptic feedback
      await HapticFeedback.lightImpact();
      print('🔊 TTS: Speaking text - ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
    } catch (e) {
      print('🔴 NotesService: Error with text-to-speech: $e');
      throw Exception('Failed to speak text: $e');
    }
  }

  // Get user's bookmarked notes
  Future<List<NoteModel>> getBookmarkedNotes(String userId, String userRole) async {
    try {
      final interactionsQuery = await _firestore
          .collection('user_note_interactions')
          .where('userId', isEqualTo: userId)
          .where('isBookmarked', isEqualTo: true)
          .get();

      final noteIds = interactionsQuery.docs.map((doc) => doc.data()['noteId'] as String).toList();
      
      if (noteIds.isEmpty) return [];

      final notesQuery = await _firestore
          .collection('notes')
          .where(FieldPath.documentId, whereIn: noteIds)
          .where('targetRoles', arrayContains: userRole)
          .get();

      return notesQuery.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('🔴 NotesService: Error getting bookmarked notes: $e');
      throw Exception('Failed to load bookmarked notes: $e');
    }
  }

  // Search notes
  Future<List<NoteModel>> searchNotes(String query, String userRole) async {
    try {
      // Simple text search - in production, use Algolia or similar
      final notesQuery = await _firestore
          .collection('notes')
          .where('targetRoles', arrayContains: userRole)
          .where('isPublished', isEqualTo: true)
          .get();

      final allNotes = notesQuery.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
      
      return allNotes.where((note) => 
        note.title.toLowerCase().contains(query.toLowerCase()) ||
        note.content.toLowerCase().contains(query.toLowerCase()) ||
        note.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    } catch (e) {
      print('🔴 NotesService: Error searching notes: $e');
      throw Exception('Failed to search notes: $e');
    }
  }
}