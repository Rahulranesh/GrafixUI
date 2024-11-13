import 'package:flutter/material.dart';
import 'package:graphixui/models/ticket.dart';
import 'package:graphixui/services/ticket_service.dart';



class UpdateTicketPage extends StatefulWidget {
  final Ticket ticket;

  UpdateTicketPage({required this.ticket});

  @override
  _UpdateTicketPageState createState() => _UpdateTicketPageState();
}

class _UpdateTicketPageState extends State<UpdateTicketPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.ticket.name;
    descriptionController.text = widget.ticket.description;
    priceController.text = widget.ticket.price.toString();
  }

  void _updateTicket() async {
    bool result = await TicketService.updateTicket(
      widget.ticket.ticketId,
      nameController.text,
      descriptionController.text,
      double.parse(priceController.text),
    );
    if (result) {
      Navigator.pop(context);
    } else {
      // Handle failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Ticket Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateTicket,
              child: Text('Update Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}
