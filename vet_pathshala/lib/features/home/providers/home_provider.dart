import 'package:flutter/foundation.dart';
import '../../../shared/models/user_model.dart';
import '../services/user_stats_service.dart';

class HomeProvider extends ChangeNotifier {
  final UserStatsService _userStatsService = UserStatsService();

  UserStats? _userStats;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoadingStats = false;
  bool _isLoadingActivities = false;
  String? _errorMessage;

  // Getters
  UserStats? get userStats => _userStats;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  bool get isLoadingStats => _isLoadingStats;
  bool get isLoadingActivities => _isLoadingActivities;
  String? get errorMessage => _errorMessage;

  /// Load user statistics from Firebase
  Future<void> loadUserStatistics(String userId) async {
    _isLoadingStats = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userStats = await _userStatsService.getUserStatistics(userId);
    } catch (e) {
      _errorMessage = 'Failed to load statistics: $e';
      print('Error loading user stats: $e');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  /// Load recent activities from Firebase
  Future<void> loadRecentActivities(String userId) async {
    _isLoadingActivities = true;
    notifyListeners();

    try {
      _recentActivities = await _userStatsService.getRecentActivities(userId, limit: 5);
    } catch (e) {
      _errorMessage = 'Failed to load activities: $e';
      print('Error loading recent activities: $e');
    } finally {
      _isLoadingActivities = false;
      notifyListeners();
    }
  }

  /// Record a new activity (called when user completes actions)
  Future<void> recordActivity({
    required String userId,
    required String activityType,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      await _userStatsService.recordActivity(
        userId: userId,
        activityType: activityType,
        metadata: metadata,
      );

      // Refresh stats and activities after recording
      loadUserStatistics(userId);
      loadRecentActivities(userId);
    } catch (e) {
      print('Error recording activity: $e');
    }
  }

  /// Refresh all data
  Future<void> refresh(String userId) async {
    await Future.wait([
      loadUserStatistics(userId),
      loadRecentActivities(userId),
    ]);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _userStats = null;
    _recentActivities = [];
    _isLoadingStats = false;
    _isLoadingActivities = false;
    _errorMessage = null;
    notifyListeners();
  }
}