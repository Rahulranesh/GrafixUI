import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphixui/pages/result_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'scan_historypage.dart';

final pwaScannerProvider =
    ChangeNotifierProvider((ref) => PwaScannerNotifier(ref));

class PwaScannerNotifier extends ChangeNotifier {
  final MobileScannerController scannerController = MobileScannerController();
  final Ref ref;

  bool showScanner = true;
  bool isTorchOn = false;
  bool isLoading = false; // New flag to prevent duplicate scans
  Map<String, dynamic>? additionalData;

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
    // Ensure only one scan is processed at a time
    if (isLoading) return;

    // Get the scanned data
    String? qrData =
        barcode.barcodes.isNotEmpty ? barcode.barcodes.first.rawValue : null;

    if (qrData != null) {
      isLoading = true; // Block further scans
      notifyListeners();

      // Process the QR code data
      verifyQR(qrData, context);
    }
  }

   Future<void> verifyQR(String qrData, BuildContext context) async {
  final url = Uri.parse("https://api.ticketverz.com/api/bookings/verifyQrCode");

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'qrCodeData': qrData}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      additionalData = data['bookingData'];

      debugPrint("Booking Data: ${additionalData.toString()}");

      ref.read(scanHistoryProvider.notifier).addScanRecord({
        'qrData': qrData,
        'status': data['valid'] == true ? 'Success' : 'Invalid',
        'details': additionalData,
      });

      _navigateToResultPage(
        context,
        ResultPage(
          isSuccess: data['valid'] == true,
          data: additionalData != null
              ? {'bookingData': additionalData}
              : {'bookingData': {}},
          onBack: resetScanner,
        ),
      );
    } else {
      handleError(qrData, context);
    }
  } catch (e) {
    debugPrint("Exception occurred: $e");
    handleError(qrData, context);
  }
}

void handleError(String qrData, BuildContext context) {
  ref.read(scanHistoryProvider.notifier).addScanRecord({
    'qrData': qrData,
    'status': 'Error',
    'details': null,
  });

  _navigateToResultPage(
    context,
    ResultPage(
      isSuccess: false,
      data: {'bookingData': {}}, // Pass an empty map on error
      onBack: resetScanner,
    ),
  );
}


  void _navigateToResultPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide in from the right
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    ).then((_) => resetScanner()); // Reset scanner on returning to the scanner
  }

  void resetScanner() {
    showScanner = true;
    additionalData = null;
    isLoading = false; // Allow new scans
    notifyListeners();
  }
}

class PwaScanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> checkAuth() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (!isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }

    checkAuth();
    final provider = ref.watch(pwaScannerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 1, 63),
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
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              provider.isTorchOn ? Icons.flash_off : Icons.flash_on,
              color: Colors.white,
            ),
            onPressed: provider.toggleTorch,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 14, 1, 63),
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Scan History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScanHistoryPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                provider.showScanner
                    ? _buildScannerUI(provider, context)
                    : Container(),
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
          colors: [Color.fromARGB(255, 227, 228, 230), Colors.grey],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildScannerUI(PwaScannerNotifier provider, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              "Please Scan Your Ticket Below",
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 15,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    child: MobileScanner(
                      controller: provider.scannerController,
                      onDetect: (barcode) =>
                          provider.handleScan(barcode, context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
