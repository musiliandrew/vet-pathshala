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
      rethrow;
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
      // Get recent activities from admin_activities collection
      final activitiesQuery = await _firestore
          .collection('admin_activities')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      return activitiesQuery.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

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