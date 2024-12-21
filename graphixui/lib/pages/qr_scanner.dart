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

  final Color primaryColor = const Color(0xFF283593);
  List<Map<String, dynamic>> scanHistory = [];

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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          setState(() {
            additionalData = data['bookingData'];
            showSuccess = true;
            showError = false;
            scanHistory.add({
              'qrData': qrData,
              'status': 'Success',
              'details': additionalData,
            });
          });
        } else {
          setState(() {
            showError = true;
            showSuccess = false;
            scanHistory.add({
              'qrData': qrData,
              'status': 'Error',
              'details': null,
            });
          });
        }
      }
    } catch (e) {
      setState(() {
        showError = true;
        showSuccess = false;
        scanHistory.add({
          'qrData': qrData,
          'status': 'Error',
          'details': null,
        });
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 93, 155, 196), Colors.grey],
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
                    fontSize: 22,
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
                  IconButton(
                    icon: const Icon(
                      Icons.history,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanHistoryPage(scanHistory),
                        ),
                      );
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
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: SizedBox(
            width: 320,
            height: 320,
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
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 10),
        const Text(
          "Access Granted!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (additionalData != null) ...[
          const SizedBox(height: 10),
          Text(
            "Event: ${additionalData!['title']}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 5),
          Text(
            "Booking ID: ${additionalData!['booking_id']}",
            style: const TextStyle(fontSize: 18),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: resetScanner,
          child: const Text("Scan Another"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDialog() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 80),
        const SizedBox(height: 10),
        const Text(
          "Error verifying QR Code!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: resetScanner,
          child: const Text("Try Again"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

class ScanHistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> scanHistory;

  ScanHistoryPage(this.scanHistory);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan History"),
        backgroundColor: Colors.white,
      ),
      body: scanHistory.isEmpty
          ? const Center(
              child: Text(
                "No scan history yet.",
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: scanHistory.length,
              itemBuilder: (context, index) {
                final item = scanHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      item['status'] == 'Success'
                          ? Icons.check_circle
                          : Icons.error,
                      color: item['status'] == 'Success'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text("QR Data: ${item['qrData']}"),
                    subtitle: Text("Status: ${item['status']}"),
                    trailing: item['details'] != null
                        ? IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("QR Details"),
                                  content: Text(
                                      "Event: ${item['details']['title']}\nBooking ID: ${item['details']['booking_id']}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
