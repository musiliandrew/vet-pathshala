import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/test_series_model.dart';

class TestSeriesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all test series
  Future<List<TestSeries>> getTestSeries() async {
    try {
      // Return sample data for now - can be replaced with Firestore data
      return _getSampleTestSeries();
    } catch (e) {
      throw Exception('Failed to load test series: $e');
    }
  }

  // Get test series by category
  Future<List<TestSeries>> getTestSeriesByCategory(String category) async {
    try {
      final allSeries = await getTestSeries();
      return allSeries.where((series) => series.category == category).toList();
    } catch (e) {
      throw Exception('Failed to load test series by category: $e');
    }
  }

  // Get test questions
  Future<List<TestQuestion>> getTestQuestions(String testSeriesId) async {
    try {
      // Return sample questions for now
      return _getSampleQuestions(testSeriesId);
    } catch (e) {
      throw Exception('Failed to load test questions: $e');
    }
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

  // Sample data - replace with actual Firestore queries
  List<TestSeries> _getSampleTestSeries() {
    return [
      // Mock Tests
      TestSeries(
        id: 'test_001',
        title: 'Veterinary Anatomy Mock Test - 1',
        description: 'Comprehensive mock test covering all aspects of veterinary anatomy including musculoskeletal, cardiovascular, and nervous systems.',
        subject: 'Veterinary Anatomy',
        topics: ['Musculoskeletal System', 'Cardiovascular System', 'Nervous System'],
        difficulty: 'medium',
        category: 'mock',
        totalQuestions: 50,
        duration: 90,
        maxMarks: 100,
        isPremium: true,
        coinCost: 8,
        createdDate: DateTime(2024, 1, 15),
        attempts: 1247,
        averageScore: 72.5,
        tags: ['anatomy', 'mock-test', 'comprehensive'],
        thumbnailUrl: 'https://example.com/thumbs/anatomy_mock.jpg',
      ),
      TestSeries(
        id: 'test_002',
        title: 'Animal Physiology Practice Series',
        description: 'Practice test series for animal physiology covering respiratory, digestive, and endocrine systems.',
        subject: 'Animal Physiology',
        topics: ['Respiratory System', 'Digestive System', 'Endocrine System'],
        difficulty: 'easy',
        category: 'practice',
        totalQuestions: 30,
        duration: 45,
        maxMarks: 60,
        isPremium: false,
        coinCost: 0,
        createdDate: DateTime(2024, 2, 10),
        attempts: 892,
        averageScore: 68.2,
        tags: ['physiology', 'practice', 'systems'],
      ),
      TestSeries(
        id: 'test_003',
        title: 'NEET-VET Competitive Exam Prep',
        description: 'Comprehensive competitive exam preparation covering all veterinary subjects for NEET-VET and similar exams.',
        subject: 'Mixed',
        topics: ['Anatomy', 'Physiology', 'Pathology', 'Medicine', 'Surgery'],
        difficulty: 'hard',
        category: 'competitive',
        totalQuestions: 100,
        duration: 180,
        maxMarks: 200,
        isPremium: true,
        coinCost: 15,
        createdDate: DateTime(2024, 3, 5),
        scheduledDate: DateTime(2024, 12, 15),
        isLive: true,
        attempts: 2156,
        averageScore: 58.7,
        tags: ['neet-vet', 'competitive', 'comprehensive'],
      ),
      TestSeries(
        id: 'test_004',
        title: 'Veterinary Medicine Clinical Cases',
        description: 'Case-based test series focusing on clinical scenarios in veterinary medicine.',
        subject: 'Veterinary Medicine',
        topics: ['Internal Medicine', 'Emergency Medicine', 'Diagnostic Medicine'],
        difficulty: 'hard',
        category: 'practice',
        totalQuestions: 40,
        duration: 75,
        maxMarks: 80,
        isPremium: true,
        coinCost: 10,
        createdDate: DateTime(2024, 1, 25),
        attempts: 645,
        averageScore: 74.3,
        tags: ['medicine', 'clinical-cases', 'diagnostics'],
      ),
      TestSeries(
        id: 'test_005',
        title: 'Veterinary Surgery Quick Test',
        description: 'Quick assessment test for veterinary surgery principles and techniques.',
        subject: 'Veterinary Surgery',
        topics: ['Soft Tissue Surgery', 'Orthopedic Surgery', 'Surgical Principles'],
        difficulty: 'medium',
        category: 'practice',
        totalQuestions: 25,
        duration: 30,
        maxMarks: 50,
        isPremium: false,
        coinCost: 0,
        createdDate: DateTime(2024, 2, 20),
        attempts: 523,
        averageScore: 71.8,
        tags: ['surgery', 'quick-test', 'techniques'],
      ),
      TestSeries(
        id: 'test_006',
        title: 'Veterinary Pathology Comprehensive',
        description: 'In-depth test series covering general and systemic pathology concepts.',
        subject: 'Veterinary Pathology',
        topics: ['General Pathology', 'Systemic Pathology', 'Clinical Pathology'],
        difficulty: 'medium',
        category: 'mock',
        totalQuestions: 60,
        duration: 120,
        maxMarks: 120,
        isPremium: true,
        coinCost: 12,
        createdDate: DateTime(2024, 3, 1),
        attempts: 789,
        averageScore: 66.4,
        tags: ['pathology', 'comprehensive', 'diagnosis'],
      ),
    ];
  }

  List<TestQuestion> _getSampleQuestions(String testSeriesId) {
    // Return sample questions based on test series
    return [
      TestQuestion(
        id: '${testSeriesId}_q1',
        testSeriesId: testSeriesId,
        questionText: 'Which of the following bones forms the main body of the skull in domestic animals?',
        options: ['Frontal bone', 'Parietal bone', 'Occipital bone', 'Temporal bone'],
        correctAnswerIndex: 2,
        explanation: 'The occipital bone forms the caudal part of the skull and contains the foramen magnum.',
        topic: 'Skeletal System',
        difficulty: 'medium',
        marks: 2,
      ),
      TestQuestion(
        id: '${testSeriesId}_q2',
        testSeriesId: testSeriesId,
        questionText: 'The normal heart rate range for adult cattle is:',
        options: ['40-80 bpm', '60-100 bpm', '80-120 bpm', '100-140 bpm'],
        correctAnswerIndex: 0,
        explanation: 'Adult cattle typically have a heart rate of 40-80 beats per minute.',
        topic: 'Cardiovascular System',
        difficulty: 'easy',
        marks: 1,
      ),
      TestQuestion(
        id: '${testSeriesId}_q3',
        testSeriesId: testSeriesId,
        questionText: 'Which vitamin deficiency causes night blindness in animals?',
        options: ['Vitamin A', 'Vitamin B1', 'Vitamin C', 'Vitamin D'],
        correctAnswerIndex: 0,
        explanation: 'Vitamin A deficiency leads to night blindness as it is essential for rhodopsin formation.',
        topic: 'Nutrition',
        difficulty: 'easy',
        marks: 1,
      ),
      // Add more sample questions as needed
    ];
  }
}