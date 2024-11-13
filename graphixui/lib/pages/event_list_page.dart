import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graphixui/models/event.dart';
import 'package:graphixui/services/event_service.dart';

import 'add_event_page.dart';
import 'update_event_page.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    var eventData = await EventService.getEventList();
    if (eventData != null) {
      setState(() {
        events = eventData;
      });
    } else {
      Fluttertoast.showToast(msg: "Failed to load events.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Categories')),
      body: events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(events[index].eventTitle),
                  subtitle: Text(events[index].eventDescription),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      bool result = await EventService.deleteEvent(events[index].eventId);
                      if (result) {
                        Fluttertoast.showToast(msg: "Event deleted.");
                        _fetchEvents(); // Refresh list after delete
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateEventPage(eventId: events[index].eventId),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddEventPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
