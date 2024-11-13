import 'package:flutter/material.dart';
import 'package:graphixui/services/event_service.dart';

import 'package:fluttertoast/fluttertoast.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  void _addEvent() async {
    bool result = await EventService.addEvent(
      titleController.text,
      descriptionController.text,
      dateController.text,
      locationController.text,
    );
    if (result) {
      Fluttertoast.showToast(msg: "Event added successfully.");
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: "Failed to add event.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) => value!.isEmpty ? 'Please enter event title' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Event Description'),
                validator: (value) => value!.isEmpty ? 'Please enter event description' : null,
              ),
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Event Date'),
                validator: (value) => value!.isEmpty ? 'Please enter event date' : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Event Location'),
                validator: (value) => value!.isEmpty ? 'Please enter event location' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addEvent();
                  }
                },
                child: Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
