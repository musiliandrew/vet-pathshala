class FirebaseAvailability {
  static bool isAvailable = false;
  
  static String get unavailableMessage => 
    'Firebase services are currently unavailable. Please check your internet connection and try again.';
}