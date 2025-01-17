// Import necessary packages
import 'package:flutter/material.dart';
import 'package:graphixui/pages/result_screen.dart';
import 'package:graphixui/pages/scan_historypage.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pwaScannerProvider =
    ChangeNotifierProvider((ref) => PwaScannerNotifier());

// Provider Notifier Class
class PwaScannerNotifier extends ChangeNotifier {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final MobileScannerController scannerController = MobileScannerController();

  bool showScanner = true;
  bool isTorchOn = false;
  bool isLoading = false;
  List<Map<String, dynamic>> scanHistory = [];
  Map<String, dynamic>? additionalData;

  PwaScannerNotifier() {
    _initializeCookie();
    _loadScanHistory();
  }

  // Initialize Admin Cookie
  Future<void> _initializeCookie() async {
    final signature = await storage.read(key: 'Admin_Signature');
    if (signature == null) {
      debugPrint('Please log in!');
    }
  }

  // Load scan history from storage
  Future<void> _loadScanHistory() async {
    final historyString = await storage.read(key: 'Scan_History');
    if (historyString != null) {
      scanHistory = List<Map<String, dynamic>>.from(jsonDecode(historyString));
    }
    notifyListeners();
  }

  // Save scan history to storage
  Future<void> _saveScanHistory() async {
    await storage.write(key: 'Scan_History', value: jsonEncode(scanHistory));
    notifyListeners();
  }

  // Toggle Flashlight
  void toggleTorch() {
    isTorchOn = !isTorchOn;
    scannerController.toggleTorch();
    notifyListeners();
  }

  // Handle QR Code Scan
  void handleScan(BarcodeCapture barcode, BuildContext context) {
    String? qrData =
        barcode.barcodes.isNotEmpty ? barcode.barcodes.first.rawValue : null;

    if (qrData != null && !isLoading) {
      isLoading = true;
      notifyListeners();
      verifyQR(qrData, context);
    }
  }

  // Verify the QR Code
  Future<void> verifyQR(String qrData, BuildContext context) async {
    final signature = await storage.read(key: "Admin_Signature");
    if (signature == null) {
      showErrorDialog(
          context, "Authentication Error", "Please log in as an admin.");
      isLoading = false;
      notifyListeners();
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
        body: jsonEncode({'qrCodeData': qrData}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['valid'] == true) {
        additionalData = data['bookingData'];
        scanHistory.add(
            {'qrData': qrData, 'status': 'Success', 'details': additionalData});
        await _saveScanHistory();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              isSuccess: true,
              data: additionalData!,
              onBack: resetScanner,
            ),
          ),
        );
      } else {
        scanHistory.add({'qrData': qrData, 'status': 'Error', 'details': null});
        await _saveScanHistory();
        showErrorDialog(
            context, "Invalid QR Code", "The scanned QR code is not valid.");
      }
    } catch (e) {
      scanHistory.add({'qrData': qrData, 'status': 'Error', 'details': null});
      await _saveScanHistory();
      showErrorDialog(context, "Network Error",
          "Unable to verify the QR code. Please try again.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Reset Scanner State
  void resetScanner() {
    showScanner = true;
    additionalData = null;
    isLoading = false;
    notifyListeners();
  }

  // Show Error Dialog
  void showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}

// Main Scanner Widget
class PwaScanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(pwaScannerProvider);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
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
                      provider.isTorchOn ? Icons.flash_off : Icons.flash_on,
                      color: Colors.white,
                    ),
                    onPressed: provider.toggleTorch,
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanHistoryPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: provider.isLoading
                      ? const CircularProgressIndicator()
                      : provider.showScanner
                          ? _buildScannerUI(provider, context)
                          : Container(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 93, 155, 196), Colors.grey],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildScannerUI(PwaScannerNotifier provider, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        const Text(
          "Please Scan Your Ticket Below",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 80),
        AnimatedOpacity(
          opacity: provider.isLoading ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Card(
            elevation: 15,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: SizedBox(
              width: 320,
              height: 320,
              child: MobileScanner(
                controller: provider.scannerController,
                onDetect: (barcode) => provider.handleScan(barcode, context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
