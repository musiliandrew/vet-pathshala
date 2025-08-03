import 'package:flutter/foundation.dart';
import '../../../shared/models/note_model.dart';
import '../services/notes_service.dart';

enum NotesState { initial, loading, loaded, error }

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();

  // State management
  NotesState _state = NotesState.initial;
  String? _errorMessage;

  // Navigation data
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _topics = [];
  List<NoteModel> _notes = [];

  // Current selections
  String? _selectedCategoryId;
  String? _selectedSubjectId;
  String? _selectedTopicId;
  NoteModel? _currentNote;
  UserNoteInteraction? _currentInteraction;

  // User data
  List<NoteModel> _bookmarkedNotes = [];
  List<NoteModel> _searchResults = [];
  String _searchQuery = '';

  // AI features
  bool _isGeneratingSummary = false;
  String? _aiSummary;
  bool _isSpeaking = false;

  // Getters
  NotesState get state => _state;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get subjects => _subjects;
  List<Map<String, dynamic>> get topics => _topics;
  List<NoteModel> get notes => _notes;
  
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedSubjectId => _selectedSubjectId;
  String? get selectedTopicId => _selectedTopicId;
  NoteModel? get currentNote => _currentNote;
  UserNoteInteraction? get currentInteraction => _currentInteraction;
  
  List<NoteModel> get bookmarkedNotes => _bookmarkedNotes;
  List<NoteModel> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  
  bool get isGeneratingSummary => _isGeneratingSummary;
  String? get aiSummary => _aiSummary;
  bool get isSpeaking => _isSpeaking;

  bool get isLoading => _state == NotesState.loading;
  bool get hasError => _state == NotesState.error;

  // Load categories
  Future<void> loadCategories(String userRole) async {
    _setState(NotesState.loading);
    try {
      _categories = await _notesService.getCategories(userRole);
      _setState(NotesState.loaded);
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  // Load subjects for selected category
  Future<void> loadSubjects(String categoryId, String userRole) async {
    _setState(NotesState.loading);
    try {
      _selectedCategoryId = categoryId;
      _subjects = await _notesService.getSubjects(categoryId, userRole);
      // Clear downstream selections
      _selectedSubjectId = null;
      _selectedTopicId = null;
      _topics.clear();
      _notes.clear();
      _setState(NotesState.loaded);
    } catch (e) {
      _setError('Failed to load subjects: $e');
    }
  }

  // Load topics for selected subject
  Future<void> loadTopics(String subjectId, String userRole) async {
    _setState(NotesState.loading);
    try {
      _selectedSubjectId = subjectId;
      _topics = await _notesService.getTopics(subjectId, userRole);
      // Clear downstream selections
      _selectedTopicId = null;
      _notes.clear();
      _setState(NotesState.loaded);
    } catch (e) {
      _setError('Failed to load topics: $e');
    }
  }

  // Load notes for selected topic
  Future<void> loadNotes(String topicId, String userRole) async {
    _setState(NotesState.loading);
    try {
      _selectedTopicId = topicId;
      _notes = await _notesService.getNotes(topicId, userRole);
      _setState(NotesState.loaded);
    } catch (e) {
      _setError('Failed to load notes: $e');
    }
  }

  // Load specific note and user interaction
  Future<void> loadNote(String noteId, String userId) async {
    _setState(NotesState.loading);
    try {
      _currentNote = await _notesService.getNote(noteId);
      _currentInteraction = await _notesService.getUserNoteInteraction(userId, noteId);
      _aiSummary = null; // Clear previous summary
      _setState(NotesState.loaded);
    } catch (e) {
      _setError('Failed to load note: $e');
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String userId, String noteId) async {
    try {
      final currentState = _currentInteraction?.isBookmarked ?? false;
      await _notesService.toggleBookmark(userId, noteId, !currentState);
      
      // Update local state
      if (_currentInteraction != null) {
        _currentInteraction = UserNoteInteraction(
          id: _currentInteraction!.id,
          userId: _currentInteraction!.userId,
          noteId: _currentInteraction!.noteId,
          isBookmarked: !currentState,
          isLiked: _currentInteraction!.isLiked,
          isRead: _currentInteraction!.isRead,
          stickyNotes: _currentInteraction!.stickyNotes,
          highlights: _currentInteraction!.highlights,
          flashcards: _currentInteraction!.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: _currentInteraction!.readProgress,
        );
      } else {
        _currentInteraction = UserNoteInteraction(
          id: '${userId}_$noteId',
          userId: userId,
          noteId: noteId,
          isBookmarked: !currentState,
          lastReadAt: DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to bookmark note: $e');
    }
  }

  // Toggle like
  Future<void> toggleLike(String userId, String noteId) async {
    try {
      final currentState = _currentInteraction?.isLiked ?? false;
      await _notesService.toggleLike(userId, noteId, !currentState);
      
      // Update local state
      if (_currentInteraction != null) {
        _currentInteraction = UserNoteInteraction(
          id: _currentInteraction!.id,
          userId: _currentInteraction!.userId,
          noteId: _currentInteraction!.noteId,
          isBookmarked: _currentInteraction!.isBookmarked,
          isLiked: !currentState,
          isRead: _currentInteraction!.isRead,
          stickyNotes: _currentInteraction!.stickyNotes,
          highlights: _currentInteraction!.highlights,
          flashcards: _currentInteraction!.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: _currentInteraction!.readProgress,
        );
      } else {
        _currentInteraction = UserNoteInteraction(
          id: '${userId}_$noteId',
          userId: userId,
          noteId: noteId,
          isLiked: !currentState,
          lastReadAt: DateTime.now(),
        );
      }

      // Update note like count
      if (_currentNote != null) {
        _currentNote = _currentNote!.copyWith(
          likeCount: _currentNote!.likeCount + (currentState ? -1 : 1),
        );
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to like note: $e');
    }
  }

  // Mark as read with progress
  Future<void> updateReadProgress(String userId, String noteId, int progress) async {
    try {
      await _notesService.markAsRead(userId, noteId, progress);
      
      // Update local state
      if (_currentInteraction != null) {
        _currentInteraction = UserNoteInteraction(
          id: _currentInteraction!.id,
          userId: _currentInteraction!.userId,
          noteId: _currentInteraction!.noteId,
          isBookmarked: _currentInteraction!.isBookmarked,
          isLiked: _currentInteraction!.isLiked,
          isRead: progress >= 90,
          stickyNotes: _currentInteraction!.stickyNotes,
          highlights: _currentInteraction!.highlights,
          flashcards: _currentInteraction!.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: progress,
        );
      } else {
        _currentInteraction = UserNoteInteraction(
          id: '${userId}_$noteId',
          userId: userId,
          noteId: noteId,
          isRead: progress >= 90,
          lastReadAt: DateTime.now(),
          readProgress: progress,
        );
      }
      notifyListeners();
    } catch (e) {
      print('Error updating read progress: $e');
    }
  }

  // Add sticky note
  Future<void> addStickyNote(String userId, String noteId, String content, int position) async {
    try {
      final stickyNote = StickyNote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        position: position,
        createdAt: DateTime.now(),
      );

      await _notesService.addStickyNote(userId, noteId, stickyNote);
      
      // Update local state
      if (_currentInteraction != null) {
        final updatedStickyNotes = List<StickyNote>.from(_currentInteraction!.stickyNotes)
          ..add(stickyNote);
        
        _currentInteraction = UserNoteInteraction(
          id: _currentInteraction!.id,
          userId: _currentInteraction!.userId,
          noteId: _currentInteraction!.noteId,
          isBookmarked: _currentInteraction!.isBookmarked,
          isLiked: _currentInteraction!.isLiked,
          isRead: _currentInteraction!.isRead,
          stickyNotes: updatedStickyNotes,
          highlights: _currentInteraction!.highlights,
          flashcards: _currentInteraction!.flashcards,
          lastReadAt: DateTime.now(),
          readProgress: _currentInteraction!.readProgress,
        );
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to add sticky note: $e');
    }
  }

  // Generate flashcard from selected text
  Future<void> generateFlashcard(String userId, String noteId, String selectedText) async {
    try {
      await _notesService.generateFlashcard(userId, noteId, selectedText);
      
      // Reload interaction to get updated flashcards
      _currentInteraction = await _notesService.getUserNoteInteraction(userId, noteId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate flashcard: $e');
    }
  }

  // Generate AI summary
  Future<void> generateAISummary() async {
    if (_currentNote == null) return;
    
    _isGeneratingSummary = true;
    notifyListeners();
    
    try {
      _aiSummary = await _notesService.generateAISummary(_currentNote!.content);
    } catch (e) {
      _setError('Failed to generate summary: $e');
    } finally {
      _isGeneratingSummary = false;
      notifyListeners();
    }
  }

  // Text-to-speech
  Future<void> speakNote() async {
    if (_currentNote == null) return;
    
    _isSpeaking = true;
    notifyListeners();
    
    try {
      await _notesService.speakText(_currentNote!.content);
    } catch (e) {
      _setError('Failed to speak note: $e');
    } finally {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  // Load bookmarked notes
  Future<void> loadBookmarkedNotes(String userId, String userRole) async {
    _setState(NotesState.loading);
    try {
      _bookmarkedNotes = await _notesService.getBookmarkedNotes(userId, userRole);
      _setState(NotesState.loaded);
    } catch (e) {
      _setError('Failed to load bookmarked notes: $e');
    }
  }

  // Search notes
  Future<void> searchNotes(String query, String userRole) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults.clear();
      notifyListeners();
      return;
    }

    _setState(NotesState.loading);
    try {
      _searchResults = await _notesService.searchNotes(query, userRole);
      _setState(NotesState.loaded);
    } catch (e) {
      _setError('Failed to search notes: $e');
    }
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults.clear();
    notifyListeners();
  }

  // Reset to categories view
  void resetToCategories() {
    _selectedCategoryId = null;
    _selectedSubjectId = null;
    _selectedTopicId = null;
    _subjects.clear();
    _topics.clear();
    _notes.clear();
    _currentNote = null;
    _currentInteraction = null;
    _aiSummary = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == NotesState.error) {
      _setState(NotesState.loaded);
    }
  }

  // Helper methods
  void _setState(NotesState newState) {
    _state = newState;
    if (newState != NotesState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = NotesState.error;
    notifyListeners();
  }
}