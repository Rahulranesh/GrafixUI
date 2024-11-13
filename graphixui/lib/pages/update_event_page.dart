import 'package:flutter/material.dart';
import 'package:graphixui/services/event_service.dart';

import 'package:fluttertoast/fluttertoast.dart';

class UpdateEventPage extends StatefulWidget {
  final String eventId;

  UpdateEventPage({required this.eventId});

  @override
  _UpdateEventPageState createState() => _UpdateEventPageState();
}

class _UpdateEventPageState extends State<UpdateEventPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    var event = await EventService.getEventDetails(widget.eventId);
    if (event != null) {
      setState(() {
        titleController.text = event.eventTitle;
        descriptionController.text = event.eventDescription;
        dateController.text = event.eventDate;
        locationController.text = event.eventLocation;
      });
    }
  }

  void _updateEvent() async {
    bool result = await EventService.updateEvent(
      widget.eventId,
      titleController.text,
      descriptionController.text,
      dateController.text,
      locationController.text,
    );
    if (result) {
      Fluttertoast.showToast(msg: "Event updated successfully.");
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: "Failed to update event.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Event Description'),
            ),
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Event Date'),
            ),
            TextField(
              controller: locationController,
              decoration: InputDecoration(labelText: 'Event Location'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateEvent,
              child: Text('Update Event'),
            ),
          ],
        ),
      ),
    );
  }
}
