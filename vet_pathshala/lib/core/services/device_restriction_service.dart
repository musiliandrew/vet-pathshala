import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../utils/firebase_availability.dart';

class DeviceRestrictionService {
  static const String _deviceIdKey = 'device_id';
  static const String _userDevicesCollection = 'user_devices';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId == null) {
      deviceId = await _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    
    return deviceId;
  }

  Future<String> _generateDeviceId() async {
    try {
      String deviceInfo = '';
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceInfo = '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceInfo = '${iosInfo.name}_${iosInfo.model}_${iosInfo.identifierForVendor}';
      } else {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceInfo = '${webInfo.browserName}_${webInfo.platform}_${webInfo.userAgent}';
      }
      
      final bytes = utf8.encode(deviceInfo + DateTime.now().millisecondsSinceEpoch.toString());
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      final fallbackId = DateTime.now().millisecondsSinceEpoch.toString();
      final bytes = utf8.encode(fallbackId);
      final digest = sha256.convert(bytes);
      return digest.toString();
    }
  }

  Future<bool> isDeviceAllowedForUser(String userId) async {
    if (!FirebaseAvailability.isAvailable) {
      return true;
    }

    try {
      final deviceId = await getDeviceId();
      final userDeviceDoc = await _firestore
          .collection(_userDevicesCollection)
          .doc(userId)
          .get();

      if (!userDeviceDoc.exists) {
        return true;
      }

      final data = userDeviceDoc.data() as Map<String, dynamic>;
      final registeredDeviceId = data['deviceId'] as String?;
      final registrationTime = (data['registrationTime'] as Timestamp?)?.toDate();
      
      if (registeredDeviceId == null) {
        return true;
      }

      if (registeredDeviceId == deviceId) {
        return true;
      }

      if (registrationTime != null) {
        final daysSinceRegistration = DateTime.now().difference(registrationTime).inDays;
        if (daysSinceRegistration > 30) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('🔴 DeviceRestriction: Error checking device: $e');
      return true;
    }
  }

  Future<void> registerDeviceForUser(String userId) async {
    if (!FirebaseAvailability.isAvailable) return;

    try {
      final deviceId = await getDeviceId();
      await _firestore.collection(_userDevicesCollection).doc(userId).set({
        'deviceId': deviceId,
        'registrationTime': FieldValue.serverTimestamp(),
        'lastLoginTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('🔴 DeviceRestriction: Error registering device: $e');
    }
  }

  Future<void> updateLastLoginTime(String userId) async {
    if (!FirebaseAvailability.isAvailable) return;

    try {
      final deviceId = await getDeviceId();
      final userDeviceDoc = await _firestore
          .collection(_userDevicesCollection)
          .doc(userId)
          .get();

      if (userDeviceDoc.exists) {
        final data = userDeviceDoc.data() as Map<String, dynamic>;
        final registeredDeviceId = data['deviceId'] as String?;
        
        if (registeredDeviceId == deviceId) {
          await _firestore.collection(_userDevicesCollection).doc(userId).update({
            'lastLoginTime': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('🔴 DeviceRestriction: Error updating login time: $e');
    }
  }

  Future<bool> requestDeviceChange(String userId, String reason) async {
    if (!FirebaseAvailability.isAvailable) return false;

    try {
      await _firestore.collection('device_change_requests').add({
        'userId': userId,
        'oldDeviceId': await _getCurrentRegisteredDevice(userId),
        'newDeviceId': await getDeviceId(),
        'reason': reason,
        'requestTime': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      return true;
    } catch (e) {
      print('🔴 DeviceRestriction: Error requesting device change: $e');
      return false;
    }
  }

  Future<String?> _getCurrentRegisteredDevice(String userId) async {
    try {
      final doc = await _firestore
          .collection(_userDevicesCollection)
          .doc(userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['deviceId'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}