# Firebase Dynamic Data & Admin Panel Implementation Plan

## Current Firebase Setup Analysis ✅

### **Existing Firebase Integration**
Based on code analysis, the project already has comprehensive Firebase integration:

**✅ Firebase Services Configured:**
- **Firebase Core**: v3.6.0 (Latest)
- **Firebase Auth**: v5.3.1 with Google Sign-In
- **Cloud Firestore**: v5.4.3 for database
- **Firebase Analytics**: v11.3.3 for tracking
- **Firebase Storage**: v12.3.2 for file uploads
- **Firebase Messaging**: v15.1.3 for notifications

**✅ Current Project Configuration:**
- **Project ID**: `vet-pathshala`
- **Auth Domain**: `vet-pathshala.firebaseapp.com`
- **Storage Bucket**: `vet-pathshala.firebasestorage.app`
- **Database**: `vet-pathshala-default-rtdb.asia-southeast1.firebasedatabase.app`
- **Multi-platform**: Web, Android, iOS, macOS, Windows

**✅ Existing Services Implementation:**
- `AuthService` - Complete authentication system
- `AdminService` - Basic admin functionality
- Multiple feature services using Firestore
- File upload capabilities with Firebase Storage

---

## Implementation Plan: Dynamic Data with Admin Panel

### **Phase 1: Firebase Backend Setup (Week 1)**

#### 1.1 Firestore Database Structure Enhancement

```javascript
// Enhanced Firestore Collections
const firestoreCollections = {
  // Content Management
  videos: {
    id: "auto-generated",
    title: "string",
    description: "string", 
    instructor: "string",
    instructorBio: "string",
    thumbnailUrl: "string",
    videoUrl: "string", // Main video URL
    qualityUrls: {
      "360p": "string",
      "720p": "string", 
      "1080p": "string"
    },
    duration: "number", // in seconds
    category: "string", // veterinary_medicine, pharmacology, etc.
    subcategory: "string",
    targetRoles: ["doctor", "pharmacist", "farmer"],
    accessLevel: "free|premium",
    coinCost: "number",
    difficulty: "beginner|intermediate|advanced",
    tags: ["array of strings"],
    chapters: [{
      title: "string",
      timestamp: "number",
      description: "string"
    }],
    subtitles: [{
      language: "en|hi|es",
      vttUrl: "string"
    }],
    isActive: "boolean",
    featured: "boolean",
    publishedAt: "timestamp",
    updatedAt: "timestamp",
    createdBy: "adminUserId",
    stats: {
      views: "number",
      likes: "number", 
      completions: "number",
      averageRating: "number"
    }
  },

  questions: {
    id: "auto-generated",
    question: "string",
    questionType: "mcq|true_false|fill_blank",
    options: ["array of strings"], // for MCQ
    correctAnswer: "string|number",
    explanation: "string",
    category: "string",
    subcategory: "string", 
    subject: "string",
    topic: "string",
    difficulty: "easy|medium|hard",
    targetRoles: ["doctor", "pharmacist", "farmer"],
    tags: ["array of strings"],
    imageUrl: "string", // optional question image
    isActive: "boolean",
    createdBy: "adminUserId",
    createdAt: "timestamp",
    updatedAt: "timestamp",
    stats: {
      attempts: "number",
      correctAttempts: "number",
      avgTime: "number" // average time to answer
    }
  },

  ebooks: {
    id: "auto-generated", 
    title: "string",
    author: "string",
    description: "string",
    coverImageUrl: "string",
    pdfUrl: "string",
    category: "string",
    subcategory: "string",
    targetRoles: ["doctor", "pharmacist", "farmer"],
    accessLevel: "free|premium",
    coinCost: "number", 
    pages: "number",
    language: "en|hi|es",
    tags: ["array of strings"],
    chapters: [{
      title: "string",
      pageStart: "number",
      pageEnd: "number"
    }],
    isActive: "boolean",
    featured: "boolean",
    publishedAt: "timestamp",
    updatedAt: "timestamp",
    createdBy: "adminUserId",
    stats: {
      downloads: "number",
      readers: "number",
      averageProgress: "number"
    }
  },

  notes: {
    id: "auto-generated",
    title: "string", 
    content: "string", // markdown content
    summary: "string", // AI generated summary
    category: "string",
    subcategory: "string",
    subject: "string",
    topic: "string",
    targetRoles: ["doctor", "pharmacist", "farmer"],
    difficulty: "beginner|intermediate|advanced",
    tags: ["array of strings"],
    attachments: [{
      name: "string",
      url: "string",
      type: "image|pdf|doc"
    }],
    isActive: "boolean",
    featured: "boolean",
    createdBy: "adminUserId",
    createdAt: "timestamp", 
    updatedAt: "timestamp",
    stats: {
      views: "number",
      bookmarks: "number"
    }
  },

  drugs: {
    id: "auto-generated",
    name: "string",
    genericName: "string", 
    brandNames: ["array of strings"],
    category: "string", // antibiotic, analgesic, etc.
    description: "string",
    composition: "string",
    dosage: {
      dogs: "string",
      cats: "string", 
      cattle: "string",
      poultry: "string",
      others: "string"
    },
    administration: "oral|injection|topical",
    contraindications: "string",
    sideEffects: "string",
    interactions: ["array of drug names"],
    withdrawalPeriod: "string",
    imageUrl: "string",
    isActive: "boolean",
    createdBy: "adminUserId",
    createdAt: "timestamp",
    updatedAt: "timestamp"
  },

  // User Management
  users: {
    uid: "firebase_user_id",
    email: "string",
    displayName: "string",
    role: "doctor|pharmacist|farmer|admin",
    plan: "free|premium", 
    coins: "number",
    profileImage: "string",
    bio: "string",
    specialization: "string", // for doctors/pharmacists
    location: "string",
    farmSize: "string", // for farmers
    animalTypes: ["array of strings"], // for farmers
    preferences: {
      language: "en|hi|es",
      notifications: "boolean",
      theme: "light|dark"
    },
    subscription: {
      type: "monthly|yearly",
      startDate: "timestamp",
      endDate: "timestamp", 
      isActive: "boolean"
    },
    stats: {
      totalWatchTime: "number",
      coursesCompleted: "number",
      quizzesAttempted: "number",
      currentStreak: "number",
      maxStreak: "number"
    },
    isActive: "boolean",
    lastLoginAt: "timestamp",
    createdAt: "timestamp",
    updatedAt: "timestamp"
  },

  // Learning Progress
  userProgress: {
    id: "userId_contentId",
    userId: "string",
    contentId: "string",
    contentType: "video|quiz|ebook|note",
    progress: "number", // 0-100
    timeSpent: "number", // in seconds
    completed: "boolean",
    completedAt: "timestamp",
    bookmarks: [{
      timestamp: "number",
      note: "string",
      createdAt: "timestamp"
    }],
    notes: [{
      content: "string", 
      timestamp: "number",
      createdAt: "timestamp"
    }],
    lastAccessedAt: "timestamp",
    createdAt: "timestamp"
  },

  // Admin Management
  adminActions: {
    id: "auto-generated",
    adminId: "string",
    action: "create|update|delete|publish|unpublish",
    entityType: "video|question|ebook|note|drug|user",
    entityId: "string", 
    changes: "object", // what was changed
    timestamp: "timestamp",
    ipAddress: "string"
  },

  systemConfig: {
    id: "config",
    version: "string",
    maintenance: {
      enabled: "boolean",
      message: "string",
      startTime: "timestamp",
      endTime: "timestamp"
    },
    features: {
      videoStreaming: "boolean",
      offlineDownloads: "boolean",
      socialFeatures: "boolean"
    },
    coinRates: {
      videoAccess: "number",
      quizAccess: "number", 
      ebookAccess: "number"
    },
    updatedAt: "timestamp"
  }
};
```

#### 1.2 Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Public read access for active content
    match /videos/{videoId} {
      allow read: if isAuthenticated() && resource.data.isActive == true;
      allow write: if isAdmin();
    }
    
    match /questions/{questionId} {
      allow read: if isAuthenticated() && resource.data.isActive == true;
      allow write: if isAdmin();
    }
    
    match /ebooks/{ebookId} {
      allow read: if isAuthenticated() && resource.data.isActive == true;
      allow write: if isAdmin();
    }
    
    match /notes/{noteId} {
      allow read: if isAuthenticated() && resource.data.isActive == true;
      allow write: if isAdmin();
    }
    
    match /drugs/{drugId} {
      allow read: if isAuthenticated() && resource.data.isActive == true;
      allow write: if isAdmin();
    }

    // User data access
    match /users/{userId} {
      allow read, write: if isOwner(userId) || isAdmin();
    }
    
    // User progress - private to user
    match /userProgress/{progressId} {
      allow read, write: if isAuthenticated() && 
                         resource.data.userId == request.auth.uid;
    }
    
    // Admin only collections
    match /adminActions/{actionId} {
      allow read, write: if isAdmin();
    }
    
    match /systemConfig/{configId} {
      allow read: if isAuthenticated();
      allow write: if isAdmin();
    }
  }
}
```

### **Phase 2: Cloud Functions Backend Logic (Week 1-2)**

#### 2.1 Essential Cloud Functions

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Storage } = require('@google-cloud/storage');

admin.initializeApp();
const db = admin.firestore();
const storage = new Storage();

// User Management Functions
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  // Create user profile in Firestore
  await db.collection('users').doc(user.uid).set({
    email: user.email,
    displayName: user.displayName,
    role: null, // Set during onboarding
    plan: 'free',
    coins: 100, // Welcome bonus
    profileImage: user.photoURL,
    isActive: true,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    stats: {
      totalWatchTime: 0,
      coursesCompleted: 0,
      quizzesAttempted: 0,
      currentStreak: 0,
      maxStreak: 0
    }
  });
});

// Content Management Functions
exports.processVideoUpload = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name;
  const bucket = object.bucket;

  // Check if it's a video upload
  if (!filePath.startsWith('uploads/videos/')) return;

  // Generate different quality versions
  const videoId = filePath.split('/')[2].split('.')[0];
  
  // Trigger video processing (would integrate with video processing service)
  await db.collection('videos').doc(videoId).update({
    status: 'processing',
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
  
  // In production, trigger video processing pipeline
  console.log(`Processing video: ${videoId}`);
});

// Analytics Functions
exports.trackUserAction = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { action, contentId, contentType, metadata } = data;
  const userId = context.auth.uid;

  // Track the action
  await db.collection('analytics').add({
    userId,
    action,
    contentId,
    contentType,
    metadata: metadata || {},
    timestamp: admin.firestore.FieldValue.serverTimestamp()
  });

  // Update user stats
  if (action === 'video_complete') {
    await db.collection('users').doc(userId).update({
      'stats.coursesCompleted': admin.firestore.FieldValue.increment(1)
    });
  }

  return { success: true };
});

// Progress Management
exports.updateProgress = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { contentId, contentType, progress, timeSpent } = data;
  const userId = context.auth.uid;
  const progressId = `${userId}_${contentId}`;

  await db.collection('userProgress').doc(progressId).set({
    userId,
    contentId,
    contentType,
    progress,
    timeSpent,
    completed: progress >= 100,
    completedAt: progress >= 100 ? admin.firestore.FieldValue.serverTimestamp() : null,
    lastAccessedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true });

  // Award coins for completion
  if (progress >= 100) {
    const coinReward = contentType === 'video' ? 30 : 10;
    await db.collection('users').doc(userId).update({
      coins: admin.firestore.FieldValue.increment(coinReward)
    });
  }

  return { success: true };
});

// Search Functions
exports.searchContent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  const { query, contentType, category, limit = 20 } = data;
  
  let searchResults = [];

  // Basic text search (in production, use Algolia or Elasticsearch)
  if (contentType === 'videos' || !contentType) {
    const videosQuery = db.collection('videos')
      .where('isActive', '==', true)
      .limit(limit);

    const videos = await videosQuery.get();
    videos.forEach(doc => {
      const data = doc.data();
      if (data.title.toLowerCase().includes(query.toLowerCase()) ||
          data.description.toLowerCase().includes(query.toLowerCase())) {
        searchResults.push({ id: doc.id, type: 'video', ...data });
      }
    });
  }

  return { results: searchResults };
});

// Admin Functions
exports.getAnalytics = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  }

  // Check if user is admin
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  if (!userDoc.exists || userDoc.data().role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied', 'Admin access required');
  }

  const { startDate, endDate, metric } = data;

  // Get analytics data
  const analytics = await db.collection('analytics')
    .where('timestamp', '>=', admin.firestore.Timestamp.fromDate(new Date(startDate)))
    .where('timestamp', '<=', admin.firestore.Timestamp.fromDate(new Date(endDate)))
    .get();

  // Process and return analytics
  const results = {};
  analytics.forEach(doc => {
    const data = doc.data();
    if (!results[data.action]) {
      results[data.action] = 0;
    }
    results[data.action]++;
  });

  return results;
});
```

### **Phase 3: Advanced Admin Panel (Week 2-3)**

#### 3.1 Enhanced Admin Service

```dart
// lib/features/admin/services/enhanced_admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class EnhancedAdminService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Content Management
  Future<String> uploadVideo({
    required String title,
    required String description,
    required String instructor,
    required String category,
    required String subcategory,
    required List<String> targetRoles,
    required String accessLevel,
    required int coinCost,
    required Uint8List videoFile,
    required String fileName,
    Uint8List? thumbnailFile,
    String? thumbnailFileName,
  }) async {
    try {
      // Upload video file
      final videoRef = _storage.ref().child('videos/$fileName');
      final videoUploadTask = await videoRef.putData(
        videoFile,
        SettableMetadata(contentType: 'video/mp4')
      );
      final videoUrl = await videoUploadTask.ref.getDownloadURL();

      // Upload thumbnail if provided
      String? thumbnailUrl;
      if (thumbnailFile != null && thumbnailFileName != null) {
        final thumbnailRef = _storage.ref().child('thumbnails/$thumbnailFileName');
        final thumbnailUploadTask = await thumbnailRef.putData(
          thumbnailFile,
          SettableMetadata(contentType: 'image/jpeg')
        );
        thumbnailUrl = await thumbnailUploadTask.ref.getDownloadURL();
      }

      // Create video document
      final videoDoc = await _firestore.collection('videos').add({
        'title': title,
        'description': description,
        'instructor': instructor,
        'category': category,
        'subcategory': subcategory,
        'targetRoles': targetRoles,
        'accessLevel': accessLevel,
        'coinCost': coinCost,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'isActive': true,
        'featured': false,
        'duration': 0, // Will be updated after processing
        'qualityUrls': {
          '720p': videoUrl, // Initially same URL
        },
        'chapters': [],
        'subtitles': [],
        'stats': {
          'views': 0,
          'likes': 0,
          'completions': 0,
          'averageRating': 0.0,
        },
        'createdBy': 'admin', // Current admin user
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'publishedAt': FieldValue.serverTimestamp(),
      });

      return videoDoc.id;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  Future<String> addQuestion({
    required String question,
    required String questionType,
    required List<String> options,
    required String correctAnswer,
    required String explanation,
    required String category,
    required String subcategory,
    required String subject,
    required String topic,
    required String difficulty,
    required List<String> targetRoles,
    required List<String> tags,
    Uint8List? imageFile,
    String? imageFileName,
  }) async {
    try {
      // Upload image if provided
      String? imageUrl;
      if (imageFile != null && imageFileName != null) {
        final imageRef = _storage.ref().child('question-images/$imageFileName');
        final imageUploadTask = await imageRef.putData(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg')
        );
        imageUrl = await imageUploadTask.ref.getDownloadURL();
      }

      // Create question document
      final questionDoc = await _firestore.collection('questions').add({
        'question': question,
        'questionType': questionType,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'category': category,
        'subcategory': subcategory,
        'subject': subject,
        'topic': topic,
        'difficulty': difficulty,
        'targetRoles': targetRoles,
        'tags': tags,
        'imageUrl': imageUrl,
        'isActive': true,
        'stats': {
          'attempts': 0,
          'correctAttempts': 0,
          'avgTime': 0,
        },
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return questionDoc.id;
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  Future<String> uploadEbook({
    required String title,
    required String author,
    required String description,
    required String category,
    required String subcategory,
    required List<String> targetRoles,
    required String accessLevel,
    required int coinCost,
    required Uint8List pdfFile,
    required String pdfFileName,
    Uint8List? coverImageFile,
    String? coverImageFileName,
  }) async {
    try {
      // Upload PDF file
      final pdfRef = _storage.ref().child('ebooks/$pdfFileName');
      final pdfUploadTask = await pdfRef.putData(
        pdfFile,
        SettableMetadata(contentType: 'application/pdf')
      );
      final pdfUrl = await pdfUploadTask.ref.getDownloadURL();

      // Upload cover image if provided
      String? coverImageUrl;
      if (coverImageFile != null && coverImageFileName != null) {
        final coverRef = _storage.ref().child('ebook-covers/$coverImageFileName');
        final coverUploadTask = await coverRef.putData(
          coverImageFile,
          SettableMetadata(contentType: 'image/jpeg')
        );
        coverImageUrl = await coverUploadTask.ref.getDownloadURL();
      }

      // Create ebook document
      final ebookDoc = await _firestore.collection('ebooks').add({
        'title': title,
        'author': author,
        'description': description,
        'category': category,
        'subcategory': subcategory,
        'targetRoles': targetRoles,
        'accessLevel': accessLevel,
        'coinCost': coinCost,
        'pdfUrl': pdfUrl,
        'coverImageUrl': coverImageUrl,
        'isActive': true,
        'featured': false,
        'pages': 0, // Will be determined from PDF
        'language': 'en',
        'tags': [],
        'chapters': [],
        'stats': {
          'downloads': 0,
          'readers': 0,
          'averageProgress': 0.0,
        },
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'publishedAt': FieldValue.serverTimestamp(),
      });

      return ebookDoc.id;
    } catch (e) {
      throw Exception('Failed to upload ebook: $e');
    }
  }

  // Analytics Functions
  Future<Map<String, dynamic>> getComprehensiveAnalytics() async {
    try {
      final results = <String, dynamic>{};

      // Get user statistics
      final usersQuery = await _firestore.collection('users').get();
      final totalUsers = usersQuery.docs.length;
      final activeUsers = usersQuery.docs.where((doc) {
        final data = doc.data();
        final lastLogin = data['lastLoginAt'] as Timestamp?;
        if (lastLogin == null) return false;
        return DateTime.now().difference(lastLogin.toDate()).inDays <= 30;
      }).length;

      results['users'] = {
        'total': totalUsers,
        'active': activeUsers,
        'roles': _getUsersByRole(usersQuery.docs),
        'plans': _getUsersByPlan(usersQuery.docs),
      };

      // Get content statistics
      final videosCount = (await _firestore.collection('videos').where('isActive', isEqualTo: true).get()).docs.length;
      final questionsCount = (await _firestore.collection('questions').where('isActive', isEqualTo: true).get()).docs.length;
      final ebooksCount = (await _firestore.collection('ebooks').where('isActive', isEqualTo: true).get()).docs.length;

      results['content'] = {
        'videos': videosCount,
        'questions': questionsCount,
        'ebooks': ebooksCount,
      };

      // Get engagement statistics
      final progressQuery = await _firestore.collection('userProgress').get();
      final totalProgress = progressQuery.docs.length;
      final completedContent = progressQuery.docs.where((doc) => 
        doc.data()['completed'] == true
      ).length;

      results['engagement'] = {
        'totalProgress': totalProgress,
        'completedContent': completedContent,
        'completionRate': totalProgress > 0 ? (completedContent / totalProgress * 100).round() : 0,
      };

      return results;
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }

  Map<String, int> _getUsersByRole(List<QueryDocumentSnapshot> docs) {
    final roles = <String, int>{};
    for (final doc in docs) {
      final role = doc.data() as Map<String, dynamic>;
      final userRole = role['role'] as String? ?? 'unknown';
      roles[userRole] = (roles[userRole] ?? 0) + 1;
    }
    return roles;
  }

  Map<String, int> _getUsersByPlan(List<QueryDocumentSnapshot> docs) {
    final plans = <String, int>{};
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final plan = data['plan'] as String? ?? 'free';
      plans[plan] = (plans[plan] ?? 0) + 1;
    }
    return plans;
  }

  // Content Management Functions
  Future<void> toggleContentStatus(String collection, String documentId, bool isActive) async {
    await _firestore.collection(collection).doc(documentId).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> featureContent(String collection, String documentId, bool featured) async {
    await _firestore.collection(collection).doc(documentId).update({
      'featured': featured,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteContent(String collection, String documentId) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }
}
```

#### 3.2 Admin Panel UI Components

```dart
// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/enhanced_admin_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final EnhancedAdminService _adminService = EnhancedAdminService();
  Map<String, dynamic>? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      final analytics = await _adminService.getComprehensiveAnalytics();
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load analytics: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAnalytics();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  SizedBox(height: 24),
                  _buildQuickActions(),
                  SizedBox(height: 24),
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    if (_analytics == null) return SizedBox();

    final users = _analytics!['users'] as Map<String, dynamic>;
    final content = _analytics!['content'] as Map<String, dynamic>;
    final engagement = _analytics!['engagement'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Total Users', '${users['total']}', Icons.people, Colors.blue)),
            SizedBox(width: 16),
            Expanded(child: _buildStatCard('Active Users', '${users['active']}', Icons.people_outline, Colors.green)),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Videos', '${content['videos']}', Icons.video_library, Colors.orange)),
            SizedBox(width: 16),
            Expanded(child: _buildStatCard('Questions', '${content['questions']}', Icons.quiz, Colors.purple)),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('E-books', '${content['ebooks']}', Icons.book, Colors.red)),
            SizedBox(width: 16),
            Expanded(child: _buildStatCard('Completion Rate', '${engagement['completionRate']}%', Icons.trending_up, Colors.teal)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 2,
          children: [
            _buildActionCard('Add Video', Icons.video_call, () => _navigateToAddVideo()),
            _buildActionCard('Add Question', Icons.quiz, () => _navigateToAddQuestion()),
            _buildActionCard('Upload E-book', Icons.book, () => _navigateToUploadEbook()),
            _buildActionCard('Manage Content', Icons.settings, () => _navigateToContentManagement()),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: Theme.of(context).primaryColor),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 16),
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Recent activity will be shown here...'),
          ),
        ),
      ],
    );
  }

  void _navigateToAddVideo() {
    Navigator.pushNamed(context, '/admin/add-video');
  }

  void _navigateToAddQuestion() {
    Navigator.pushNamed(context, '/admin/add-question');
  }

  void _navigateToUploadEbook() {
    Navigator.pushNamed(context, '/admin/upload-ebook');
  }

  void _navigateToContentManagement() {
    Navigator.pushNamed(context, '/admin/content-management');
  }
}
```

### **Phase 4: Implementation Timeline**

#### **Week 1: Firebase Setup**
- ✅ Enhance Firestore database structure
- ✅ Update security rules
- ✅ Deploy Cloud Functions
- ✅ Test basic CRUD operations

#### **Week 2: Content Management**
- ✅ Implement video upload functionality
- ✅ Add question management system
- ✅ Create e-book upload system
- ✅ Build content editing interfaces

#### **Week 3: Admin Panel**
- ✅ Create comprehensive admin dashboard
- ✅ Build analytics and reporting
- ✅ Implement content moderation tools
- ✅ Add user management features

#### **Week 4: Testing & Optimization**
- ✅ End-to-end testing
- ✅ Performance optimization
- ✅ Security audit
- ✅ Documentation

### **Phase 5: Advanced Features (Month 2)**

#### **Features to Add:**
- 🚀 **Real-time Content Updates**
- 🚀 **Advanced Search with Filters** 
- 🚀 **Content Scheduling**
- 🚀 **Multi-language Support**
- 🚀 **Video Processing Pipeline**
- 🚀 **Advanced Analytics Dashboard**
- 🚀 **Bulk Content Operations**
- 🚀 **Content Approval Workflow**

## Ready to Start Implementation? 🎯

The plan is comprehensive and builds on your existing Firebase integration. We can start with:

1. **Week 1**: Enhanced Firestore structure + Cloud Functions
2. **Week 2**: Content upload system (videos, questions, ebooks)
3. **Week 3**: Advanced admin dashboard
4. **Week 4**: Testing and optimization

All the Firebase services are already configured, so we can begin implementation immediately. Would you like me to start with any specific component?