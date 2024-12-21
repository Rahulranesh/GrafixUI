import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PwaScanner extends StatefulWidget {
  @override
  _PwaScannerState createState() => _PwaScannerState();
}

class _PwaScannerState extends State<PwaScanner> {
  final MobileScannerController scannerController = MobileScannerController();
  final storage = const FlutterSecureStorage();

  bool showScanner = true;
  bool showSuccess = false;
  bool showError = false;
  bool isTorchOn = false;
  Map<String, dynamic>? additionalData;

  final Color primaryColor = const Color.fromARGB(255, 8, 5, 61);

  @override
  void initState() {
    super.initState();
    _initializeCookie();
  }

  Future<void> _initializeCookie() async {
    final signature = await storage.read(key: 'Admin_Signature');
    if (signature == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in!')),
      );
    }
  }

  Future<String?> _getCookie() async {
    return await storage.read(key: "Admin_Signature");
  }

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
    final signature = await _getCookie();
    // Retrieve stored event ID

    if (signature == null) {
      setState(() {
        showError = true;
      });
      return;
    }

    final url =
        Uri.parse("https://api.ticketverz.com/api/bookings/verifyQrCode");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'Admin-Signature=$signature',
        },
        body: jsonEncode({
          'qrCodeData': qrData,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          setState(() {
            additionalData = data['bookingData']; // Store booking data
            showSuccess = true;
            showError = false;
          });
        } else {
          setState(() {
            showError = true;
            showSuccess = false;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        showError = true;
        showSuccess = false;
      });
    }
  }

  void resetScanner() {
    setState(() {
      showScanner = true;
      showError = false;
      showSuccess = false;
      additionalData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.purple.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: const Text(
                  "QR Code Scanner",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
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
              Expanded(
                child: Center(
                  child: showScanner
                      ? _buildScannerUI()
                      : showSuccess
                          ? _buildSuccessDialog()
                          : showError
                              ? _buildErrorDialog()
                              : Container(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScannerUI() {
    return Column(
      children: [
        const Text(
          "Please Scan Your Ticket Below",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 30),
        Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SizedBox(
            width: 300,
            height: 300,
            child: MobileScanner(
              controller: scannerController,
              onDetect: handleScan,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessDialog() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 60),
        const SizedBox(height: 10),
        const Text(
          "Access Granted!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (additionalData != null) ...[
          const SizedBox(height: 10),
          Text(
            "Event: ${additionalData!['title']}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            "Date: ${additionalData!['start_date_time']}",
            style: const TextStyle(fontSize: 16),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: resetScanner,
          child: const Text("Scan Another"),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        ),
      ],
    );
  }

  Widget _buildErrorDialog() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 60),
        const SizedBox(height: 10),
        const Text(
          "Error verifying QR Code!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: resetScanner,
          child: const Text("Try Again"),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        ),
      ],
    );
  }
}
