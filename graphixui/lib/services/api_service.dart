import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/admin_login.dart';
import '../models/admin_register.dart';

class ApiService {
  final String baseUrl = 'https://mqnmrqvamm.us-east-1.awsapprunner.com/api'; // Update to your base URL

  Future<dynamic> login(AdminLogin loginData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(loginData.toJson()),
    );

    return _handleResponse(response);
  }

  Future<dynamic> register(AdminRegister registerData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registerData.toJson()),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 400:
      case 409:
      case 404:
      case 500:
      default:
        throw Exception(json.decode(response.body)['message']);
    }
  }
}
