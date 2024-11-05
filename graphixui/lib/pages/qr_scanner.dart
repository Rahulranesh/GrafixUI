import 'package:flutter/material.dart';
import 'package:graphixui/pages/result_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';

const bgColor = Color(0xfffafafa);

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool isScanCompleted = false;
  bool isTorchOn = false;
  final MobileScannerController cameraController = MobileScannerController();

  void closeScreen() {
    setState(() {
      isScanCompleted = false;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void toggleTorch() {
    setState(() {
      isTorchOn = !isTorchOn;
      cameraController.toggleTorch();
    });
  }

  Future<void> verifyQrCode(String code) async {
    final url = Uri.parse(
        'https://mqnmrqvamm.us-east-1.awsapprunner.com/api/bookings/verifyQrCode');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qrCode': code}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String verificationStatus = data['status'] ?? 'Verification successful';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              code: verificationStatus,
              closeScreen: closeScreen,
            ),
          ),
        );
      } else {
        throw Exception('Failed to verify QR code');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying QR code: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("QR SCANNER"),
        actions: [
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: isTorchOn ? Colors.yellow : Colors.grey,
            ),
            iconSize: 32.0,
            onPressed: toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: const [
                Text(
                  "Place the QR code in the area",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Scanning will start automatically",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 3),
                    ),
                    child: MobileScanner(
                      controller: cameraController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (!isScanCompleted && barcodes.isNotEmpty) {
                          final String code = barcodes.first.rawValue ?? '---';
                          isScanCompleted = true;
                          verifyQrCode(code);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
