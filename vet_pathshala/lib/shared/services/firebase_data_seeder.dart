import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseDataSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedAllData() async {
    debugPrint('🌱 Starting Firebase data seeding...');
    
    try {
      await Future.wait([
        seedUsers(),
        seedVideos(),
        seedQuestions(), 
        seedEbooks(),
        seedUserProgress(),
      ]);
      
      debugPrint('✅ Firebase data seeding completed successfully!');
    } catch (e) {
      debugPrint('❌ Error seeding data: $e');
      rethrow;
    }
  }

  Future<void> seedUsers() async {
    debugPrint('👥 Seeding users...');
    
    final users = [
      {
        'email': 'admin@vetpathshala.com',
        'displayName': 'Admin User',
        'role': 'admin',
        'plan': 'premium',
        'coins': 1000,
        'profileImage': null,
        'bio': 'Platform Administrator',
        'specialization': 'System Administration',
        'location': 'Mumbai, India',
        'farmSize': null,
        'animalTypes': [],
        'preferences': {
          'language': 'en',
          'notifications': true,
          'theme': 'light',
        },
        'subscription': {
          'type': 'yearly',
          'startDate': Timestamp.now(),
          'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 365))),
          'isActive': true,
        },
        'stats': {
          'totalWatchTime': 0,
          'coursesCompleted': 0,
          'quizzesAttempted': 0,
          'currentStreak': 0,
          'maxStreak': 0,
        },
        'isActive': true,
        'lastLoginAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'email': 'doctor.smith@example.com',
        'displayName': 'Dr. Sarah Smith',
        'role': 'doctor',
        'plan': 'premium',
        'coins': 250,
        'profileImage': null,
        'bio': 'Small Animal Veterinarian with 10+ years experience',
        'specialization': 'Small Animal Medicine',
        'location': 'Delhi, India',
        'farmSize': null,
        'animalTypes': [],
        'preferences': {
          'language': 'en',
          'notifications': true,
          'theme': 'light',
        },
        'subscription': {
          'type': 'monthly',
          'startDate': Timestamp.now(),
          'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
          'isActive': true,
        },
        'stats': {
          'totalWatchTime': 1250,
          'coursesCompleted': 8,
          'quizzesAttempted': 45,
          'currentStreak': 5,
          'maxStreak': 12,
        },
        'isActive': true,
        'lastLoginAt': Timestamp.now(),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 45))),
        'updatedAt': Timestamp.now(),
      },
      {
        'email': 'pharmacist.raj@example.com',
        'displayName': 'Raj Patel',
        'role': 'pharmacist',
        'plan': 'free',
        'coins': 100,
        'profileImage': null,
        'bio': 'Veterinary Pharmacist specializing in livestock medications',
        'specialization': 'Veterinary Pharmacy',
        'location': 'Gujarat, India',
        'farmSize': null,
        'animalTypes': [],
        'preferences': {
          'language': 'hi',
          'notifications': true,
          'theme': 'light',
        },
        'subscription': null,
        'stats': {
          'totalWatchTime': 320,
          'coursesCompleted': 2,
          'quizzesAttempted': 15,
          'currentStreak': 2,
          'maxStreak': 7,
        },
        'isActive': true,
        'lastLoginAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30))),
        'updatedAt': Timestamp.now(),
      },
      {
        'email': 'farmer.krishna@example.com',
        'displayName': 'Krishna Kumar',
        'role': 'farmer',
        'plan': 'free',
        'coins': 150,
        'profileImage': null,
        'bio': 'Dairy farmer with 50+ cattle',
        'specialization': 'Dairy Farming',
        'location': 'Punjab, India',
        'farmSize': '25 acres',
        'animalTypes': ['cattle', 'buffalo', 'goat'],
        'preferences': {
          'language': 'hi',
          'notifications': true,
          'theme': 'light',
        },
        'subscription': null,
        'stats': {
          'totalWatchTime': 180,
          'coursesCompleted': 1,
          'quizzesAttempted': 8,
          'currentStreak': 1,
          'maxStreak': 4,
        },
        'isActive': true,
        'lastLoginAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
        'updatedAt': Timestamp.now(),
      },
    ];

    for (int i = 0; i < users.length; i++) {
      final userId = 'user_${i + 1}';
      await _firestore.collection('users').doc(userId).set(users[i]);
    }
    
    debugPrint('✅ Seeded ${users.length} users');
  }

  Future<void> seedVideos() async {
    debugPrint('🎥 Seeding videos...');
    
    final videos = [
      {
        'title': 'Introduction to Small Animal Anatomy',
        'description': 'Comprehensive overview of canine and feline anatomy covering skeletal, muscular, and organ systems. Perfect for veterinary students and practitioners.',
        'instructor': 'Dr. Sarah Mitchell',
        'instructorBio': 'DVM, PhD in Veterinary Anatomy, 15+ years teaching experience',
        'thumbnailUrl': null,
        'videoUrl': 'https://example.com/videos/anatomy-intro.mp4',
        'qualityUrls': {
          '360p': 'https://example.com/videos/anatomy-intro-360p.mp4',
          '720p': 'https://example.com/videos/anatomy-intro-720p.mp4',
          '1080p': 'https://example.com/videos/anatomy-intro-1080p.mp4',
        },
        'duration': 2450, // 40 minutes 50 seconds
        'category': 'Animal Anatomy',
        'subcategory': 'Small Animal',
        'targetRoles': ['doctor', 'pharmacist'],
        'accessLevel': 'free',
        'coinCost': 0,
        'difficulty': 'beginner',
        'tags': ['anatomy', 'small animal', 'basics', 'education'],
        'chapters': [
          {'title': 'Introduction', 'timestamp': 0, 'description': 'Course overview'},
          {'title': 'Skeletal System', 'timestamp': 300, 'description': 'Bones and joints'},
          {'title': 'Muscular System', 'timestamp': 900, 'description': 'Muscle groups'},
          {'title': 'Internal Organs', 'timestamp': 1500, 'description': 'Organ systems'},
        ],
        'subtitles': [
          {'language': 'en', 'vttUrl': 'https://example.com/subtitles/anatomy-intro-en.vtt'},
          {'language': 'hi', 'vttUrl': 'https://example.com/subtitles/anatomy-intro-hi.vtt'},
        ],
        'isActive': true,
        'featured': true,
        'publishedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'views': 1247,
          'likes': 89,
          'completions': 234,
          'averageRating': 4.6,
        },
      },
      {
        'title': 'Advanced Surgical Techniques in Large Animals',
        'description': 'Master advanced surgical procedures for cattle, horses, and other large animals. Covers pre-operative planning, surgical techniques, and post-operative care.',
        'instructor': 'Dr. Michael Johnson',
        'instructorBio': 'Large Animal Surgery Specialist, 20+ years field experience',
        'thumbnailUrl': null,
        'videoUrl': 'https://example.com/videos/large-animal-surgery.mp4',
        'qualityUrls': {
          '720p': 'https://example.com/videos/large-animal-surgery-720p.mp4',
          '1080p': 'https://example.com/videos/large-animal-surgery-1080p.mp4',
        },
        'duration': 3600, // 1 hour
        'category': 'Surgery',
        'subcategory': 'Large Animal',
        'targetRoles': ['doctor'],
        'accessLevel': 'premium',
        'coinCost': 50,
        'difficulty': 'advanced',
        'tags': ['surgery', 'large animal', 'cattle', 'advanced'],
        'chapters': [
          {'title': 'Pre-operative Assessment', 'timestamp': 0, 'description': 'Patient evaluation'},
          {'title': 'Anesthesia Protocols', 'timestamp': 600, 'description': 'Safe anesthesia'},
          {'title': 'Surgical Procedures', 'timestamp': 1200, 'description': 'Step-by-step techniques'},
          {'title': 'Post-operative Care', 'timestamp': 2800, 'description': 'Recovery management'},
        ],
        'subtitles': [
          {'language': 'en', 'vttUrl': 'https://example.com/subtitles/surgery-en.vtt'},
        ],
        'isActive': true,
        'featured': true,
        'publishedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'views': 623,
          'likes': 45,
          'completions': 89,
          'averageRating': 4.8,
        },
      },
      {
        'title': 'Pharmacology Basics for Veterinarians',
        'description': 'Essential pharmacology concepts for veterinary practice. Covers drug classifications, dosing, interactions, and safety protocols.',
        'instructor': 'Dr. Priya Sharma',
        'instructorBio': 'Clinical Pharmacologist, PhD, Published researcher',
        'thumbnailUrl': null,
        'videoUrl': 'https://example.com/videos/pharmacology-basics.mp4',
        'qualityUrls': {
          '720p': 'https://example.com/videos/pharmacology-basics-720p.mp4',
        },
        'duration': 2100, // 35 minutes
        'category': 'Pharmacology',
        'subcategory': 'Clinical Pharmacology',
        'targetRoles': ['doctor', 'pharmacist'],
        'accessLevel': 'premium',
        'coinCost': 30,
        'difficulty': 'intermediate',
        'tags': ['pharmacology', 'drugs', 'dosing', 'safety'],
        'chapters': [
          {'title': 'Drug Classifications', 'timestamp': 0, 'description': 'Types of medications'},
          {'title': 'Dosing Principles', 'timestamp': 500, 'description': 'Proper dosing'},
          {'title': 'Drug Interactions', 'timestamp': 1200, 'description': 'Safety considerations'},
        ],
        'subtitles': [
          {'language': 'en', 'vttUrl': 'https://example.com/subtitles/pharmacology-en.vtt'},
          {'language': 'hi', 'vttUrl': 'https://example.com/subtitles/pharmacology-hi.vtt'},
        ],
        'isActive': true,
        'featured': false,
        'publishedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'views': 334,
          'likes': 28,
          'completions': 67,
          'averageRating': 4.4,
        },
      },
      {
        'title': 'Cattle Health Management for Farmers',
        'description': 'Practical guide for dairy and beef cattle health management. Learn to identify common diseases, prevention strategies, and when to call a veterinarian.',
        'instructor': 'Dr. Ravi Krishnan',
        'instructorBio': 'Large Animal Practitioner, Rural veterinary expert',
        'thumbnailUrl': null,
        'videoUrl': 'https://example.com/videos/cattle-health.mp4',
        'qualityUrls': {
          '720p': 'https://example.com/videos/cattle-health-720p.mp4',
        },
        'duration': 1800, // 30 minutes
        'category': 'Animal Husbandry',
        'subcategory': 'Cattle Management',
        'targetRoles': ['farmer', 'doctor'],
        'accessLevel': 'free',
        'coinCost': 0,
        'difficulty': 'beginner',
        'tags': ['cattle', 'health', 'farming', 'prevention'],
        'chapters': [
          {'title': 'Common Cattle Diseases', 'timestamp': 0, 'description': 'Disease identification'},
          {'title': 'Prevention Strategies', 'timestamp': 600, 'description': 'Preventive measures'},
          {'title': 'When to Call the Vet', 'timestamp': 1200, 'description': 'Emergency signs'},
        ],
        'subtitles': [
          {'language': 'en', 'vttUrl': 'https://example.com/subtitles/cattle-health-en.vtt'},
          {'language': 'hi', 'vttUrl': 'https://example.com/subtitles/cattle-health-hi.vtt'},
        ],
        'isActive': true,
        'featured': false,
        'publishedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'views': 789,
          'likes': 56,
          'completions': 145,
          'averageRating': 4.3,
        },
      },
    ];

    for (final video in videos) {
      await _firestore.collection('video_lectures').add(video);
    }
    
    debugPrint('✅ Seeded ${videos.length} videos');
  }

  Future<void> seedQuestions() async {
    debugPrint('❓ Seeding questions...');
    
    final questions = [
      {
        'question': 'Which bone forms the main structure of the canine skull?',
        'questionType': 'mcq',
        'options': ['Frontal bone', 'Occipital bone', 'Temporal bone', 'Parietal bone'],
        'correctAnswer': 'Occipital bone',
        'explanation': 'The occipital bone forms the back and base of the skull, providing the main structural support and housing the foramen magnum.',
        'category': 'Animal Anatomy',
        'subcategory': 'Skeletal System',
        'subject': 'Anatomy',
        'topic': 'Skull Structure',
        'difficulty': 'easy',
        'targetRoles': ['doctor', 'pharmacist'],
        'tags': ['anatomy', 'skull', 'bones', 'canine'],
        'imageUrl': null,
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'attempts': 156,
          'correctAttempts': 123,
          'avgTime': 12.5,
        },
      },
      {
        'question': 'What is the recommended dosage of amoxicillin for a 25kg dog?',
        'questionType': 'mcq',
        'options': ['5-10 mg/kg twice daily', '10-20 mg/kg twice daily', '20-25 mg/kg twice daily', '25-30 mg/kg twice daily'],
        'correctAnswer': '10-20 mg/kg twice daily',
        'explanation': 'The standard dosage of amoxicillin for dogs is 10-20 mg/kg administered twice daily for most infections.',
        'category': 'Pharmacology',
        'subcategory': 'Antibiotics',
        'subject': 'Clinical Pharmacology',
        'topic': 'Antibiotic Dosing',
        'difficulty': 'medium',
        'targetRoles': ['doctor', 'pharmacist'],
        'tags': ['pharmacology', 'antibiotics', 'dosing', 'dogs'],
        'imageUrl': null,
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 4))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'attempts': 89,
          'correctAttempts': 67,
          'avgTime': 18.3,
        },
      },
      {
        'question': 'Mastitis in dairy cows is primarily caused by bacterial infection.',
        'questionType': 'true_false',
        'options': ['True', 'False'],
        'correctAnswer': 'True',
        'explanation': 'Mastitis in dairy cows is indeed primarily caused by bacterial infections, with Staphylococcus aureus and Escherichia coli being common pathogens.',
        'category': 'Clinical Medicine',
        'subcategory': 'Bovine Medicine',
        'subject': 'Large Animal Medicine',
        'topic': 'Mastitis',
        'difficulty': 'easy',
        'targetRoles': ['doctor', 'farmer'],
        'tags': ['mastitis', 'cattle', 'infection', 'dairy'],
        'imageUrl': null,
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'attempts': 203,
          'correctAttempts': 187,
          'avgTime': 8.7,
        },
      },
      {
        'question': 'The normal body temperature range for cattle is _____ to _____ degrees Celsius.',
        'questionType': 'fill_blank',
        'options': [],
        'correctAnswer': '38.5 to 39.5',
        'explanation': 'The normal body temperature for cattle ranges from 38.5°C to 39.5°C (101.3°F to 103.1°F). Temperatures outside this range may indicate illness.',
        'category': 'Clinical Medicine',
        'subcategory': 'Physical Examination',
        'subject': 'Large Animal Medicine',
        'topic': 'Vital Signs',
        'difficulty': 'medium',
        'targetRoles': ['doctor', 'farmer'],
        'tags': ['cattle', 'temperature', 'normal values', 'examination'],
        'imageUrl': null,
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'attempts': 78,
          'correctAttempts': 52,
          'avgTime': 22.1,
        },
      },
      {
        'question': 'Which surgical technique is most appropriate for treating bloat in cattle?',
        'questionType': 'mcq',
        'options': ['Rumenotomy', 'Trocarization', 'Cesarian section', 'Laparoscopy'],
        'correctAnswer': 'Trocarization',
        'explanation': 'Trocarization is the emergency procedure of choice for treating acute bloat in cattle, providing immediate relief by releasing trapped gas.',
        'category': 'Surgery',
        'subcategory': 'Emergency Surgery',
        'subject': 'Large Animal Surgery',
        'topic': 'Bloat Treatment',
        'difficulty': 'hard',
        'targetRoles': ['doctor'],
        'tags': ['surgery', 'bloat', 'cattle', 'emergency'],
        'imageUrl': null,
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'attempts': 45,
          'correctAttempts': 28,
          'avgTime': 25.8,
        },
      },
      {
        'question': 'What is the gestation period for dairy cows?',
        'questionType': 'mcq',
        'options': ['9 months', '10 months', '11 months', '12 months'],
        'correctAnswer': '9 months',
        'explanation': 'The gestation period for dairy cows is approximately 9 months (280-285 days), similar to humans.',
        'category': 'Animal Husbandry',
        'subcategory': 'Reproduction',
        'subject': 'Theriogenology',
        'topic': 'Bovine Reproduction',
        'difficulty': 'easy',
        'targetRoles': ['doctor', 'farmer'],
        'tags': ['reproduction', 'gestation', 'cattle', 'breeding'],
        'imageUrl': null,
        'isActive': true,
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'attempts': 124,
          'correctAttempts': 98,
          'avgTime': 10.2,
        },
      },
    ];

    for (final question in questions) {
      await _firestore.collection('questions').add(question);
    }
    
    debugPrint('✅ Seeded ${questions.length} questions');
  }

  Future<void> seedEbooks() async {
    debugPrint('📚 Seeding ebooks...');
    
    final ebooks = [
      {
        'title': 'Veterinary Anatomy and Physiology Handbook',
        'author': 'Dr. Jennifer Williams, Dr. Mark Thompson',
        'description': 'Comprehensive guide to animal anatomy and physiology covering all major species. Includes detailed illustrations, case studies, and practical applications for veterinary practice.',
        'coverImageUrl': null,
        'pdfUrl': 'https://example.com/ebooks/anatomy-physiology-handbook.pdf',
        'category': 'Animal Anatomy',
        'subcategory': 'Reference Materials',
        'targetRoles': ['doctor', 'pharmacist'],
        'accessLevel': 'premium',
        'coinCost': 100,
        'pages': 456,
        'language': 'en',
        'tags': ['anatomy', 'physiology', 'reference', 'comprehensive'],
        'chapters': [
          {'title': 'Introduction to Anatomy', 'pageStart': 1, 'pageEnd': 25},
          {'title': 'Skeletal System', 'pageStart': 26, 'pageEnd': 85},
          {'title': 'Muscular System', 'pageStart': 86, 'pageEnd': 145},
          {'title': 'Cardiovascular System', 'pageStart': 146, 'pageEnd': 210},
          {'title': 'Respiratory System', 'pageStart': 211, 'pageEnd': 265},
          {'title': 'Digestive System', 'pageStart': 266, 'pageEnd': 350},
          {'title': 'Urogenital System', 'pageStart': 351, 'pageEnd': 420},
          {'title': 'Nervous System', 'pageStart': 421, 'pageEnd': 456},
        ],
        'isActive': true,
        'featured': true,
        'publishedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 14))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 20))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'downloads': 89,
          'readers': 156,
          'averageProgress': 65.3,
        },
      },
      {
        'title': 'Clinical Pharmacology for Veterinarians',
        'author': 'Dr. Robert Chen, Dr. Sarah Patel',
        'description': 'Essential guide to veterinary pharmacology including drug classifications, mechanisms of action, dosing protocols, and adverse reactions. Updated with latest research and regulations.',
        'coverImageUrl': null,
        'pdfUrl': 'https://example.com/ebooks/clinical-pharmacology.pdf',
        'category': 'Pharmacology',
        'subcategory': 'Clinical Practice',
        'targetRoles': ['doctor', 'pharmacist'],
        'accessLevel': 'premium',
        'coinCost': 80,
        'pages': 324,
        'language': 'en',
        'tags': ['pharmacology', 'clinical', 'drugs', 'dosing'],
        'chapters': [
          {'title': 'Pharmacological Principles', 'pageStart': 1, 'pageEnd': 45},
          {'title': 'Antimicrobials', 'pageStart': 46, 'pageEnd': 120},
          {'title': 'Analgesics and Anesthetics', 'pageStart': 121, 'pageEnd': 180},
          {'title': 'Cardiovascular Drugs', 'pageStart': 181, 'pageEnd': 230},
          {'title': 'Endocrine Medications', 'pageStart': 231, 'pageEnd': 280},
          {'title': 'Drug Interactions', 'pageStart': 281, 'pageEnd': 324},
        ],
        'isActive': true,
        'featured': true,
        'publishedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'downloads': 67,
          'readers': 123,
          'averageProgress': 72.1,
        },
      },
      {
        'title': 'Practical Guide to Cattle Diseases',
        'author': 'Dr. Krishna Mohan',
        'description': 'Practical handbook for identifying, preventing, and treating common cattle diseases. Written specifically for farmers and field veterinarians with emphasis on cost-effective solutions.',
        'coverImageUrl': null,
        'pdfUrl': 'https://example.com/ebooks/cattle-diseases-guide.pdf',
        'category': 'Clinical Medicine',
        'subcategory': 'Bovine Medicine',
        'targetRoles': ['doctor', 'farmer'],
        'accessLevel': 'free',
        'coinCost': 0,
        'pages': 198,
        'language': 'en',
        'tags': ['cattle', 'diseases', 'practical', 'farming'],
        'chapters': [
          {'title': 'Introduction to Cattle Health', 'pageStart': 1, 'pageEnd': 20},
          {'title': 'Infectious Diseases', 'pageStart': 21, 'pageEnd': 85},
          {'title': 'Metabolic Disorders', 'pageStart': 86, 'pageEnd': 130},
          {'title': 'Reproductive Issues', 'pageStart': 131, 'pageEnd': 165},
          {'title': 'Prevention Programs', 'pageStart': 166, 'pageEnd': 198},
        ],
        'isActive': true,
        'featured': false,
        'publishedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 8))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'downloads': 234,
          'readers': 345,
          'averageProgress': 58.7,
        },
      },
      {
        'title': 'Small Animal Surgery Atlas',
        'author': 'Dr. Michelle Rodriguez, Dr. James Liu',
        'description': 'Comprehensive surgical atlas with step-by-step procedures for common small animal surgeries. Features high-quality images, surgical tips, and complication management.',
        'coverImageUrl': null,
        'pdfUrl': 'https://example.com/ebooks/surgery-atlas.pdf',
        'category': 'Surgery',
        'subcategory': 'Small Animal',
        'targetRoles': ['doctor'],
        'accessLevel': 'premium',
        'coinCost': 120,
        'pages': 512,
        'language': 'en',
        'tags': ['surgery', 'atlas', 'small animal', 'procedures'],
        'chapters': [
          {'title': 'Surgical Fundamentals', 'pageStart': 1, 'pageEnd': 50},
          {'title': 'Soft Tissue Surgery', 'pageStart': 51, 'pageEnd': 200},
          {'title': 'Orthopedic Surgery', 'pageStart': 201, 'pageEnd': 350},
          {'title': 'Emergency Procedures', 'pageStart': 351, 'pageEnd': 450},
          {'title': 'Post-operative Care', 'pageStart': 451, 'pageEnd': 512},
        ],
        'isActive': true,
        'featured': true,
        'publishedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
        'updatedAt': Timestamp.now(),
        'createdBy': 'admin',
        'stats': {
          'downloads': 45,
          'readers': 78,
          'averageProgress': 43.2,
        },
      },
    ];

    for (final ebook in ebooks) {
      await _firestore.collection('ebooks').add(ebook);
    }
    
    debugPrint('✅ Seeded ${ebooks.length} ebooks');
  }

  Future<void> seedUserProgress() async {
    debugPrint('📈 Seeding user progress...');
    
    final progressEntries = [
      {
        'userId': 'user_2',
        'contentId': 'video_1',
        'contentType': 'video',
        'progress': 100,
        'timeSpent': 2450,
        'completed': true,
        'completedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
        'bookmarks': [
          {
            'timestamp': 300,
            'note': 'Important skeletal system overview',
            'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
          },
          {
            'timestamp': 1500,
            'note': 'Organ system details',
            'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
          },
        ],
        'notes': [],
        'lastAccessedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      },
      {
        'userId': 'user_2',
        'contentId': 'ebook_1',
        'contentType': 'ebook',
        'progress': 75,
        'timeSpent': 3600,
        'completed': false,
        'completedAt': null,
        'bookmarks': [
          {
            'timestamp': 120,
            'note': 'Chapter 3 - Muscular system',
            'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
          },
        ],
        'notes': [
          {
            'content': 'Remember to review cardiovascular system diagrams',
            'timestamp': 180,
            'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
          },
        ],
        'lastAccessedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
      },
      {
        'userId': 'user_4',
        'contentId': 'video_4',
        'contentType': 'video',
        'progress': 60,
        'timeSpent': 1080,
        'completed': false,
        'completedAt': null,
        'bookmarks': [
          {
            'timestamp': 600,
            'note': 'Prevention strategies for my farm',
            'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
          },
        ],
        'notes': [],
        'lastAccessedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 8))),
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 24))),
      },
    ];

    for (int i = 0; i < progressEntries.length; i++) {
      final progressId = 'progress_${i + 1}';
      await _firestore.collection('userProgress').doc(progressId).set(progressEntries[i]);
    }
    
    debugPrint('✅ Seeded ${progressEntries.length} progress entries');
  }

  Future<void> clearAllData() async {
    debugPrint('🗑️ Clearing all Firebase data...');
    
    try {
      final collections = ['users', 'videos', 'questions', 'ebooks', 'userProgress'];
      
      for (final collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
        debugPrint('✅ Cleared $collection collection');
      }
      
      debugPrint('✅ All Firebase data cleared successfully!');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      rethrow;
    }
  }
}