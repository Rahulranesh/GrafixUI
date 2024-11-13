class Ticket {
  final String ticketId;
  final String name;
  final String description;
  final double price;

  Ticket({
    required this.ticketId,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
    );
  }
}
