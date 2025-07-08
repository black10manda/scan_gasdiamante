import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        backgroundColor: const Color(0xFF971c17),
        foregroundColor: Colors.white,
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          facing: CameraFacing.back,
          torchEnabled: false,
        ),
        onDetect: (capture) {
          if (_scanned) return;
          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;
          if (code != null) {
            _scanned = true;
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}
