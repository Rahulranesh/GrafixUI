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
  Map<String, dynamic>? additionalData;

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
        'Cookie':
            'Admin-Signature=ce55f33243', // Only include the Admin-Signature cookie value
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
      print("API Error: ${response.body}");
      setState(() {
        showError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PWA Scanner")),
      body: Center(
        child: showScanner
            ? MobileScanner(onDetect: handleScan)
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
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text("Access Granted!"),
            if (additionalData != null) ...[
              Text("Type Name: ${additionalData!['bookingData']['title']}"),
              Text("Phone: ${additionalData!['bookingData']['phone']}"),
              Text(
                  "Booking ID: ${additionalData!['bookingData']['booking_id']}"),
            ],
            ElevatedButton(
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
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 80),
            SizedBox(height: 20),
            Text("Error: QR code not recognized."),
            ElevatedButton(
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
