import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final bool isSuccess;
  final Map<String, dynamic>? data;
  final VoidCallback onBack;

  const ResultPage({
    required this.isSuccess,
    required this.data,
    required this.onBack,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color.fromARGB(255, 93, 155, 196)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? Colors.green : Colors.red,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isSuccess ? "Access Granted!" : "Access Denied!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isSuccess && data != null) ...[
                      _buildDetailsRow('Event:', data!['title']),
                      _buildDetailsRow('Booking ID:', data!['booking_id']),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Back to Scanner"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess
                            ? const Color.fromARGB(255, 62, 80, 214)
                            : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30), // To fill empty space
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.withOpacity(0.3),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: Colors.blue,
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
