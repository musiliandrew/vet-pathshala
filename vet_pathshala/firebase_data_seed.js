// Firebase Data Seeding Script
// Run this in Firebase Console or Firebase CLI to create missing collections

// 1. CREATE VIDEO_LECTURES COLLECTION (from your lecturers data)
const videoLecturesData = [
  {
    id: 'video_1',
    title: 'Introduction to Veterinary Medicine',
    description: 'Basic concepts for new veterinary students',
    instructor: 'Dr. Sarah Johnson',
    instructorBio: 'DVM, PhD in Veterinary Medicine with 15+ years experience',
    thumbnailUrl: 'https://example.com/thumbnails/intro_vet.jpg',
    videoUrl: 'https://example.com/videos/intro-vet-med.mp4',
    targetRoles: ['doctor'],
    category: 'basics',
    accessLevel: 'free',
    status: 'published',
    duration: 1800,
    coinCost: 0,
    qualityUrls: {
      'sd_480': 'https://example.com/videos/intro_480p.mp4',
      'hd_720': 'https://example.com/videos/intro_720p.mp4'
    },
    chapters: [],
    subtitles: [],
    rating: 4.5,
    viewCount: 245,
    downloadCount: 89,
    isDownloadable: true,
    metadata: { difficulty: 'beginner', credits: 2 },
    tags: ['veterinary', 'introduction', 'basics'],
    createdAt: new Date('2024-07-28'),
    updatedAt: new Date('2024-08-20'),
    publishedAt: new Date('2024-07-28')
  },
  {
    id: 'video_2',
    title: 'Canine Cardiac Anatomy',
    description: 'Understanding heart structure in dogs',
    instructor: 'Dr. Maria Rodriguez',
    instructorBio: 'Veterinary Cardiologist, 10+ years experience',
    thumbnailUrl: 'https://example.com/thumbnails/cardiac.jpg',
    videoUrl: 'https://example.com/videos/cardiac-anatomy.mp4',
    targetRoles: ['doctor', 'pharmacist'],
    category: 'anatomy',
    accessLevel: 'premium',
    status: 'published',
    duration: 2400,
    coinCost: 5,
    qualityUrls: {
      'sd_480': 'https://example.com/videos/cardiac_480p.mp4',
      'hd_720': 'https://example.com/videos/cardiac_720p.mp4'
    },
    chapters: [],
    subtitles: [],
    rating: 4.8,
    viewCount: 156,
    downloadCount: 67,
    isDownloadable: true,
    metadata: { difficulty: 'intermediate', credits: 3 },
    tags: ['anatomy', 'heart', 'cardiology', 'canine'],
    createdAt: new Date('2024-08-01'),
    updatedAt: new Date('2024-08-15'),
    publishedAt: new Date('2024-08-01')
  }
];

// 2. CREATE EBOOKS COLLECTION
const ebooksData = [
  {
    id: 'ebook_1',
    title: 'Veterinary Anatomy Handbook',
    description: 'Comprehensive guide to animal anatomy for veterinary professionals',
    author: 'Dr. James Wilson',
    authorBio: 'Professor of Veterinary Anatomy, 20+ years teaching experience',
    coverImageUrl: 'https://example.com/covers/anatomy_handbook.jpg',
    fileUrl: 'https://example.com/ebooks/anatomy_handbook.pdf',
    fileSize: 25600000, // 25.6 MB
    pageCount: 450,
    targetRoles: ['doctor', 'pharmacist'],
    category: 'anatomy',
    type: 'textbook',
    accessLevel: 'free',
    coinCost: 0,
    language: 'en',
    isbn: '978-0123456789',
    publisher: 'Veterinary Education Press',
    publishedDate: new Date('2024-01-15'),
    edition: '3rd Edition',
    rating: 4.6,
    downloadCount: 1250,
    isActive: true,
    tags: ['anatomy', 'reference', 'comprehensive'],
    metadata: { difficulty: 'intermediate', category: 'reference' },
    createdAt: new Date('2024-07-20'),
    updatedAt: new Date('2024-08-10')
  },
  {
    id: 'ebook_2',
    title: 'Small Animal Surgery Guide',
    description: 'Step-by-step surgical procedures for small animals',
    author: 'Dr. Lisa Chen',
    authorBio: 'Board-certified veterinary surgeon',
    coverImageUrl: 'https://example.com/covers/surgery_guide.jpg',
    fileUrl: 'https://example.com/ebooks/surgery_guide.pdf',
    fileSize: 45600000, // 45.6 MB
    pageCount: 678,
    targetRoles: ['doctor'],
    category: 'surgery',
    type: 'manual',
    accessLevel: 'premium',
    coinCost: 15,
    language: 'en',
    isbn: '978-0987654321',
    publisher: 'Surgical Arts Publishing',
    publishedDate: new Date('2024-03-10'),
    edition: '2nd Edition',
    rating: 4.9,
    downloadCount: 456,
    isActive: true,
    tags: ['surgery', 'procedures', 'small-animal'],
    metadata: { difficulty: 'advanced', category: 'clinical' },
    createdAt: new Date('2024-07-25'),
    updatedAt: new Date('2024-08-12')
  }
];

// 3. CREATE QUIZZES COLLECTION (from your questions data)
const quizzesData = [
  {
    id: 'quiz_1',
    title: 'Animal Anatomy Basics',
    description: 'Test your knowledge of basic animal anatomy',
    category: 'Animal Anatomy',
    subject: 'Anatomy',
    targetRole: 'doctor',
    type: 'practice',
    difficulty: 'easy',
    questionCount: 10,
    timeLimit: 600, // 10 minutes
    questionPool: [], // Will be populated with question IDs
    passingScore: 70,
    coinReward: 5,
    isActive: true,
    metadata: {
      instructions: 'Answer all questions to complete the quiz',
      showCorrectAnswers: true,
      allowRetakes: true
    },
    createdAt: new Date('2024-08-14'),
    updatedAt: new Date('2024-08-19'),
    createdBy: 'admin'
  },
  {
    id: 'quiz_2',
    title: 'Veterinary Pharmacology Quiz',
    description: 'Advanced quiz on veterinary medications',
    category: 'Pharmacology',
    subject: 'Pharmacology',
    targetRole: 'pharmacist',
    type: 'timed',
    difficulty: 'intermediate',
    questionCount: 15,
    timeLimit: 900, // 15 minutes
    questionPool: [],
    passingScore: 80,
    coinReward: 10,
    isActive: true,
    metadata: {
      instructions: 'Timed quiz - answer quickly and accurately',
      showCorrectAnswers: false,
      allowRetakes: false
    },
    createdAt: new Date('2024-08-10'),
    updatedAt: new Date('2024-08-15'),
    createdBy: 'admin'
  }
];

// 4. CREATE USER_VIDEO_PROGRESS COLLECTION (empty but with structure)
const userVideoProgressStructure = {
  // Example structure - this will be created when users watch videos
  userId: 'string',
  videoId: 'string',
  currentPosition: 0, // seconds
  watchedPercentage: 0.0,
  isCompleted: false,
  bookmarks: [],
  notes: [],
  selectedQuality: 'auto',
  selectedSubtitleLanguage: null,
  playbackSpeed: 1.0,
  totalWatchTime: 0,
  watchCount: 1,
  lastWatchedAt: new Date(),
  createdAt: new Date(),
  watchData: {}
};

// 5. CREATE USER_EBOOKS COLLECTION (empty but with structure)
const userEbooksStructure = {
  // Example structure - this will be created when users access ebooks
  userId: 'string',
  ebookId: 'string',
  accessedAt: new Date(),
  downloadedAt: null,
  currentPage: 1,
  readingProgress: 0.0,
  isBookmarked: false,
  isDownloaded: false,
  lastReadAt: new Date(),
  totalReadingTime: 0,
  readingData: {}
};

// 6. CREATE QUIZ_ATTEMPTS COLLECTION (empty but with structure)
const quizAttemptsStructure = {
  // Example structure - this will be created when users take quizzes
  userId: 'string',
  quizId: 'string',
  answers: [],
  startTime: new Date(),
  endTime: null,
  timeSpent: 0,
  score: 0,
  totalQuestions: 0,
  accuracy: 0.0,
  isCompleted: false,
  metadata: {}
};

console.log('=== FIREBASE DATA SEEDING INSTRUCTIONS ===');
console.log('');
console.log('Run these commands in Firebase Console or Firebase CLI:');
console.log('');
console.log('1. CREATE video_lectures collection:');
videoLecturesData.forEach((video, index) => {
  console.log(`db.collection('video_lectures').doc('${video.id}').set(${JSON.stringify(video, null, 2)});`);
});

console.log('');
console.log('2. CREATE ebooks collection:');
ebooksData.forEach((ebook, index) => {
  console.log(`db.collection('ebooks').doc('${ebook.id}').set(${JSON.stringify(ebook, null, 2)});`);
});

console.log('');
console.log('3. CREATE quizzes collection:');
quizzesData.forEach((quiz, index) => {
  console.log(`db.collection('quizzes').doc('${quiz.id}').set(${JSON.stringify(quiz, null, 2)});`);
});

console.log('');
console.log('4. Update your existing questions collection to add quiz references');
console.log('');
console.log('=== ALTERNATIVE: Use the Flutter admin panel to seed this data ===');