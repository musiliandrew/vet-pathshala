import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  double _volume = 0.8;
  double _pitch = 1.0;
  double _speechRate = 0.5;
  String? _currentLanguage = 'en-US';
  List<String> _languages = [];
  List<String> _voices = [];

  // Getters
  TtsState get ttsState => _ttsState;
  bool get isPlaying => _ttsState == TtsState.playing;
  bool get isStopped => _ttsState == TtsState.stopped;
  bool get isPaused => _ttsState == TtsState.paused;
  double get volume => _volume;
  double get pitch => _pitch;
  double get speechRate => _speechRate;
  String? get currentLanguage => _currentLanguage;
  List<String> get languages => _languages;
  List<String> get voices => _voices;

  Future<void> initTts() async {
    try {
      _flutterTts = FlutterTts();

      // Set up TTS handlers
      await _setTtsHandlers();

      // Get available languages and voices
      await _getLanguages();
      await _getVoices();

      // Set initial configuration
      await _setTtsConfiguration();

      debugPrint('✅ TTS Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing TTS: $e');
    }
  }

  Future<void> _setTtsHandlers() async {
    if (_flutterTts == null) return;

    _flutterTts!.setStartHandler(() {
      debugPrint('🔊 TTS Started');
      _ttsState = TtsState.playing;
      notifyListeners();
    });

    _flutterTts!.setCompletionHandler(() {
      debugPrint('🔇 TTS Completed');
      _ttsState = TtsState.stopped;
      notifyListeners();
    });

    _flutterTts!.setCancelHandler(() {
      debugPrint('🛑 TTS Cancelled');
      _ttsState = TtsState.stopped;
      notifyListeners();
    });

    _flutterTts!.setPauseHandler(() {
      debugPrint('⏸️ TTS Paused');
      _ttsState = TtsState.paused;
      notifyListeners();
    });

    _flutterTts!.setContinueHandler(() {
      debugPrint('▶️ TTS Continued');
      _ttsState = TtsState.continued;
      notifyListeners();
    });

    _flutterTts!.setErrorHandler((msg) {
      debugPrint('❌ TTS Error: $msg');
      _ttsState = TtsState.stopped;
      notifyListeners();
    });
  }

  Future<void> _setTtsConfiguration() async {
    if (_flutterTts == null) return;

    await _flutterTts!.setVolume(_volume);
    await _flutterTts!.setSpeechRate(_speechRate);
    await _flutterTts!.setPitch(_pitch);
    
    if (_currentLanguage != null) {
      await _flutterTts!.setLanguage(_currentLanguage!);
    }

    // Platform specific configurations
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _flutterTts!.setQueueMode(1); // QUEUE_FLUSH
      } catch (e) {
        debugPrint('Android-specific TTS configuration failed: $e');
      }
    }
  }

  Future<void> _getLanguages() async {
    if (_flutterTts == null) return;

    try {
      final languages = await _flutterTts!.getLanguages;
      if (languages != null) {
        _languages = List<String>.from(languages);
        
        // Set default language if available
        if (_languages.contains('en-US')) {
          _currentLanguage = 'en-US';
        } else if (_languages.contains('en-GB')) {
          _currentLanguage = 'en-GB';
        } else if (_languages.isNotEmpty) {
          _currentLanguage = _languages.first;
        }
      }
    } catch (e) {
      debugPrint('Error getting languages: $e');
    }
  }

  Future<void> _getVoices() async {
    if (_flutterTts == null) return;

    try {
      // Skip voices for web platform as it's not fully supported
      if (kIsWeb) {
        debugPrint('Voices not supported on web platform');
        return;
      }
      
      final voices = await _flutterTts!.getVoices;
      if (voices != null) {
        _voices = List<String>.from(voices);
      }
    } catch (e) {
      debugPrint('Error getting voices: $e');
    }
  }

  Future<void> speak(String text) async {
    if (_flutterTts == null) {
      await initTts();
    }

    if (text.isEmpty) return;

    try {
      // Stop current speech if playing
      if (_ttsState == TtsState.playing) {
        await stop();
      }

      final result = await _flutterTts!.speak(text);
      if (result == 1) {
        debugPrint('🎤 Speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      }
    } catch (e) {
      debugPrint('❌ Error speaking text: $e');
    }
  }

  Future<void> pause() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.pause();
    } catch (e) {
      debugPrint('Error pausing TTS: $e');
    }
  }

  Future<void> stop() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    if (_flutterTts == null) return;

    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts!.setVolume(_volume);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    if (_flutterTts == null) return;

    _speechRate = rate.clamp(0.1, 1.0);
    await _flutterTts!.setSpeechRate(_speechRate);
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    if (_flutterTts == null) return;

    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts!.setPitch(_pitch);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    if (_flutterTts == null) return;

    _currentLanguage = language;
    await _flutterTts!.setLanguage(language);
    notifyListeners();
  }

  // Utility methods for note reading
  Future<void> speakNote(String noteContent) async {
    // Clean the text for better TTS experience
    String cleanText = _cleanTextForSpeech(noteContent);
    await speak(cleanText);
  }

  String _cleanTextForSpeech(String text) {
    // Remove markdown syntax and clean up text
    String cleanText = text
        .replaceAll(RegExp(r'[#*_`]'), '') // Remove markdown symbols
        .replaceAll(RegExp(r'\n+'), '. ') // Replace line breaks with pauses
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();

    return cleanText;
  }

  // Extract and speak selected text
  Future<void> speakSelection(String selectedText) async {
    if (selectedText.trim().isEmpty) return;
    
    String cleanText = _cleanTextForSpeech(selectedText);
    await speak(cleanText);
  }

  void dispose() {
    _flutterTts?.stop();
  }
}