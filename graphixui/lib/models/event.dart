class Event {
  final String eventId;
  final String eventTitle;
  final String eventDescription;
  final String eventDate;
  final String eventLocation;

  Event({
    required this.eventId,
    required this.eventTitle,
    required this.eventDescription,
    required this.eventDate,
    required this.eventLocation,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['eventId'],
      eventTitle: json['title'],
      eventDescription: json['description'],
      eventDate: json['start_date'],
      eventLocation: json['location'],
    );
  }
}
