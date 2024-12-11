import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = 'https://api.ticketverz.com/api';
  final String baseUrl2 = 'https://mqnmrqvamm.us-east-1.awsapprunner.com';
  final storage = const FlutterSecureStorage();

  Future<dynamic> login(
      String username, String password, String roleEndpoint) async {
    final response = await http.post(
      Uri.parse(roleEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    print('Login Response: ${response.body}'); // Debug: Print the response body
    print('Headers: ${response.headers}'); // Debug: Print the response headers

    final data = _handleResponse(response);

    if (response.headers.containsKey('set-cookie')) {
      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        final signature =
            RegExp(r'Admin-Signature=([^;]+)').firstMatch(cookies)?.group(1);
        if (signature != null) {
          await storage.write(key: 'Admin_Signature', value: signature);
          print('Admin-Signature saved: $signature'); // Debug
        }
      }
    }
    return data;
  }

  Future<dynamic> googleLogin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
      }),
    );

    return _handleResponse(response);
  }

  Future<dynamic> facebookLogin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/facebook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );

    final data = _handleResponse(response);

    // Save Admin Signature if provided in login response
    if (data != null && data['Admin-Signature'] != null) {
      await storage.write(
          key: 'Admin_Signature', value: data['Admin-Signature']);
    }

    return data;
  }

  Future<String?> getAdminSignature() async {
    return await storage.read(key: 'Admin_Signature');
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      default:
        throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<dynamic> register(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
    String selectedRole, {
    String? name,
  }) async {
    final roleEndpoints = {
      'Organizer': '$baseUrl/auth/org/register',
      'Admin': '$baseUrl/admin/register',
    };

    final String url = roleEndpoints[selectedRole]!;

    try {
      Map<String, dynamic> body = {
        'username': username,
        'email': email,
        'password': password,
      };

      if (selectedRole == 'Organizer' && name != null) {
        body['name'] = name;
      } else {
        body['first_name'] = firstName;
        body['last_name'] = lastName;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }
}
