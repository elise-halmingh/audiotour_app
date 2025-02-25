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
  bool _isDialogOpen = false; // Voorkomt spam van foutmeldingen

  // Pop-up
  void _showErrorDialog(String message) {
    if (_isDialogOpen) return; // Voorkomt dubbele meldingen

    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xfff1f0ea) ,
        title: const Text('Foutmelding'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              _isDialogOpen = false;
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Color(0xff82A790)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
            if (_isDialogOpen) return; // Stop scanner als er een foutmelding open is

            final String? rawCode = barcodeCapture.barcodes.isNotEmpty
                ? barcodeCapture.barcodes.first.rawValue
                : null;

            if (rawCode == null || rawCode.isEmpty) {
              _showErrorDialog('Mislukt om QR-code te scannen. Probeer het opnieuw.');
              return;
            }

            print('QR Code detected: $rawCode');

            int? scannedCode = int.tryParse(rawCode);

            if (scannedCode == null) {
              _showErrorDialog('Onbekende QR-code. Deze code wordt niet herkend.');
              return;
            }

            if (scannedCode == widget.nextQRCode) {
              setState(() {
                _isScanning = false;
              });

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PhotoPlayScreen(currentQR: widget.nextQRCode),
                ),
              );
            } else {
              _showErrorDialog('Onjuiste scanvolgorde. Scan eerst QR-code ${widget.nextQRCode}.');
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
