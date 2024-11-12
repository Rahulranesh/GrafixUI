import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingApi {
  static const baseUrl = 'https://mqnmrqvamm.us-east-1.awsapprunner.com/api';

  static Future<void> verifyQR({
    required String qrCodeData,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(String) onError,
  }) async {
    final url = Uri.parse('$baseUrl/api/bookings/verifyQrCode');
    final payload = {'qrCodeData': qrCodeData};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        onSuccess(data);
      } else {
        onError("QR Code verification failed.");
      }
    } catch (error) {
      onError("An error occurred: $error");
    }
  }
}
