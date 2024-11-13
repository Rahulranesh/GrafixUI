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
        "https://mqnmrqvamm.us-east-1.awsapprunner.com/api/bookings/verifyQrCode");

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
        title: Text("PWA Scanner", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: navbarColor,
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
      body: Center(
        child: showScanner
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  // Adjusted Logo image with border radius and slight curve
                  
                  Container(
  width: 120,
  decoration: BoxDecoration(
    color: navbarColor,
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(8), // Padding around the logo
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
)
,
                  SizedBox(height: 20),
                  // Instructions
                  Text(
                    "Please Scan Your Ticket Here!!",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: navbarColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Scan in this area!!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Scanner container with neumorphism effect
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.deepPurple, width: 3),
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
              )
            : showSuccess
                ? _buildSuccessDialog()
                : showError
                    ? _buildErrorDialog()
                    : Container(),
      ),
    );
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              "QR Successfully Completed",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: navbarColor,
              ),
            ),
            SizedBox(height: 10),
            if (additionalData != null) ...[
              Text(
                "Type Name: ${additionalData!['bookingData']['title']}",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                "Phone: ${additionalData!['bookingData']['phone']}",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                "Booking ID: ${additionalData!['bookingData']['booking_id']}",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  showScanner = true;
                  showSuccess = false;
                });
              },
              child: Text("Proceed"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 80),
            SizedBox(height: 20),
            Text(
              "Error: QR code not recognized.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  showScanner = true;
                  showError = false;
                });
              },
              child: Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}
