import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pyp_model.dart';

class PYPService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get PYP categories
  Future<List<PYPCategory>> getCategories() async {
    try {
      // Return sample data for now - can be replaced with Firestore data
      return _getSampleCategories();
    } catch (e) {
      throw Exception('Failed to load PYP categories: $e');
    }
  }

  // Get PYP papers
  Future<List<PYPPaper>> getPapers() async {
    try {
      // Return sample data for now - can be replaced with Firestore data
      return _getSamplePapers();
    } catch (e) {
      throw Exception('Failed to load PYP papers: $e');
    }
  }

  // Download paper
  Future<bool> downloadPaper(String paperId) async {
    try {
      // Update download count in Firestore
      await _firestore.collection('pyp_papers').doc(paperId).update({
        'downloads': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error downloading paper: $e');
      return false;
    }
  }

  // Rate paper
  Future<void> ratePaper(String paperId, double rating) async {
    try {
      await _firestore.collection('pyp_papers').doc(paperId).update({
        'ratings': FieldValue.arrayUnion([rating]),
      });
    } catch (e) {
      throw Exception('Failed to rate paper: $e');
    }
  }

  // Sample data - replace with actual Firestore queries
  List<PYPCategory> _getSampleCategories() {
    return [
      PYPCategory(
        id: 'basic_sciences',
        name: 'Basic Sciences',
        icon: '🧬',
        totalPapers: 156,
        subjects: [
          PYPSubject(
            id: 'veterinary_anatomy',
            name: 'Veterinary Anatomy',
            categoryId: 'basic_sciences',
            topics: ['Musculoskeletal System', 'Cardiovascular System', 'Nervous System'],
            yearWisePapers: {2024: 12, 2023: 15, 2022: 18, 2021: 14},
            totalPapers: 59,
          ),
          PYPSubject(
            id: 'animal_physiology',
            name: 'Animal Physiology',
            categoryId: 'basic_sciences',
            topics: ['Respiratory Physiology', 'Endocrine System', 'Digestive System'],
            yearWisePapers: {2024: 8, 2023: 12, 2022: 10, 2021: 16},
            totalPapers: 46,
          ),
        ],
      ),
      PYPCategory(
        id: 'clinical_sciences',
        name: 'Clinical Sciences',
        icon: '🏥',
        totalPapers: 203,
        subjects: [
          PYPSubject(
            id: 'veterinary_medicine',
            name: 'Veterinary Medicine',
            categoryId: 'clinical_sciences',
            topics: ['Internal Medicine', 'Emergency Medicine', 'Preventive Medicine'],
            yearWisePapers: {2024: 20, 2023: 25, 2022: 22, 2021: 18},
            totalPapers: 85,
          ),
          PYPSubject(
            id: 'veterinary_surgery',
            name: 'Veterinary Surgery',
            categoryId: 'clinical_sciences',
            topics: ['Soft Tissue Surgery', 'Orthopedic Surgery', 'Surgical Techniques'],
            yearWisePapers: {2024: 15, 2023: 20, 2022: 18, 2021: 16},
            totalPapers: 69,
          ),
        ],
      ),
      PYPCategory(
        id: 'pathology',
        name: 'Pathology & Diagnostics',
        icon: '🔬',
        totalPapers: 127,
        subjects: [
          PYPSubject(
            id: 'veterinary_pathology',
            name: 'Veterinary Pathology',
            categoryId: 'pathology',
            topics: ['General Pathology', 'Systemic Pathology', 'Clinical Pathology'],
            yearWisePapers: {2024: 10, 2023: 14, 2022: 16, 2021: 12},
            totalPapers: 52,
          ),
        ],
      ),
    ];
  }

  List<PYPPaper> _getSamplePapers() {
    return [
      // 2024 Papers
      PYPPaper(
        id: 'pyp_001',
        title: 'Veterinary Anatomy - Final Exam 2024',
        subject: 'Veterinary Anatomy',
        topic: 'Musculoskeletal System',
        year: 2024,
        examType: 'university',
        difficulty: 'hard',
        tags: ['anatomy', 'bones', 'muscles', 'final-exam'],
        pdfUrl: 'https://example.com/papers/anatomy_2024.pdf',
        thumbnailUrl: 'https://example.com/thumbs/anatomy_2024.jpg',
        questions: 100,
        duration: 180,
        maxMarks: 200,
        isPremium: true,
        coinCost: 10,
        uploadDate: DateTime(2024, 6, 15),
        downloads: 1247,
        rating: 4.7,
      ),
      PYPPaper(
        id: 'pyp_002',
        title: 'Animal Physiology - Mid-term 2024',
        subject: 'Animal Physiology',
        topic: 'Cardiovascular System',
        year: 2024,
        examType: 'university',
        difficulty: 'medium',
        tags: ['physiology', 'cardiovascular', 'mid-term'],
        pdfUrl: 'https://example.com/papers/physiology_2024.pdf',
        thumbnailUrl: 'https://example.com/thumbs/physiology_2024.jpg',
        questions: 75,
        duration: 120,
        maxMarks: 150,
        isPremium: false,
        coinCost: 0,
        uploadDate: DateTime(2024, 3, 20),
        downloads: 892,
        rating: 4.4,
      ),
      PYPPaper(
        id: 'pyp_003',
        title: 'Veterinary Medicine - Comprehensive 2024',
        subject: 'Veterinary Medicine',
        topic: 'Internal Medicine',
        year: 2024,
        examType: 'competitive',
        difficulty: 'hard',
        tags: ['medicine', 'internal-medicine', 'comprehensive'],
        pdfUrl: 'https://example.com/papers/medicine_2024.pdf',
        thumbnailUrl: 'https://example.com/thumbs/medicine_2024.jpg',
        questions: 150,
        duration: 240,
        maxMarks: 300,
        isPremium: true,
        coinCost: 15,
        uploadDate: DateTime(2024, 8, 10),
        downloads: 2156,
        rating: 4.9,
      ),

      // 2023 Papers
      PYPPaper(
        id: 'pyp_004',
        title: 'Veterinary Surgery - Practical Exam 2023',
        subject: 'Veterinary Surgery',
        topic: 'Soft Tissue Surgery',
        year: 2023,
        examType: 'university',
        difficulty: 'medium',
        tags: ['surgery', 'practical', 'soft-tissue'],
        pdfUrl: 'https://example.com/papers/surgery_2023.pdf',
        thumbnailUrl: 'https://example.com/thumbs/surgery_2023.jpg',
        questions: 50,
        duration: 90,
        maxMarks: 100,
        isPremium: false,
        coinCost: 0,
        uploadDate: DateTime(2023, 11, 25),
        downloads: 678,
        rating: 4.2,
      ),
      PYPPaper(
        id: 'pyp_005',
        title: 'Veterinary Pathology - Final Theory 2023',
        subject: 'Veterinary Pathology',
        topic: 'General Pathology',
        year: 2023,
        examType: 'university',
        difficulty: 'hard',
        tags: ['pathology', 'theory', 'final-exam'],
        pdfUrl: 'https://example.com/papers/pathology_2023.pdf',
        thumbnailUrl: 'https://example.com/thumbs/pathology_2023.jpg',
        questions: 80,
        duration: 150,
        maxMarks: 160,
        isPremium: true,
        coinCost: 8,
        uploadDate: DateTime(2023, 5, 18),
        downloads: 1034,
        rating: 4.6,
      ),

      // 2022 Papers
      PYPPaper(
        id: 'pyp_006',
        title: 'Animal Physiology - Annual Exam 2022',
        subject: 'Animal Physiology',
        topic: 'Respiratory Physiology',
        year: 2022,
        examType: 'university',
        difficulty: 'medium',
        tags: ['physiology', 'respiratory', 'annual'],
        pdfUrl: 'https://example.com/papers/physiology_2022.pdf',
        thumbnailUrl: 'https://example.com/thumbs/physiology_2022.jpg',
        questions: 90,
        duration: 180,
        maxMarks: 180,
        isPremium: false,
        coinCost: 0,
        uploadDate: DateTime(2022, 12, 8),
        downloads: 543,
        rating: 4.1,
      ),
      PYPPaper(
        id: 'pyp_007',
        title: 'Veterinary Medicine - Mock Test 2022',
        subject: 'Veterinary Medicine',
        topic: 'Emergency Medicine',
        year: 2022,
        examType: 'mock',
        difficulty: 'easy',
        tags: ['medicine', 'emergency', 'mock-test'],
        pdfUrl: 'https://example.com/papers/medicine_mock_2022.pdf',
        thumbnailUrl: 'https://example.com/thumbs/medicine_mock_2022.jpg',
        questions: 60,
        duration: 90,
        maxMarks: 120,
        isPremium: false,
        coinCost: 0,
        uploadDate: DateTime(2022, 9, 14),
        downloads: 789,
        rating: 3.9,
      ),

      // More sample papers can be added here
    ];
  }
}