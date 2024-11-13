import 'dart:convert';
import 'package:graphixui/models/event.dart';
import 'package:http/http.dart' as http;
class EventService {
  static const String baseUrl = 'http://localhost:8080/api/org';

  static Future<List<Event>?> getEventList() async {
    final response = await http.get(Uri.parse('$baseUrl/getEventList'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'] as List;
      return data.map((event) => Event.fromJson(event)).toList();
    } else {
      return null;
    }
  }

  static Future<Event?> getEventDetails(String eventId) async {
    final response = await http.get(Uri.parse('$baseUrl/getEventById?event_id=$eventId'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'];
      return Event.fromJson(data);
    } else {
      return null;
    }
  }

  static Future<bool> addEvent(String title, String description, String date, String location) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addEvent'),
      body: {
        'title': title,
        'description': description,
        'start_date': date,
        'location': location,
      },
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateEvent(String eventId, String title, String description, String date, String location) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateEvent'),
      body: {
        'event_id': eventId,
        'title': title,
        'description': description,
        'start_date': date,
        'location': location,
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteEvent(String eventId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteEvent?event_id=$eventId'),
    );
    return response.statusCode == 200;
  }
}
