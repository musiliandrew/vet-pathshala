import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../../shared/models/note_model.dart';

class NotesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get categories for notes (similar to question bank structure)
  Future<List<Map<String, dynamic>>> getCategories(String userRole) async {
    try {
      final query = await _firestore
          .collection('note_categories')
          .where('targetRoles', arrayContains: userRole)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('🔴 NotesService: Error getting categories, using sample data: $e');
      // Return sample data when Firebase is not available
      return _getSampleCategories();
    }
  }

  List<Map<String, dynamic>> _getSampleCategories() {
    return [
      {
        'id': 'cat_01',
        'title': 'Veterinary Medicine',
        'description': 'Core veterinary medical knowledge and clinical practices',
        'icon': 'medicine',
        'notesCount': 245,
        'color': '#4B5E4A',
        'targetRoles': ['doctor', 'pharmacist'],
        'isActive': true,
        'order': 1,
      },
      {
        'id': 'cat_02',
        'title': 'Animal Husbandry',
        'description': 'Animal care, management, and farming practices',
        'icon': 'nutrition',
        'notesCount': 189,
        'color': '#6B7A69',
        'targetRoles': ['doctor', 'farmer'],
        'isActive': true,
        'order': 2,
      },
      {
        'id': 'cat_03',
        'title': 'Pharmacology',
        'description': 'Drug knowledge, interactions, and applications',
        'icon': 'pharmacology',
        'notesCount': 156,
        'color': '#4B5E4A',
        'targetRoles': ['doctor', 'pharmacist'],
        'isActive': true,
        'order': 3,
      },
      {
        'id': 'cat_04',
        'title': 'Diagnostics & Lab',
        'description': 'Diagnostic procedures, lab tests, and interpretations',
        'icon': 'laboratory',
        'notesCount': 178,
        'color': '#6B7A69',
        'targetRoles': ['doctor'],
        'isActive': true,
        'order': 4,
      },
    ];
  }

  // Get subjects for a category
  Future<List<Map<String, dynamic>>> getSubjects(String categoryId, String userRole) async {
    try {
      final query = await _firestore
          .collection('note_subjects')
          .where('categoryId', isEqualTo: categoryId)
          .where('targetRoles', arrayContains: userRole)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('🔴 NotesService: Error getting subjects, using sample data: $e');
      return _getSampleSubjects(categoryId);
    }
  }

  List<Map<String, dynamic>> _getSampleSubjects(String categoryId) {
    final allSubjects = {
      'cat_01': [
        {
          'id': 'sub_01',
          'categoryId': 'cat_01',
          'title': 'Veterinary Anatomy',
          'description': 'Animal body structure and organ systems',
          'notesCount': 89,
          'color': '#4B5E4A',
          'icon': 'anatomy',
          'targetRoles': ['doctor', 'pharmacist'],
          'isActive': true,
          'order': 1,
        },
        {
          'id': 'sub_02',
          'categoryId': 'cat_01',
          'title': 'Animal Physiology',
          'description': 'Body functions and biological processes',
          'notesCount': 76,
          'color': '#6B7A69',
          'icon': 'physiology',
          'targetRoles': ['doctor'],
          'isActive': true,
          'order': 2,
        },
        {
          'id': 'sub_03',
          'categoryId': 'cat_01',
          'title': 'Pathology',
          'description': 'Disease mechanisms and diagnosis',
          'notesCount': 80,
          'color': '#4B5E4A',
          'icon': 'pathology',
          'targetRoles': ['doctor'],
          'isActive': true,
          'order': 3,
        },
      ],
      'cat_02': [
        {
          'id': 'sub_04',
          'categoryId': 'cat_02',
          'title': 'Livestock Management',
          'description': 'Care and management of farm animals',
          'notesCount': 67,
          'color': '#6B7A69',
          'icon': 'reproduction',
          'targetRoles': ['doctor', 'farmer'],
          'isActive': true,
          'order': 1,
        },
        {
          'id': 'sub_05',
          'categoryId': 'cat_02',
          'title': 'Animal Nutrition',
          'description': 'Feeding and nutritional requirements',
          'notesCount': 54,
          'color': '#4B5E4A',
          'icon': 'nutrition',
          'targetRoles': ['farmer'],
          'isActive': true,
          'order': 2,
        },
        {
          'id': 'sub_06',
          'categoryId': 'cat_02',
          'title': 'Breeding & Genetics',
          'description': 'Animal breeding and genetic principles',
          'notesCount': 68,
          'color': '#6B7A69',
          'icon': 'reproduction',
          'targetRoles': ['doctor', 'farmer'],
          'isActive': true,
          'order': 3,
        },
      ],
    };

    return allSubjects[categoryId] ?? [];
  }

  // Get topics for a subject
  Future<List<Map<String, dynamic>>> getTopics(String subjectId, String userRole) async {
    try {
      final query = await _firestore
          .collection('note_topics')
          .where('subjectId', isEqualTo: subjectId)
          .where('targetRoles', arrayContains: userRole)
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      return query.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    } catch (e) {
      print('🔴 NotesService: Error getting topics, using sample data: $e');
      return _getSampleTopics(subjectId);
    }
  }

  List<Map<String, dynamic>> _getSampleTopics(String subjectId) {
    final allTopics = {
      'sub_01': [
        {
          'id': 'top_01',
          'subjectId': 'sub_01',
          'title': 'Musculoskeletal System',
          'description': 'Bones, muscles, and joints',
          'notesCount': 23,
          'color': '#4B5E4A',
          'targetRoles': ['doctor'],
          'isActive': true,
          'order': 1,
        },
        {
          'id': 'top_02',
          'subjectId': 'sub_01',
          'title': 'Cardiovascular System',
          'description': 'Heart and blood vessels',
          'notesCount': 19,
          'color': '#6B7A69',
          'targetRoles': ['doctor'],
          'isActive': true,
          'order': 2,
        },
        {
          'id': 'top_03',
          'subjectId': 'sub_01',
          'title': 'Nervous System',
          'description': 'Brain, spinal cord, and nerves',
          'notesCount': 25,
          'color': '#4B5E4A',
          'targetRoles': ['doctor'],
          'isActive': true,
          'order': 3,
        },
        {
          'id': 'top_04',
          'subjectId': 'sub_01',
          'title': 'Digestive System',
          'description': 'Organs of digestion and absorption',
          'notesCount': 22,
          'color': '#6B7A69',
          'targetRoles': ['doctor'],
          'isActive': true,
          'order': 4,
        },
      ],
    };

    return allTopics[subjectId] ?? [];
  }

  // Get notes for a topic
  Future<List<NoteModel>> getNotes(String topicId, String userRole) async {
    try {
      final query = await _firestore
          .collection('notes')
          .where('topicId', isEqualTo: topicId)
          .where('targetRoles', arrayContains: userRole)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => NoteModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('🔴 NotesService: Error getting notes, using sample data: $e');
      return _getSampleNotes(topicId);
    }
  }

  List<NoteModel> _getSampleNotes(String topicId) {
    final now = DateTime.now();
    
    if (topicId == 'top_01') {
      return [
        NoteModel(
          id: 'note_01',
          title: 'Introduction to Bone Structure',
          content: '''# Introduction to Bone Structure

## Overview
Bones are complex living tissues that provide structural support, protect internal organs, and serve as sites for muscle attachment. Understanding bone structure is fundamental to veterinary medicine.

## Bone Composition
Bones consist of:
- **Organic matrix (35%)**: Primarily collagen fibers
- **Inorganic minerals (65%)**: Mainly calcium phosphate and calcium carbonate

## Types of Bone Tissue
### Compact Bone
Dense, hard tissue that forms the outer layer of bones. It provides strength and protection.

### Spongy Bone
Lighter, trabecular tissue found inside bones. It contains bone marrow and provides structural support.

## Bone Cells
1. **Osteoblasts**: Bone-building cells
2. **Osteocytes**: Mature bone cells
3. **Osteoclasts**: Bone-resorbing cells

## Clinical Significance
Understanding bone structure is crucial for:
- Diagnosing fractures
- Understanding bone diseases
- Planning surgical procedures
- Interpreting radiographs

## Key Points to Remember
- Bones are living, dynamic tissues
- They constantly remodel throughout life
- Proper nutrition is essential for bone health
- Age affects bone density and strength''',
          categoryId: 'cat_01',
          subjectId: 'sub_01',
          topicId: 'top_01',
          targetRoles: ['doctor', 'pharmacist'],
          tags: ['anatomy', 'bones', 'structure', 'fundamentals'],
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 2)),
          authorId: 'author_01',
        ),
        NoteModel(
          id: 'note_02',
          title: 'Joint Classification and Function',
          content: '''# Joint Classification and Function

## Introduction
Joints, also called articulations, are the connections between bones. They allow movement and provide mechanical support.

## Classification by Structure
### Fibrous Joints
- Connected by fibrous connective tissue
- Generally immovable (synarthroses)
- Examples: Skull sutures

### Cartilaginous Joints
- Connected by cartilage
- Slightly movable (amphiarthroses)
- Examples: Intervertebral discs

### Synovial Joints
- Most common and movable joints
- Have a joint cavity filled with synovial fluid
- Examples: Knee, shoulder, hip

## Synovial Joint Components
1. **Articular cartilage**: Smooth surface for movement
2. **Joint capsule**: Surrounds the joint
3. **Synovial membrane**: Lines the joint capsule
4. **Synovial fluid**: Lubricates the joint
5. **Ligaments**: Stabilize the joint

## Types of Synovial Joints
- **Ball and socket**: Hip, shoulder
- **Hinge**: Elbow, knee
- **Pivot**: Atlas-axis
- **Gliding**: Carpals, tarsals
- **Saddle**: Thumb
- **Condyloid**: Wrist

## Movement Types
- Flexion/Extension
- Abduction/Adduction
- Rotation
- Circumduction

## Clinical Applications
Joint knowledge is essential for:
- Lameness evaluation
- Arthritis diagnosis
- Surgical planning
- Physical therapy''',
          categoryId: 'cat_01',
          subjectId: 'sub_01',
          topicId: 'top_01',
          targetRoles: ['doctor'],
          tags: ['anatomy', 'joints', 'movement', 'classification'],
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 1)),
          authorId: 'author_02',
        ),
      ];
    }
    
    return [];
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
      print('🔴 NotesService: Error getting user interaction: $e');
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
      print('🔴 NotesService: Error updating user interaction: $e');
      // Don't throw exception - gracefully handle Firebase permission errors
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
      print('🔴 NotesService: Error toggling bookmark: $e');
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
      print('🔴 NotesService: Error marking as read: $e');
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