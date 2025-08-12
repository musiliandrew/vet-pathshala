import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Conditionally import QR scanner only for non-web platforms
import 'package:qr_code_scanner/qr_code_scanner.dart' if (dart.library.html) 'qr_scanner_web_stub.dart';
import '../../../core/theme/unified_theme.dart';
import '../services/qr_service.dart';
import '../models/animal_model.dart';
import 'animal_profile_screen.dart';
import '../../coins/providers/coin_provider.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  bool isLoading = false;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    if (!kIsWeb && controller != null) {
      if (Platform.isAndroid) {
        controller!.pauseCamera();
      } else if (Platform.isIOS) {
        controller!.resumeCamera();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // For web platforms, show manual input interface instead of camera scanner
    if (kIsWeb) {
      return _buildWebInterface(context);
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: const Text(
          '🔲 Scan Animal QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: const Icon(Icons.flash_on, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          // QR Camera View
          _buildQRView(context),
          
          // Overlay with scanning frame
          _buildScanningOverlay(),
          
          // Instructions at bottom
          _buildInstructions(),
          
          // Loading indicator
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildQRView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
        
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: const Color(0xFF4CAF50),
        borderRadius: 12,
        borderLength: 40,
        borderWidth: 4,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Widget _buildScanningOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
        ),
        child: Center(
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(
                color: isScanning 
                    ? const Color(0xFF4CAF50) 
                    : Colors.grey,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Corner brackets
                ...List.generate(4, (index) {
                  return Positioned(
                    top: index < 2 ? 8 : null,
                    bottom: index >= 2 ? 8 : null,
                    left: index % 2 == 0 ? 8 : null,
                    right: index % 2 == 1 ? 8 : null,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border(
                          top: index < 2 ? BorderSide(color: const Color(0xFF4CAF50), width: 4) : BorderSide.none,
                          bottom: index >= 2 ? BorderSide(color: const Color(0xFF4CAF50), width: 4) : BorderSide.none,
                          left: index % 2 == 0 ? BorderSide(color: const Color(0xFF4CAF50), width: 4) : BorderSide.none,
                          right: index % 2 == 1 ? BorderSide(color: const Color(0xFF4CAF50), width: 4) : BorderSide.none,
                        ),
                      ),
                    ),
                  );
                }),
                
                // Scanning line animation
                if (isScanning)
                  Positioned.fill(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(seconds: 2),
                      builder: (context, value, child) {
                        return CustomPaint(
                          painter: ScanLinePainter(value),
                        );
                      },
                      onEnd: () {
                        if (mounted && isScanning) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text(
              'Position QR code within the frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Animal profile will open automatically when scanned',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Manual input option
            TextButton.icon(
              onPressed: _showManualInputDialog,
              icon: const Icon(Icons.keyboard, color: Colors.white),
              label: const Text(
                'Enter QR data manually',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading animal profile...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    
    controller.scannedDataStream.listen((scanData) {
      if (isScanning && scanData.code != null) {
        setState(() {
          isScanning = false;
          scannedData = scanData.code;
        });
        _processScannedData(scanData.code!);
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission required to scan QR codes'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleFlash() async {
    await controller?.toggleFlash();
  }

  void _processScannedData(String qrData) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Validate if this is an animal QR code
      final animalId = QRService.extractAnimalIdFromQR(qrData);
      
      if (animalId != null) {
        // Try to fetch animal profile
        final animal = await QRService.getAnimalFromQR(qrData);
        
        if (animal != null && mounted) {
          // Award coin for successful QR scan
          context.read<CoinProvider>().addCoins(1, 'QR Code Scan');
          
          // Navigate to animal profile
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AnimalProfileScreen(animal: animal),
            ),
          );
        } else {
          _showErrorDialog('Animal not found', 
            'The scanned QR code does not correspond to any animal in our database.');
        }
      } else {
        // Check if it's a general QR code that might contain animal info
        _showQRDataDialog(qrData);
      }
    } catch (e) {
      _showErrorDialog('Scanning Error', 
        'Unable to process QR code. Please try again or check your internet connection.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showQRDataDialog(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Scanned data:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                data,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This doesn\'t appear to be a valid animal profile QR code.',
              style: TextStyle(color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanning();
            },
            child: const Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanning();
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebInterface(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('🔲 Animal QR Code Scanner'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Color(0xFF2E7D32),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'QR Code Scanner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Camera scanning is not available on web browsers.\nPlease use the manual input option below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showManualInputDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text('Enter QR Code Data Manually'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter QR Code Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste the QR code data or URL:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'https://vetpathshala.app/animal/...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.isNotEmpty) {
                _processScannedData(controller.text);
              }
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  void _resetScanning() {
    setState(() {
      isScanning = true;
      isLoading = false;
      scannedData = null;
    });
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

// Custom painter for scanning line animation
class ScanLinePainter extends CustomPainter {
  final double animationValue;

  ScanLinePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final y = size.height * animationValue;
    
    // Draw scanning line with gradient effect
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFF4CAF50).withOpacity(0.8),
        Colors.transparent,
      ],
    );
    
    final rect = Rect.fromLTWH(0, y - 10, size.width, 20);
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect);
    
    canvas.drawRect(rect, gradientPaint);
    
    // Draw line
    canvas.drawLine(
      Offset(20, y),
      Offset(size.width - 20, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}