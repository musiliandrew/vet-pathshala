import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  // Check notification permission status
  Future<PermissionStatus> getNotificationPermissionStatus() async {
    return await Permission.notification.status;
  }

  // Request notification permission
  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  // Check storage permission status
  Future<PermissionStatus> getStoragePermissionStatus() async {
    return await Permission.storage.status;
  }

  // Request storage permission
  Future<PermissionStatus> requestStoragePermission() async {
    return await Permission.storage.request();
  }

  // Check camera permission status
  Future<PermissionStatus> getCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  // Request camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  // Check microphone permission status
  Future<PermissionStatus> getMicrophonePermissionStatus() async {
    return await Permission.microphone.status;
  }

  // Request microphone permission
  Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  // Check phone permission status
  Future<PermissionStatus> getPhonePermissionStatus() async {
    return await Permission.phone.status;
  }

  // Request phone permission
  Future<PermissionStatus> requestPhonePermission() async {
    return await Permission.phone.request();
  }

  // Request multiple permissions at once
  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    List<Permission> permissions,
  ) async {
    return await permissions.request();
  }

  // Check if all required permissions are granted
  Future<bool> areRequiredPermissionsGranted() async {
    final notificationStatus = await getNotificationPermissionStatus();
    final storageStatus = await getStoragePermissionStatus();
    
    return notificationStatus.isGranted && 
           (storageStatus.isGranted || storageStatus.isLimited);
  }

  // Request all required permissions
  Future<bool> requestRequiredPermissions() async {
    final permissions = [
      Permission.notification,
      Permission.storage,
    ];

    final statuses = await requestMultiplePermissions(permissions);
    
    final notificationGranted = statuses[Permission.notification]?.isGranted ?? false;
    final storageStatus = statuses[Permission.storage];
    final storageGranted = (storageStatus?.isGranted ?? false) || 
                          (storageStatus?.isLimited ?? false);
    
    return notificationGranted && storageGranted;
  }

  // Open app settings
  Future<bool> openDeviceSettings() async {
    return await openAppSettings();
  }

  // Check if permission is permanently denied
  bool isPermanentlyDenied(PermissionStatus status) {
    return status.isPermanentlyDenied;
  }

  // Get permission status message
  String getPermissionStatusMessage(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Permission granted';
      case PermissionStatus.denied:
        return 'Permission denied';
      case PermissionStatus.restricted:
        return 'Permission restricted';
      case PermissionStatus.limited:
        return 'Permission limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permission permanently denied';
      case PermissionStatus.provisional:
        return 'Permission provisional';
    }
  }
}