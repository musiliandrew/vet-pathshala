# Firebase Collections Documentation for Vet-Pathshala

## Overview
This document provides comprehensive documentation for all Firestore collections used in the Vet-Pathshala application, based on the existing codebase and user-provided Firebase structure.

---

## Collection Structure

### 1. **users** Collection
Stores user authentication and profile information for all three user roles (Doctor, Pharmacist, Farmer).

**Document ID**: Firebase Auth UID

```typescript
{
  id: string,                    // Firebase Auth UID
  email: string,                 // User email address
  displayName: string,           // Full name
  phoneNumber?: string,          // Phone number (optional)
  userRole: string,              // "doctor" | "pharmacist" | "farmer"
  specialization?: string,       // Professional specialization
  experienceYears?: number,      // Years of experience
  profileCompleted: boolean,     // Profile setup completion status
  createdTime: Timestamp,        // Account creation timestamp
  coins: number                  // Drug coins balance (default: 0)
}
```

**Example Document**:
```json
{
  "id": "user123",
  "email": "musili03andrew@gmail.com",
  "displayName": "andrew",
  "phoneNumber": null,
  "userRole": "doctor",
  "specialization": null,
  "experienceYears": null,
  "profileCompleted": false,
  "createdTime": "2025-07-29T06:58:31.000Z",
  "coins": 0
}
```

---

### 2. **questions** Collection
Contains multiple-choice questions for the question bank system, organized by categories and subjects.

**Document ID**: Auto-generated

```typescript
{
  id: string,                    // Document ID
  authorId: string,              // "admin" or user ID who created
  category: string,              // e.g., "Basic Veterinary Science"
  correctAnswer: number,         // Index of correct option (0-based)
  createdAt: Timestamp,          // Question creation date
  difficulty: string,            // "beginner" | "intermediate" | "advanced"
  options: string[],             // Array of answer options
  questionText: string,          // The actual question
  questionType: string,          // "multiple_choice" | "true_false"
  targetRole: string            // "doctor" | "pharmacist" | "farmer"
}
```

**Example Document**:
```json
{
  "authorId": "admin",
  "category": "Basic Veterinary Science",
  "correctAnswer": 1,
  "createdAt": "2025-07-28T00:00:00.000Z",
  "difficulty": "beginner",
  "options": [
    "98.6°F - 99.6°F",
    "100.5°F - 102.5°F",
    "103°F - 104°F",
    "97°F - 98°F"
  ],
  "questionText": "What is the normal body temperature range for dogs?",
  "questionType": "multiple_choice",
  "targetRole": "doctor"
}
```

---

### 3. **notes** Collection
Educational notes and study materials organized by categories and subjects.

**Document ID**: Auto-generated

```typescript
{
  id: string,                    // Document ID
  authorId: string,              // "admin" or content creator ID
  category: string,              // Subject category (e.g., "Anatomy")
  content: string,               // Note content/description
  createdAt: Timestamp,          // Creation timestamp
  downloadUrl: string,           // URL to PDF or content file
  targetRole: string,            // Target user role
  title: string                  // Note title
}
```

**Example Document**:
```json
{
  "authorId": "admin",
  "category": "Anatomy",
  "content": "Essential anatomy knowledge for veterinary students...",
  "createdAt": "2025-07-28T00:00:00.000Z",
  "downloadUrl": "https://example.com/notes/canine-anatomy.pdf",
  "targetRole": "doctor",
  "title": "Canine Anatomy Basics"
}
```

---

### 4. **lecturers** Collection
Video lectures and educational content for different subjects.

**Document ID**: Auto-generated

```typescript
{
  id: string,                    // Document ID
  category: string,              // Subject category
  createdAt: Timestamp,          // Creation timestamp
  description: string,           // Lecture description
  duration: number,              // Duration in seconds
  targetRole: string,            // Target user role
  title: string,                 // Lecture title
  videoUrl: string              // URL to video content
}
```

**Example Document**:
```json
{
  "category": "Introduction",
  "createdAt": "2025-07-28T00:00:00.000Z",
  "description": "Basic concepts for new veterinary students",
  "duration": 1800,
  "targetRole": "doctor",
  "title": "Introduction to Veterinary Medicine",
  "videoUrl": "https://example.com/videos/intro-vet-med.mp4"
}
```

---

### 5. **subscriptions** Collection
User subscription information for premium features.

**Document ID**: Auto-generated

```typescript
{
  id: string,                    // Document ID
  userId: string,                // Reference to user ID
  planType: string,              // "basic" | "premium" | "enterprise"
  status: string,                // "active" | "inactive" | "expired"
  startDate: Timestamp,          // Subscription start date
  endDate: Timestamp,            // Subscription end date
  price: number                  // Subscription price
}
```

**Example Document**:
```json
{
  "userId": "example-user-id",
  "planType": "premium",
  "status": "active",
  "startDate": "2025-07-28T00:00:00.000Z",
  "endDate": "2025-08-28T00:00:00.000Z",
  "price": 299
}
```

---

### 6. **coinTransactions** Collection
Tracks all drug coin transactions for earning and spending.

**Document ID**: Auto-generated

```typescript
{
  id: string,                    // Document ID
  userId: string,                // User who made the transaction
  amount: number,                // Coin amount (positive for earned, negative for spent)
  type: string,                  // "earned" | "spent" | "purchased"
  reason: string,                // Description of transaction
  createdAt: Timestamp          // Transaction timestamp
}
```

**Example Document**:
```json
{
  "userId": "example-user-id",
  "amount": 50,
  "type": "earned",
  "reason": "Completed quiz",
  "createdAt": "2025-07-28T00:00:00.000Z"
}
```

---

## Security Rules

### Current Implementation
Based on the codebase structure, the following security considerations are implemented:

1. **User Document Access**: Users can only read/write their own user documents
2. **Content Access**: Read access to questions, notes, and lectures based on user roles
3. **Coin Transactions**: Users can only read their own transaction history
4. **Subscriptions**: Users can only access their own subscription data

### Recommended Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Questions are readable by authenticated users based on targetRole
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userRole == 'admin';
    }
    
    // Notes are readable by authenticated users based on targetRole
    match /notes/{noteId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userRole == 'admin';
    }
    
    // Lectures are readable by authenticated users based on targetRole
    match /lecturers/{lectureId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.userRole == 'admin';
    }
    
    // Users can only access their own subscriptions
    match /subscriptions/{subscriptionId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Users can only access their own coin transactions
    match /coinTransactions/{transactionId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## Data Models in Code

The application includes comprehensive Dart models for type safety:

### Key Model Classes
- **UserModel**: Complete user information with coins integration
- **QuestionModel**: Question bank items with categories and difficulty
- **LectureModel**: Video lecture metadata
- **NoteModel**: Study notes and materials
- **CoinTransactionModel**: Drug coin transaction tracking
- **SubscriptionModel**: User subscription management

### Additional Profile Models
- **UserProfile**: Extended profile information
- **UserPreferences**: App settings and preferences
- **UserStats**: Learning analytics and progress tracking

---

## Implementation Status

### ✅ Completed Features
- **Authentication System**: Multi-provider auth (Email, Google, Phone OTP)
- **User Management**: Complete profile setup with role-based customization
- **Drug Coins System**: Earning, spending, and transaction tracking
- **Core Infrastructure**: Firebase integration with proper models

### 🚧 In Progress
- **Content Management**: Question bank and notes system
- **Learning Analytics**: Progress tracking and statistics

### 📋 Planned Features
- **Gamification**: Battle mode and leaderboards
- **Subscription System**: Premium feature access
- **Admin Panel**: Content management and analytics

---

## Usage Examples

### Creating a New User
```dart
final userModel = UserModel(
  id: user.uid,
  email: user.email ?? '',
  displayName: name,
  userRole: selectedRole,
  profileCompleted: true,
  createdTime: DateTime.now(),
  coins: 0,
);

await FirebaseFirestore.instance
  .collection('users')
  .doc(user.uid)
  .set(userModel.toFirestore());
```

### Recording a Coin Transaction
```dart
final transaction = CoinTransactionModel(
  id: '',
  userId: currentUser.id,
  amount: 5,
  type: 'earned',
  reason: 'Daily login bonus',
  createdAt: DateTime.now(),
);

await FirebaseFirestore.instance
  .collection('coinTransactions')
  .add(transaction.toFirestore());
```

---

*Last Updated: January 29, 2025*
*Version: 1.0*