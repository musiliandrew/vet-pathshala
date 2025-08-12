// Web stub for QR scanner functionality
// This file provides dummy classes for web builds where QR scanner is not available

import 'dart:async';
import 'package:flutter/widgets.dart';

class QRViewController {
  Future<void> pauseCamera() async {}
  Future<void> resumeCamera() async {}
  Future<void> dispose() async {}
  Future<void> toggleFlash() async {}
  
  Stream<Barcode> get scannedDataStream => Stream<Barcode>.empty();
}

class QRView extends StatelessWidget {
  final Key? key;
  final Function(QRViewController)? onQRViewCreated;
  final List<BarcodeFormat>? formatsAllowed;
  final Function(QRViewController, bool)? onPermissionSet;
  final Widget? overlay;
  
  const QRView({
    this.key,
    this.onQRViewCreated,
    this.formatsAllowed,
    this.onPermissionSet,
    this.overlay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return empty container for web builds
    return Container();
  }
}

class Barcode {
  final String? code;
  final BarcodeFormat? format;
  
  Barcode(this.code, {this.format});
}

class BarcodeFormat {
  static const qrcode = BarcodeFormat._('qrcode');
  const BarcodeFormat._(this.name);
  final String name;
}

class QrScannerOverlayShape extends StatelessWidget {
  final double? borderRadius;
  final Color? borderColor;
  final double? borderLength;
  final double? borderWidth;
  final double? cutOutSize;
  final double? cutOutBottomOffset;
  final Widget? overlayColor;
  
  const QrScannerOverlayShape({
    super.key,
    this.borderRadius,
    this.borderColor,
    this.borderLength,
    this.borderWidth,
    this.cutOutSize,
    this.cutOutBottomOffset,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(); // Empty for web builds
  }
}