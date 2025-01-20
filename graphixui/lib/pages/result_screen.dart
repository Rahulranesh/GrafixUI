import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // Format date-time strings into readable formats
  String formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return "N/A";
    }
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      final String formattedDate = DateFormat('EEE, dd MMM').format(parsedDate);
      final String formattedTime = DateFormat('h:mm a').format(parsedDate);
      return '$formattedDate at $formattedTime';
    } catch (e) {
      return "N/A";
    }
  }

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) {
      return "N/A";
    }
    try {
      final DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('EEE, dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract booking data for convenience
    final bookingData = data['bookingData'] ?? {};

    // Format the dates
    final String formattedEventDate = formatDate(bookingData['event_date']);
    final String formattedStartDateTime =
        formatDateTime(bookingData['start_date_time']);

    return Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                isSuccess ? "Access Granted!" : "Access Denied!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      "Event Title:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      bookingData['title'] ?? "N/A",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    // Booking ID
                    Text(
                      "Booking ID:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      bookingData['booking_id'] ?? "N/A",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Name:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      bookingData['first_name'] ?? "N/A",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      bookingData['last_name'] ?? "N/A",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Event Date:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      formattedEventDate,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Start Time:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      formattedStartDateTime,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    // Quantity
                    Text(
                      "Quantity:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      bookingData['quantity']?.toString() ?? "N/A",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  onBack();
                  Navigator.pop(context);
                },
                label: const Text("Scan Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.blue : Colors.blue,
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
      ),
    );
  }
}
