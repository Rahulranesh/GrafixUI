import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanHistoryPage extends ConsumerWidget {
  const ScanHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanHistory = ref.watch(scanHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan History"),
        backgroundColor: Colors.blueAccent,
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
                return Card(
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

// A provider for managing scan history
final scanHistoryProvider =
    StateNotifierProvider<ScanHistoryNotifier, List<Map<String, dynamic>>>(
  (ref) => ScanHistoryNotifier(),
);

/// StateNotifier for managing the scan history
class ScanHistoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ScanHistoryNotifier() : super([]);

  /// Adds a new scan record to the history
  void addScanRecord(Map<String, dynamic> record) {
    state = [...state, record];
  }

  /// Clears the entire scan history
  void clearHistory() {
    state = [];
  }
}
