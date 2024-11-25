import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PwaScanner extends StatefulWidget {
  @override
  _PwaScannerState createState() => _PwaScannerState();
}

class _PwaScannerState extends State<PwaScanner> {
  bool showScanner = true;
  bool showSuccess = false;
  bool showError = false;
  bool isTorchOn = false;
  Map<String, dynamic>? additionalData;
  final Color navbarColor = const Color.fromARGB(255, 8, 5, 61);
  final MobileScannerController scannerController = MobileScannerController();

  void handleScan(BarcodeCapture barcode) {
    String? qrData =
        barcode.barcodes.isNotEmpty ? barcode.barcodes.first.rawValue : null;
    if (qrData != null) {
      setState(() {
        showScanner = false;
      });
      verifyQR(qrData);
    }
  }

  Future<void> verifyQR(String qrData) async {
    final url = Uri.parse(
        "https://api.ticketverse.eu/api/bookings/verifyQrCode");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'Admin-Signature=ce55f33243',
      },
      body: jsonEncode({'qrCodeData': qrData}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        additionalData = data;
        showSuccess = true;
      });
    } else {
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: navbarColor,
        title: Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  'assets/logo.png',
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_off : Icons.flash_on,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isTorchOn = !isTorchOn;
              });
              scannerController.toggleTorch();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: showScanner
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            "Please Scan Your Ticket Here!!",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: navbarColor,
                            ),
                          ),
                          SizedBox(height: 20),
                          Stack(
                            children: [
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.deepPurple, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.6),
                                      offset: Offset(-5, -5),
                                      blurRadius: 15,
                                    ),
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      offset: Offset(5, 5),
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: MobileScanner(
                                    controller: scannerController,
                                    onDetect: handleScan,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    )
                  : showSuccess
                      ? _buildSuccessDialog()
                      : showError
                          ? _buildErrorDialog()
                          : Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDialog() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 10),
          Text("QR Code successfully verified!"),
        ],
      ),
    );
  }

  Widget _buildErrorDialog() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: 60),
          SizedBox(height: 10),
          Text("Error verifying QR Code!"),
        ],
      ),
    );
  }
}
