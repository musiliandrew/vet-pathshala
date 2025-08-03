# Vet-Pathshala 🐕 💊 🌾

Educational platform for Veterinary professionals - Doctors, Pharmacists, and Farmers.

## 📋 Project Status

**Current Version**: v0.2.0-alpha  
**Development Status**: 🚧 Active Development  
**Last Updated**: January 29, 2025

### Quick Links
- 📊 [Development Progress](./DEVELOPMENT_PROGRESS.md)
- 🎯 [Milestone Tracker](./MILESTONE_TRACKER.md)  
- 🧪 [Testing Log](./TESTING_LOG.md)

## ✅ Completed Features

- **Authentication System**: Email, Google, Phone OTP
- **Role-Based Access**: Doctor, Pharmacist, Farmer roles
- **Enhanced Profile Setup**: 3-step modern UI flow
- **Firebase Integration**: Firestore, Auth, Web config

## 🚧 Current Development

- **Main Dashboard**: Role-based home screen
- **Navigation System**: Bottom navigation with role customization

## 🚀 Getting Started

### Prerequisites
- Flutter 3.24+
- Dart 3.5+
- Firebase project configured

### Installation
```bash
# Clone the repository
git clone <repository-url>
cd vet_pathshala

# Install dependencies
flutter pub get

# Run for web
flutter run -d chrome

# Build for web
flutter build web
```

### Firebase Setup
1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email, Google, Phone)
3. Create Firestore database
4. Add your platform configurations

## 🏗️ Architecture

### Project Structure
```
lib/
├── core/                 # Core utilities, constants, themes
├── features/            # Feature-based modules
│   ├── auth/           # Authentication & profile setup
│   └── home/           # Dashboard & navigation
├── shared/             # Shared models, widgets, providers
└── main.dart           # App entry point
```

### Key Technologies
- **Framework**: Flutter 3.24+
- **State Management**: Provider
- **Backend**: Firebase (Auth + Firestore)
- **UI Design**: Material Design 3
- **Platforms**: Web, Android, iOS

## 📱 Features Overview

### For Veterinarians 🐕
- Advanced medical content
- Surgery & treatment guides
- Drug calculations & interactions
- Professional development courses

### For Pharmacists 💊  
- Drug compounding guides
- Dosage calculators (Drug Coins required)
- Clinical pharmacy content
- Regulatory compliance info

### For Farmers 🌾
- Animal health basics
- Disease prevention
- Nutrition guidelines
- Breeding best practices

## 🪙 Drug Coins System (Upcoming)
- **Drug Index**: 100% Free access
- **Drug Calculator**: Premium feature (coins required)
- **Earn Coins**: Watch ads, complete lessons
- **Buy Coins**: In-app purchases

## 🧪 Testing

Run the test suite:
```bash
flutter test
flutter analyze
```

See [Testing Log](./TESTING_LOG.md) for detailed test results.

## 📚 Documentation

- [Development Progress](./DEVELOPMENT_PROGRESS.md) - Current development status
- [Milestone Tracker](./MILESTONE_TRACKER.md) - Feature completion tracking  
- [Testing Log](./TESTING_LOG.md) - Test results and coverage

## 🤝 Contributing

1. Check current milestones in [Milestone Tracker](./MILESTONE_TRACKER.md)
2. Follow the existing code structure and patterns
3. Update documentation for new features
4. Ensure tests pass before submitting

## 📄 License

This project is proprietary software for Vet-Pathshala educational platform.

---

**Built with ❤️ for the Veterinary Community**
