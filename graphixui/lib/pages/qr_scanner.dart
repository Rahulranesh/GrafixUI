import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'scan_historypage.dart';

final pwaScannerProvider =
    ChangeNotifierProvider((ref) => PwaScannerNotifier(ref));

class PwaScannerNotifier extends ChangeNotifier {
  final MobileScannerController scannerController = MobileScannerController();
  final Ref ref;

  bool showScanner = true;
  bool isTorchOn = false;
  bool isLoading = false;
  Map<String, dynamic>? additionalData;
  bool showResult = false;

  PwaScannerNotifier(this.ref);

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  void toggleTorch() {
    isTorchOn = !isTorchOn;
    scannerController.toggleTorch();
    notifyListeners();
  }

  void handleScan(BarcodeCapture barcode, BuildContext context) {
    String? qrData =
        barcode.barcodes.isNotEmpty ? barcode.barcodes.first.rawValue : null;

    if (qrData != null && !isLoading) {
      isLoading = true;
      notifyListeners();
      verifyQR(qrData, context);
    }
  }

  Future<void> verifyQR(String qrData, BuildContext context) async {
    final url =
        Uri.parse("https://api.ticketverz.com/api/bookings/verifyQrCode");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qrCodeData': qrData}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        additionalData = data['bookingData'];

        ref.read(scanHistoryProvider.notifier).addScanRecord({
          'qrData': qrData,
          'status': data['valid'] == true ? 'Success' : 'Invalid',
          'details': additionalData,
        });

        showResult = true;
        notifyListeners();
      } else {
        ref.read(scanHistoryProvider.notifier).addScanRecord({
          'qrData': qrData,
          'status': 'Error',
          'details': null,
        });

        showResult = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Exception occurred: $e");
      ref.read(scanHistoryProvider.notifier).addScanRecord({
        'qrData': qrData,
        'status': 'Error',
        'details': null,
      });

      showResult = true;
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void resetScanner() {
    showScanner = true;
    additionalData = null;
    isLoading = false;
    showResult = false;
    notifyListeners();
  }
}

class PwaScanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(pwaScannerProvider);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SingleChildScrollView(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: const Color.fromARGB(255, 8, 1, 44),
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
                            builder: (_) => const ScanHistoryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                provider.showScanner
                    ? _buildScannerUI(provider, context)
                    : Container(),
                // Smooth transition for result popup
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  bottom: provider.showResult
                      ? 100
                      : -250, // Position result popup below scanner
                  left: 20,
                  right: 20,
                  child: provider.showResult
                      ? _buildResultPopup(provider)
                      : Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.grey,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildScannerUI(PwaScannerNotifier provider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Please Scan Your Ticket Below",
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: provider.isLoading ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Card(
              elevation: 15,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Curved edges for scanner
                side: const BorderSide(color: Colors.black, width: 2), // Black border
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height:
                    MediaQuery.of(context).size.width * 0.9, // Keep it square
                child: MobileScanner(
                  controller: provider.scannerController,
                  onDetect: (barcode) => provider.handleScan(barcode, context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPopup(PwaScannerNotifier provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              provider.additionalData != null
                  ? Icons.check_circle
                  : Icons.error,
              color:
                  provider.additionalData != null ? Colors.green : Colors.red,
              size: 80,
            ),
            const SizedBox(height: 15),
            Text(
              provider.additionalData != null
                  ? "Access Granted!"
                  : "Access Denied!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    provider.additionalData != null ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 15),
            if (provider.additionalData != null) ...[
              _buildDetailRow("Booking ID:",
                  provider.additionalData!['booking_id']?.toString() ?? "N/A"),
              _buildDetailRow("Quantity: ",
                  provider.additionalData!['quantity']?.toString() ?? "N/A"),
            ],
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                provider.resetScanner();
              },
              label: const Text("Scan Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
