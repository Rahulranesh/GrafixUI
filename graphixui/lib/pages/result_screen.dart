import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final bool isSuccess;
  final Map<String, dynamic> data;
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
      appBar: AppBar(
        title: Text(isSuccess ? "Success" : "Error"),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
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
              if (isSuccess) ...[
                const SizedBox(height: 10),
                Text(
                  "Event: ${data['title']}",
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  "Booking ID: ${data['booking_id']}",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  onBack();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Scanner"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
