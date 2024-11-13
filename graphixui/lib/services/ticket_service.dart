import 'dart:convert';
import 'package:graphixui/models/ticket.dart';
import 'package:http/http.dart' as http;


class TicketService {
  static const String baseUrl = 'http://localhost:8080/api/org';

  static Future<List<Ticket>?> getTicketList(String eventId) async {
    final response = await http.get(Uri.parse('$baseUrl/getTicketList?event_id=$eventId'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body)['data'] as List;
      return data.map((ticket) => Ticket.fromJson(ticket)).toList();
    } else {
      return null;
    }
  }

  static Future<bool> addTicket(String eventId, String name, String description, double price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addTicket'),
      body: {
        'event_id': eventId,
        'name': name,
        'description': description,
        'price': price.toString(),
      },
    );
    return response.statusCode == 201;
  }

  static Future<bool> updateTicket(String ticketId, String name, String description, double price) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateTicket'),
      body: {
        'ticket_id': ticketId,
        'name': name,
        'description': description,
        'price': price.toString(),
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteTicket(String ticketId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/deleteTicket?ticket_id=$ticketId'),
    );
    return response.statusCode == 200;
  }
}
