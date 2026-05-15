import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'edit_page.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {

  final MobileScannerController controller = MobileScannerController();
  bool scanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR / Barcode")),
      body: MobileScanner(
        controller: controller,

        // ✅ Updated callback format
        onDetect: (BarcodeCapture capture) async {

          if (scanned) return;

          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isEmpty) return;

          final String? code = barcodes.first.rawValue;

          if (code == null) return;

          scanned = true;
          await controller.stop();

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditPage(initialData: code),
            ),
          );

          scanned = false;
          await controller.start();
        },
      ),
    );
  }
}
