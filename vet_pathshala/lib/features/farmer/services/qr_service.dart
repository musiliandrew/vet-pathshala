import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/animal_model.dart';

class QRService {
  static const String baseUrl = 'https://vetpathshala.app/animal/';
  
  /// Generate QR code data for an animal profile
  static String generateAnimalQRData(AnimalModel animal) {
    return '$baseUrl${animal.id}?name=${Uri.encodeComponent(animal.name)}&type=${animal.type}&owner=${animal.ownerId}';
  }
  
  /// Create high-quality QR code widget
  static Widget buildQRWidget(String data, {double size = 200.0}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            // errorCorrectionLevel: QrErrorCorrectLevel.H, // Removed for compatibility
            padding: const EdgeInsets.all(8),
            semanticsLabel: 'QR Code for animal profile',
            embeddedImage: null, // Could add logo here if needed
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Scan with camera to view profile',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'Google Lens compatible',
            style: TextStyle(
              fontSize: 10,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Generate and save QR code image to device
  static Future<String?> saveQRCodeImage(
    String data, 
    String animalName, {
    double size = 300.0,
  }) async {
    try {
      // Request storage permission
      final permission = await Permission.storage.request();
      if (!permission.isGranted) {
        throw Exception('Storage permission required to save QR code');
      }
      
      // Create QR code widget
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        // errorCorrectionLevel: QrErrorCorrectLevel.H, // Removed for compatibility
      );
      
      if (!qrValidationResult.isValid) {
        throw Exception('Invalid QR code data');
      }
      
      // Generate QR code painter
      final qrCode = qrValidationResult.qrCode!;
      final painter = QrPainter.withQr(
        qr: qrCode,
        color: Colors.black,
        emptyColor: Colors.white,
        // errorCorrectionLevel: QrErrorCorrectLevel.H, // Removed for compatibility
      );
      
      // Create image from painter
      final picData = await painter.toImageData(size);
      if (picData == null) {
        throw Exception('Failed to generate QR code image');
      }
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final qrDirectory = Directory('${directory.path}/qr_codes');
      if (!await qrDirectory.exists()) {
        await qrDirectory.create(recursive: true);
      }
      
      // Save image file
      final fileName = 'QR_${animalName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${qrDirectory.path}/$fileName');
      await file.writeAsBytes(picData.buffer.asUint8List());
      
      return file.path;
    } catch (e) {
      print('Error saving QR code: $e');
      return null;
    }
  }
  
  /// Share QR code with animal details
  static Future<void> shareAnimalQR(AnimalModel animal) async {
    try {
      final qrData = generateAnimalQRData(animal);
      final imagePath = await saveQRCodeImage(qrData, animal.name);
      
      if (imagePath != null) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: '🐄 ${animal.name} (${animal.type})\n'
                'Scan QR code to view full animal profile\n'
                'Via Vet-Pathshala App',
          subject: 'Animal Profile - ${animal.name}',
        );
      } else {
        // Fallback to sharing URL only
        await Share.share(
          '🐄 ${animal.name} Profile\n$qrData\n\nScan QR or visit link to view details',
          subject: 'Animal Profile - ${animal.name}',
        );
      }
    } catch (e) {
      print('Error sharing QR code: $e');
      throw Exception('Failed to share QR code');
    }
  }
  
  /// Validate and extract animal ID from QR data
  static String? extractAnimalIdFromQR(String qrData) {
    try {
      if (qrData.startsWith(baseUrl)) {
        final uri = Uri.parse(qrData);
        final animalId = uri.pathSegments.lastWhere(
          (segment) => segment.isNotEmpty,
          orElse: () => '',
        );
        return animalId.isNotEmpty ? animalId : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Fetch animal profile from QR scan
  static Future<AnimalModel?> getAnimalFromQR(String qrData) async {
    try {
      final animalId = extractAnimalIdFromQR(qrData);
      if (animalId == null) return null;
      
      final doc = await FirebaseFirestore.instance
          .collection('animals')
          .doc(animalId)
          .get();
      
      if (doc.exists) {
        return AnimalModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching animal from QR: $e');
      return null;
    }
  }
  
  /// Generate batch QR codes for multiple animals
  static Future<Map<String, String?>> generateBatchQRCodes(
    List<AnimalModel> animals,
    {double size = 300.0}
  ) async {
    final results = <String, String?>{};
    
    for (final animal in animals) {
      final qrData = generateAnimalQRData(animal);
      final imagePath = await saveQRCodeImage(qrData, animal.name, size: size);
      results[animal.id] = imagePath;
      
      // Add small delay to prevent overwhelming the system
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return results;
  }
  
  /// Update animal's QR code in database
  static Future<void> updateAnimalQRCode(String animalId, String qrCode) async {
    try {
      await FirebaseFirestore.instance
          .collection('animals')
          .doc(animalId)
          .update({'qrCode': qrCode});
    } catch (e) {
      print('Error updating animal QR code: $e');
      throw Exception('Failed to update QR code');
    }
  }
}