import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

// Provider Class to Manage State
// Provider Class to Manage State
class PwaScannerProvider extends ChangeNotifier {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final MobileScannerController scannerController = MobileScannerController();

  bool showScanner = true;
  bool showSuccess = false;
  bool showError = false;
  bool isTorchOn = false;
  bool isLoading = false;
  Map<String, dynamic>? additionalData;
  List<Map<String, dynamic>> scanHistory = [];

  final Color primaryColor = const Color.fromARGB(255, 62, 80, 214);

  PwaScannerProvider() {
    _initializeCookie();
    _loadScanHistory();
  }

  // Initialize the user signature
  Future<void> _initializeCookie() async {
    final signature = await storage.read(key: 'Admin_Signature');
    if (signature == null) {
      debugPrint('Please log in!');
    }
  }

  // Load scan history from secure storage
  Future<void> _loadScanHistory() async {
    final historyString = await storage.read(key: 'Scan_History');
    if (historyString != null) {
      scanHistory = List<Map<String, dynamic>>.from(jsonDecode(historyString));
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  // Save scan history to secure storage
  Future<void> _saveScanHistory() async {
    await storage.write(key: 'Scan_History', value: jsonEncode(scanHistory));
    notifyListeners(); // Notify listeners to update the UI
  }

  // Get stored cookie
  Future<String?> _getCookie() async {
    return await storage.read(key: "Admin_Signature");
  }

  // Toggle flashlight
  void toggleTorch() {
    isTorchOn = !isTorchOn;
    scannerController.toggleTorch();
    notifyListeners();
  }

  // Handle QR code scan
  void handleScan(BarcodeCapture barcode, BuildContext context) {
    String? qrData = barcode.barcodes.isNotEmpty ? barcode.barcodes.first.rawValue : null;

    if (qrData != null && !isLoading) {
      isLoading = true;
      notifyListeners();
      verifyQR(qrData, context);
    }
  }

  // Verify the QR code by calling an API
  Future<void> verifyQR(String qrData, BuildContext context) async {
    final signature = await _getCookie();

    if (signature == null) {
      showError = true;
      showSuccess = false;
      isLoading = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse("https://api.ticketverz.com/api/bookings/verifyQrCode");

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['valid'] == true) {
        if (data.containsKey('bookingData')) {
          additionalData = data['bookingData'];
          showSuccess = true;
          showError = false;

          scanHistory.add({
            'qrData': qrData,
            'status': 'Success',
            'details': additionalData,
          });

          await _saveScanHistory(); // Save the history after a successful scan

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                isSuccess: true,
                data: additionalData!,
                onBack: resetScanner,
              ),
            ),
          );
        } else {
          showError = true;
          showSuccess = false;
        }
      } else {
        showError = true;
        showSuccess = false;

        scanHistory.add({
          'qrData': qrData,
          'status': 'Error',
          'details': null,
        });

        await _saveScanHistory(); // Save history in case of error
      }
    } catch (e) {
      showError = true;
      showSuccess = false;

      scanHistory.add({
        'qrData': qrData,
        'status': 'Error',
        'details': null,
      });

      await _saveScanHistory(); // Save history in case of exception
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Reset scanner state
  void resetScanner() {
    showScanner = true;
    showError = false;
    showSuccess = false;
    additionalData = null;
    isLoading = false;
    notifyListeners();
  }
}

// Main Scanner Widget
class PwaScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PwaScannerProvider(),
      child: Scaffold(
        body: Consumer<PwaScannerProvider>(
          builder: (context, provider, child) {
            return Stack(
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
                            provider.isTorchOn
                                ? Icons.flash_off
                                : Icons.flash_on,
                            color: Colors.white,
                          ),
                          onPressed: provider.toggleTorch,
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
                                builder: (context) => ScanHistoryPage(),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildScannerUI(PwaScannerProvider provider, BuildContext context) {
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
              controller: provider.scannerController,
              onDetect: (barcode) => provider.handleScan(barcode, context),
            ),
          ),
        ),
      ],
    );
  }
}

// Result Page
class ResultPage extends StatelessWidget {
  final bool isSuccess;
  final Map<String, dynamic> data;
  final VoidCallback onBack;

  const ResultPage({
    required this.isSuccess,
    required this.data,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSuccess ? "Success" : "Error"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: isSuccess
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 80),
                    const SizedBox(height: 10),
                    Text(
                      "Access Granted! Event: ${data['title']}",
                      style: const TextStyle(fontSize: 22),
                    ),
                    Text("Booking ID: ${data['booking_id']}"),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 80),
                    const Text("Access Denied!"),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onBack();
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}

// Scan History Page
// Scan History Page
class ScanHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PwaScannerProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Scan History"),
            backgroundColor: Colors.white,
          ),
          body: provider.scanHistory.isEmpty
              ? const Center(
                  child: Text(
                    "No scan history yet.",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: provider.scanHistory.length,
                  itemBuilder: (context, index) {
                    final item = provider.scanHistory[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
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
                                          onPressed: () =>
                                              Navigator.pop(context),
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
      },
    );
  }
}
