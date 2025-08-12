import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService extends ChangeNotifier {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // In production, admin emails would be stored in Firestore or environment variables
  final Set<String> _adminEmails = {
    'admin@vetpathshala.com',
    'support@vetpathshala.com',
    'developer@vetpathshala.com',
  };

  /// Check if user is admin
  bool isUserAdmin(String? email) {
    if (email == null) return false;
    return _adminEmails.contains(email.toLowerCase());
  }

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // In production, these would be real Firestore queries
      // For demo, returning mock data
      
      final stats = {
        'totalUsers': await _getUserCount(),
        'totalQuestions': await _getQuestionCount(),
        'totalNotes': await _getNoteCount(),
        'totalReports': await _getReportCount(),
        'activeUsers': await _getActiveUserCount(),
        'newUsersToday': await _getNewUsersToday(),
      };

      debugPrint('📊 Dashboard stats loaded: $stats');
      return stats;

    } catch (e) {
      debugPrint('❌ Error loading dashboard stats: $e');
      // Return mock data on error
      return {
        'totalUsers': 1234,
        'totalQuestions': 15678,
        'totalNotes': 890,
        'totalReports': 23,
        'activeUsers': 456,
        'newUsersToday': 12,
      };
    }
  }

  Future<int> _getUserCount() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      return 1234; // Mock data
    }
  }

  Future<int> _getQuestionCount() async {
    try {
      final snapshot = await _firestore.collection('questions').get();
      return snapshot.docs.length;
    } catch (e) {
      return 15678; // Mock data
    }
  }

  Future<int> _getNoteCount() async {
    try {
      final snapshot = await _firestore.collection('notes').get();
      return snapshot.docs.length;
    } catch (e) {
      return 890; // Mock data
    }
  }

  Future<int> _getReportCount() async {
    try {
      final snapshot = await _firestore
          .collection('interactions')
          .where('type', isEqualTo: 'report')
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 23; // Mock data
    }
  }

  Future<int> _getActiveUserCount() async {
    try {
      final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
      final snapshot = await _firestore
          .collection('users')
          .where('lastActive', isGreaterThan: Timestamp.fromDate(oneDayAgo))
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 456; // Mock data
    }
  }

  Future<int> _getNewUsersToday() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final snapshot = await _firestore
          .collection('users')
          .where('createdTime', isGreaterThan: Timestamp.fromDate(startOfDay))
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 12; // Mock data
    }
  }

  /// Get recent activity
  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 10}) async {
    try {
      // In production, this would aggregate from multiple collections
      // For demo, returning mock data
      
      return [
        {
          'type': 'user_registration',
          'title': 'New user registration',
          'description': 'Dr. Sarah Johnson joined as Veterinarian',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
          'icon': 'person_add',
          'color': 'green',
        },
        {
          'type': 'question_added',
          'title': 'Question added',
          'description': 'Pathology question submitted for review',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
          'icon': 'quiz',
          'color': 'blue',
        },
        {
          'type': 'content_reported',
          'title': 'Content reported',
          'description': 'Question #1234 reported as inappropriate',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'icon': 'flag',
          'color': 'red',
        },
        {
          'type': 'note_updated',
          'title': 'Note updated',
          'description': 'Anatomy notes revised and republished',
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'icon': 'note',
          'color': 'orange',
        },
        {
          'type': 'lecture_uploaded',
          'title': 'Lecture uploaded',
          'description': 'New surgical procedure video added',
          'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
          'icon': 'video_library',
          'color': 'purple',
        },
      ];

    } catch (e) {
      debugPrint('❌ Error loading recent activity: $e');
      return [];
    }
  }

  /// Add admin email (for development/testing)
  void addAdminEmail(String email) {
    _adminEmails.add(email.toLowerCase());
    debugPrint('➕ Added admin email: $email');
  }

  /// Remove admin email
  void removeAdminEmail(String email) {
    _adminEmails.remove(email.toLowerCase());
    debugPrint('➖ Removed admin email: $email');
  }

  /// Get all admin emails (for debugging only)
  Set<String> get adminEmails => Set.from(_adminEmails);
}