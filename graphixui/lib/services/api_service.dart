// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      'https://mqnmrqvamm.us-east-1.awsapprunner.com/api'; // Update to your base URL
  final String baseUrl2 = 'https://mqnmrqvamm.us-east-1.awsapprunner.com';

  Future<dynamic> login(
      String username, String password, String roleEndpoint) async {
    final response = await http.post(
      Uri.parse(roleEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<dynamic> googleLogin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
      }),
    );

    return _handleResponse(response);
  }

  Future<dynamic> facebookLogin(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl2/auth/facebook'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
      }),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      default:
        throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<dynamic> register(String firstName, String lastName, String username,
      String email, String password, String selectedRole) async {
    final roleEndpoints = {
      'User': '$baseUrl/auth/register',
      'Organizer': '$baseUrl/auth/org/register',
      'Admin': '$baseUrl/admin/register',
    };

    final String url = roleEndpoints[selectedRole]!;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'first_name': firstName,
          'last_name': lastName,
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body); // Return successful response
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during registration: $e');
    }
  }
}
