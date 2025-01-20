import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

final scanHistoryProvider =
    StateNotifierProvider<ScanHistoryNotifier, List<Map<String, dynamic>>>(
  (ref) => ScanHistoryNotifier(),
);

class ScanHistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ScanHistoryNotifier() : super([]);

  void addScanRecord(Map<String, dynamic> record) {
    state = [...state, record];
  }

  void clearHistory() {
    state = [];
  }

  void deleteRecord(int index) {
    state = [...state]..removeAt(index); // Removes item at the given index
  }
}

class ScanHistoryPage extends ConsumerWidget {
  const ScanHistoryPage({Key? key}) : super(key: key);

  // Helper function to format date strings into readable format
  String formatDate(String? dateString) {
    if (dateString == null) return "N/A";
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMMM dd, yyyy')
          .format(dateTime); // e.g., January 20, 2025
    } catch (e) {
      return "Invalid Date";
    }
  }

  // Helper function to format time strings into readable format
  String formatTime(String? timeString) {
    if (timeString == null) return "N/A";
    try {
      final dateTime = DateTime.parse(timeString);
      return DateFormat('hh:mm a').format(dateTime); // e.g., 02:30 PM
    } catch (e) {
      return "Invalid Time";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanHistory = ref.watch(scanHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scan History (${scanHistory.length})", // Display the count
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 14, 1, 63),
        actions: [
          if (scanHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(scanHistoryProvider.notifier).clearHistory();
              },
              tooltip: "Clear All History",
            ),
        ],
      ),
      body: scanHistory.isEmpty
          ? const Center(
              child: Text(
                "No scan history yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: scanHistory.length,
              itemBuilder: (context, index) {
                final item = scanHistory[index];
                final movieTitle =
                    item['details']?['title'] ?? 'Unknown Title'; // Movie title

                return Card(
                  color: const Color.fromARGB(255, 162, 170, 172),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      item['status'] == 'Success'
                          ? Icons.check_circle
                          : Icons.error,
                      color: item['status'] == 'Success'
                          ? Colors.green
                          : Colors.red,
                    ),
                    title: Text(movieTitle), // Display movie title
                    subtitle: Text("Status: ${item['status']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item['details'] != null)
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("QR Details"),
                                  content: Text(
                                    "Event: ${movieTitle}\n"
                                    "Booking ID: ${item['details']['booking_id']}\n"
                                    "First Name: ${item['details']['first_name']}\n"
                                    "Last Name: ${item['details']['last_name']}\n"
                                    "Event Date: ${formatDate(item['details']['event_date'])}\n"
                                    "Start Time: ${formatTime(item['details']['start_date_time'])}\n"
                                    "Quantity: ${item['details']['quantity']}",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Close"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            ref
                                .read(scanHistoryProvider.notifier)
                                .deleteRecord(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
