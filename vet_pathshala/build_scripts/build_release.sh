#!/bin/bash

# Vet Pathshala Release Build Script
# This script builds production-ready APKs and App Bundles

set -e  # Exit on any error

# Configuration
APP_NAME="Vet Pathshala"
VERSION="1.0.0"
BUILD_NUMBER="1"
PACKAGE_NAME="com.vetpathshala.app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Flutter
    if ! command_exists flutter; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Flutter version
    FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
    log_info "Flutter version: $FLUTTER_VERSION"
    
    # Check if Android SDK is available
    if [ -z "$ANDROID_HOME" ]; then
        log_error "ANDROID_HOME is not set"
        exit 1
    fi
    
    # Check if Java is available
    if ! command_exists java; then
        log_error "Java is not installed or not in PATH"
        exit 1
    fi
    
    # Check Java version
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d '"' -f 2)
    log_info "Java version: $JAVA_VERSION"
    
    log_success "Prerequisites check passed"
}

# Function to clean build artifacts
clean_build() {
    log_info "Cleaning previous build artifacts..."
    
    flutter clean
    rm -rf build/
    
    log_success "Build artifacts cleaned"
}

# Function to get dependencies
get_dependencies() {
    log_info "Getting Flutter dependencies..."
    
    flutter pub get
    
    log_success "Dependencies retrieved"
}

# Function to run code generation
run_code_generation() {
    log_info "Running code generation..."
    
    # Run build_runner if it exists
    if grep -q "build_runner" pubspec.yaml; then
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    log_success "Code generation completed"
}

# Function to analyze code
analyze_code() {
    log_info "Analyzing code..."
    
    flutter analyze
    
    if [ $? -eq 0 ]; then
        log_success "Code analysis passed"
    else
        log_warning "Code analysis found issues - continuing with build"
    fi
}

# Function to run tests
run_tests() {
    log_info "Running tests..."
    
    flutter test
    
    if [ $? -eq 0 ]; then
        log_success "All tests passed"
    else
        log_warning "Some tests failed - continuing with build"
    fi
}

# Function to build Android APK
build_android_apk() {
    log_info "Building Android APK..."
    
    # Set environment variables for Android build
    export ANDROID_HOME="/home/musiliandrew/Android/Sdk"
    export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
    
    # Build release APK
    flutter build apk --release \
        --target-platform android-arm64 \
        --dart-define=ENVIRONMENT=production \
        --dart-define=API_URL=https://api.vetpathshala.com \
        --dart-define=FIREBASE_PROJECT_ID=vetpathshala-prod \
        --dart-define=ANALYTICS_ENABLED=true \
        --dart-define=CRASHLYTICS_ENABLED=true \
        --dart-define=DEBUG_MENU_ENABLED=false
    
    if [ $? -eq 0 ]; then
        log_success "Android APK built successfully"
        
        # Copy APK to release directory
        mkdir -p releases/android
        cp build/app/outputs/flutter-apk/app-release.apk "releases/android/vetpathshala-v${VERSION}-${BUILD_NUMBER}.apk"
        
        # Get APK info
        APK_SIZE=$(du -h "releases/android/vetpathshala-v${VERSION}-${BUILD_NUMBER}.apk" | cut -f1)
        log_info "APK size: $APK_SIZE"
        
    else
        log_error "Android APK build failed"
        return 1
    fi
}

# Function to build Android App Bundle
build_android_bundle() {
    log_info "Building Android App Bundle..."
    
    # Set environment variables for Android build
    export ANDROID_HOME="/home/musiliandrew/Android/Sdk"
    export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
    
    # Build release App Bundle
    flutter build appbundle --release \
        --dart-define=ENVIRONMENT=production \
        --dart-define=API_URL=https://api.vetpathshala.com \
        --dart-define=FIREBASE_PROJECT_ID=vetpathshala-prod \
        --dart-define=ANALYTICS_ENABLED=true \
        --dart-define=CRASHLYTICS_ENABLED=true \
        --dart-define=DEBUG_MENU_ENABLED=false
    
    if [ $? -eq 0 ]; then
        log_success "Android App Bundle built successfully"
        
        # Copy AAB to release directory
        mkdir -p releases/android
        cp build/app/outputs/bundle/release/app-release.aab "releases/android/vetpathshala-v${VERSION}-${BUILD_NUMBER}.aab"
        
        # Get AAB info
        AAB_SIZE=$(du -h "releases/android/vetpathshala-v${VERSION}-${BUILD_NUMBER}.aab" | cut -f1)
        log_info "App Bundle size: $AAB_SIZE"
        
    else
        log_error "Android App Bundle build failed"
        return 1
    fi
}

# Function to build web version
build_web() {
    log_info "Building web version..."
    
    flutter build web --release \
        --dart-define=ENVIRONMENT=production \
        --dart-define=API_URL=https://api.vetpathshala.com \
        --dart-define=FIREBASE_PROJECT_ID=vetpathshala-prod \
        --dart-define=ANALYTICS_ENABLED=true \
        --dart-define=CRASHLYTICS_ENABLED=true \
        --dart-define=DEBUG_MENU_ENABLED=false
    
    if [ $? -eq 0 ]; then
        log_success "Web build completed successfully"
        
        # Create web release archive
        mkdir -p releases/web
        cd build/web
        tar -czf "../../releases/web/vetpathshala-web-v${VERSION}-${BUILD_NUMBER}.tar.gz" .
        cd ../..
        
        # Get web build info
        WEB_SIZE=$(du -h "releases/web/vetpathshala-web-v${VERSION}-${BUILD_NUMBER}.tar.gz" | cut -f1)
        log_info "Web build size: $WEB_SIZE"
        
    else
        log_error "Web build failed"
        return 1
    fi
}

# Function to generate checksums
generate_checksums() {
    log_info "Generating checksums..."
    
    cd releases
    
    # Generate checksums for all files
    find . -type f \( -name "*.apk" -o -name "*.aab" -o -name "*.tar.gz" \) -exec md5sum {} \; > checksums.md5
    find . -type f \( -name "*.apk" -o -name "*.aab" -o -name "*.tar.gz" \) -exec sha256sum {} \; > checksums.sha256
    
    cd ..
    
    log_success "Checksums generated"
}

# Function to create release notes
create_release_notes() {
    log_info "Creating release notes..."
    
    cat > releases/RELEASE_NOTES.md << EOF
# Vet Pathshala v${VERSION} (Build ${BUILD_NUMBER})

## Release Information
- **Version**: ${VERSION}
- **Build Number**: ${BUILD_NUMBER}
- **Release Date**: $(date +%Y-%m-%d)
- **Package Name**: ${PACKAGE_NAME}

## What's New
🎉 Welcome to Vet Pathshala v${VERSION}!

✨ NEW FEATURES:
• Complete video lecture system with HD streaming
• Interactive quiz bank with 1000+ questions
• Comprehensive e-book library
• Advanced drug calculator and interaction checker
• Farmer animal management tools
• QR code-based animal identification
• Gamification system with achievements and rewards

🔧 CORE FUNCTIONALITY:
• Multi-role support (Doctors, Pharmacists, Farmers)
• Offline learning capabilities
• Multi-language support
• Performance optimizations
• Enhanced security features

🎯 PREMIUM FEATURES:
• Coin-based content access system
• Exclusive masterclass content
• Advanced analytics and progress tracking
• Priority customer support

📱 USER EXPERIENCE:
• Modern Material Design 3 interface
• Smooth animations and transitions
• Accessibility improvements
• Dark mode support (coming soon)

## Technical Details
- **Flutter Version**: $(flutter --version | head -n 1 | cut -d ' ' -f 2)
- **Dart Version**: $(flutter --version | grep -o 'Dart [0-9.]*' | cut -d ' ' -f 2)
- **Target SDK**: 34 (Android)
- **Min SDK**: 21 (Android)
- **iOS Deployment Target**: 12.0

## Build Artifacts
EOF

    # Add file information to release notes
    if [ -f "releases/android/vetpathshala-v${VERSION}-${BUILD_NUMBER}.apk" ]; then
        APK_SIZE=$(du -h "releases/android/vetpathshala-v${VERSION}-${BUILD_NUMBER}.apk" | cut -f1)
        echo "- **Android APK**: vetpathshala-v${VERSION}-${BUILD_NUMBER}.apk (${APK_SIZE})" >> releases/RELEASE_NOTES.md
    fi
    
    if [ -f "releases/android/vetpathshala-v${VERSION}-${BUILD_NUMBER}.aab" ]; then
        AAB_SIZE=$(du -h "releases/android/vetpathshala-v${VERSION}-${BUILD_NUMBER}.aab" | cut -f1)
        echo "- **Android App Bundle**: vetpathshala-v${VERSION}-${BUILD_NUMBER}.aab (${AAB_SIZE})" >> releases/RELEASE_NOTES.md
    fi
    
    if [ -f "releases/web/vetpathshala-web-v${VERSION}-${BUILD_NUMBER}.tar.gz" ]; then
        WEB_SIZE=$(du -h "releases/web/vetpathshala-web-v${VERSION}-${BUILD_NUMBER}.tar.gz" | cut -f1)
        echo "- **Web Build**: vetpathshala-web-v${VERSION}-${BUILD_NUMBER}.tar.gz (${WEB_SIZE})" >> releases/RELEASE_NOTES.md
    fi
    
    cat >> releases/RELEASE_NOTES.md << EOF

## Installation Instructions

### Android APK
1. Download the APK file
2. Enable "Install from unknown sources" in Android settings
3. Install the APK file
4. Launch Vet Pathshala

### Android App Bundle (Play Store)
- Submit the AAB file to Google Play Console
- Follow Google Play review process

### Web Version
1. Extract the web build archive
2. Deploy to your web server
3. Access via web browser

## Support
- **Email**: support@vetpathshala.com
- **Website**: https://vetpathshala.com
- **Documentation**: https://docs.vetpathshala.com

## Verification
Use the provided checksums to verify file integrity:
- MD5: See checksums.md5
- SHA256: See checksums.sha256
EOF

    log_success "Release notes created"
}

# Function to print build summary
print_build_summary() {
    echo
    echo "======================================"
    echo "         BUILD SUMMARY"
    echo "======================================"
    echo "App: $APP_NAME"
    echo "Version: $VERSION"
    echo "Build Number: $BUILD_NUMBER"
    echo "Build Date: $(date)"
    echo "======================================"
    
    if [ -d "releases" ]; then
        echo "Build Artifacts:"
        find releases -type f \( -name "*.apk" -o -name "*.aab" -o -name "*.tar.gz" \) -exec ls -lh {} \;
        echo "======================================"
    fi
}

# Main build function
main() {
    log_info "Starting $APP_NAME v$VERSION build process..."
    
    # Check prerequisites
    check_prerequisites
    
    # Clean previous builds
    clean_build
    
    # Get dependencies
    get_dependencies
    
    # Run code generation
    run_code_generation
    
    # Analyze code
    analyze_code
    
    # Run tests
    run_tests
    
    # Build for different platforms
    log_info "Building for multiple platforms..."
    
    # Build Android APK
    build_android_apk
    
    # Build Android App Bundle
    build_android_bundle
    
    # Build Web version
    build_web
    
    # Generate checksums
    generate_checksums
    
    # Create release notes
    create_release_notes
    
    # Print summary
    print_build_summary
    
    log_success "Build process completed successfully!"
    log_info "Release artifacts are available in the 'releases' directory"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --build-number)
            BUILD_NUMBER="$2"
            shift 2
            ;;
        --android-only)
            ANDROID_ONLY=true
            shift
            ;;
        --web-only)
            WEB_ONLY=true
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --version VERSION        Set version number (default: $VERSION)"
            echo "  --build-number NUMBER    Set build number (default: $BUILD_NUMBER)"
            echo "  --android-only           Build only Android versions"
            echo "  --web-only              Build only web version"
            echo "  --help                  Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Run main function
main