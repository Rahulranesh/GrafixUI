import 'package:flutter/material.dart';
import 'package:graphixui/models/ticket.dart';
import 'package:graphixui/services/ticket_service.dart';

import 'add_ticket_page.dart';
import 'update_ticket_page.dart';

class TicketListPage extends StatefulWidget {
  final String eventId;

  TicketListPage({required this.eventId});

  @override
  _TicketListPageState createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  List<Ticket> tickets = [];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    var ticketData = await TicketService.getTicketList(widget.eventId);
    if (ticketData != null) {
      setState(() {
        tickets = ticketData;
      });
    } else {
      // Handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tickets')),
      body: tickets.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tickets[index].name),
                  subtitle: Text('Price: \$${tickets[index].price}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool result = await TicketService.deleteTicket(tickets[index].ticketId);
                      if (result) {
                        _fetchTickets();
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateTicketPage(ticket: tickets[index]),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTicketPage(eventId: widget.eventId)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
