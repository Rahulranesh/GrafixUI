import 'package:flutter/material.dart';
import 'package:graphixui/services/ticket_service.dart';


class AddTicketPage extends StatefulWidget {
  final String eventId;

  AddTicketPage({required this.eventId});

  @override
  _AddTicketPageState createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  void _addTicket() async {
    bool result = await TicketService.addTicket(
      widget.eventId,
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
      appBar: AppBar(title: Text('Add Ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Ticket Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a ticket name' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addTicket();
                  }
                },
                child: Text('Add Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
