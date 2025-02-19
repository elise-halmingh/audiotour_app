import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audiotour_apps/screens/photo_play_screen.dart';

class QRScannerScreen extends StatefulWidget {
  final int nextQRCode;

  const QRScannerScreen({Key? key, required this.nextQRCode}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f0ea),
      appBar: AppBar(
        backgroundColor: const Color(0xfff1f0ea),
        title: const Text('QR Scanner'),
      ),
      body: Center(
        child: _isScanning
            ? MobileScanner(
          onDetect: (barcodeCapture) {
            final String code = barcodeCapture.barcodes.isNotEmpty
                ? barcodeCapture.barcodes.first.rawValue ?? 'Unknown QR Code'
                : 'No QR Code detected';

            print('QR Code detected: $code');

            // Check if the QR code matches the nextQRCode
            if (int.parse(code) == widget.nextQRCode) {
              setState(() {
                _isScanning = false;
              });

              // After scanning, navigate to the PhotoPlay screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoPlayScreen(currentQR: widget.nextQRCode),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please scan QR code ${widget.nextQRCode} first.')),
              );
            }
          },
        )
            : const Center(
          child: Text('Processing QR code...'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _isScanning = false;
  }
}
