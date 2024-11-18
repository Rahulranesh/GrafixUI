import 'package:flutter/material.dart';
import 'package:graphixui/models/ticket.dart';
import 'package:graphixui/pages/add_event_page.dart';
import 'package:graphixui/pages/add_ticket_page.dart';
import 'package:graphixui/pages/event_list_page.dart';
import 'package:graphixui/pages/login_page.dart';
import 'package:graphixui/pages/qr_scanner.dart';
import 'package:graphixui/pages/register_page.dart';
import 'package:graphixui/pages/splash_screen.dart';

import 'package:graphixui/pages/ticket_list_page.dart';
import 'package:graphixui/pages/update_event_page.dart';
import 'package:graphixui/pages/update_ticket_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GraphixUI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/qr_scanner',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/qr_scanner': (context) => PwaScanner(),
        '/event/add': (context) => AddEventPage(),
        '/event/list': (context) => EventListPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/event/update') {
          final eventId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => UpdateEventPage(eventId: eventId!),
          );
        }
        if (settings.name == '/ticket/list') {
          final eventId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => TicketListPage(eventId: eventId!),
          );
        }
        if (settings.name == '/ticket/add') {
          final eventId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => AddTicketPage(eventId: eventId!),
          );
        }
        if (settings.name == '/ticket/update') {
          final ticket = settings.arguments as Ticket?;
          return MaterialPageRoute(
            builder: (context) => UpdateTicketPage(ticket: ticket!),
          );
        }

        return null; // Return null if the route is not defined
      },
    );
  }
}
