
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';

class PwaScanner extends StatefulWidget {
  @override
  _PwaScannerState createState() => _PwaScannerState();
}

class _PwaScannerState extends State<PwaScanner> with SingleTickerProviderStateMixin {
  final MobileScannerController scannerController = MobileScannerController();
  final storage = const FlutterSecureStorage();

  bool showScanner = true;
  bool showSuccess = false;
  bool showError = false;
  bool isTorchOn = false;
  Map<String, dynamic>? additionalData;

  final Color primaryColor = const Color.fromARGB(255, 8, 5, 61);

  // For snow animation
  late AnimationController _animationController;
  late List<Snowflake> _snowflakes;

  @override
  void initState() {
    super.initState();
    _initializeCookie();
    _initializeSnowfall();
  }

  Future<void> _initializeCookie() async {
    final signature = await storage.read(key: 'attendee_signature');
    if (signature == null) {
      print("No attendee signature found. User not logged in.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in !')),
        );
      }
    }
  }

  Future<String?> _getCookie() async {
    return await storage.read(key: "attendee_signature");
  }

  void _initializeSnowfall() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _snowflakes = List.generate(
      100,
      (index) => Snowflake(
        Random().nextDouble() * MediaQuery.of(context).size.width,
        Random().nextDouble() * MediaQuery.of(context).size.height,
        Random().nextDouble() * 2 + 1,
      ),
    );
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
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'Attendee-Signature=$signature',
      },
      body: jsonEncode({'qrCodeData': qrData}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['valid'] == true) {
        setState(() {
          additionalData = data['bookingData'];
          showSuccess = true;
          showError = false;
        });
      } else {
        setState(() {
          showError = true;
          showSuccess = false;
        });
      }
    } else {
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
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.purple.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Snow Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: SnowPainter(_snowflakes, _animationController.value),
              );
            },
          ),

          // Main Content
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
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
        Text(
          "Please Scan Your Ticket Below",
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 30),
        Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 300,
            height: 300,
            child: MobileScanner(
              controller: scannerController,
              onDetect: handleScan,
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Align the QR Code within the frame",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessDialog() {
    if (additionalData == null) return Container();

    return Card(
      elevation: 10,
      margin: EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text(
              "QR Code Verified Successfully!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              "Event: ${additionalData?['title'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Date: ${additionalData?['start_date_time'] ?? 'N/A'}",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetScanner,
              child: Text("Scan Another Ticket"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDialog() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Colors.red, size: 60),
        SizedBox(height: 10),
        Text(
          "Error verifying QR Code!",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: resetScanner,
          child: Text("Try Again"),
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        ),
      ],
    );
  }
}

class Snowflake {
  double x, y, speed;

  Snowflake(this.x, this.y, this.speed);

  void update(double value, double height) {
    y += speed * value * 200;
    if (y > height) {
      y = -10;
    }
  }
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;
  final double value;

  SnowPainter(this.snowflakes, this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var snowflake in snowflakes) {
      canvas.drawCircle(Offset(snowflake.x, snowflake.y), 3, paint);
      snowflake.update(value, size.height);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}