import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_series_model.dart';

class TestSeriesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all test series
  Future<List<TestSeries>> getTestSeries() async {
    final query = await _firestore
        .collection('test_series')
        .where('isActive', isEqualTo: true)
        .orderBy('createdDate', descending: true)
        .get();

    return query.docs.map((doc) => TestSeries.fromFirestore(doc)).toList();
  }

  // Get test series by category
  Future<List<TestSeries>> getTestSeriesByCategory(String category) async {
    final query = await _firestore
        .collection('test_series')
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('createdDate', descending: true)
        .get();

    return query.docs.map((doc) => TestSeries.fromFirestore(doc)).toList();
  }

  // Get test questions
  Future<List<TestQuestion>> getTestQuestions(String testSeriesId) async {
    final query = await _firestore
        .collection('test_questions')
        .where('testSeriesId', isEqualTo: testSeriesId)
        .orderBy('order')
        .get();

    return query.docs.map((doc) => TestQuestion.fromFirestore(doc)).toList();
  }

  // Start test attempt
  Future<TestAttempt> startTestAttempt(String testSeriesId, String userId) async {
    try {
      final attemptId = '${testSeriesId}_${userId}_${DateTime.now().millisecondsSinceEpoch}';
      final attempt = TestAttempt(
        id: attemptId,
        testSeriesId: testSeriesId,
        userId: userId,
        startTime: DateTime.now(),
      );
      
      // Save to Firestore
      await _firestore.collection('test_attempts').doc(attemptId).set(attempt.toJson());
      return attempt;
    } catch (e) {
      throw Exception('Failed to start test attempt: $e');
    }
  }

  // Submit test attempt
  Future<void> submitTestAttempt(TestAttempt attempt) async {
    try {
      await _firestore.collection('test_attempts').doc(attempt.id).update(attempt.toJson());
    } catch (e) {
      throw Exception('Failed to submit test attempt: $e');
    }
  }

  // Get user's test attempts
  Future<List<TestAttempt>> getUserTestAttempts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('test_attempts')
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) => TestAttempt.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error getting user test attempts: $e');
      return [];
    }
  }


}