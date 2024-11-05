import 'package:flutter/material.dart';
import 'package:graphixui/pages/login_page.dart';
import 'package:graphixui/pages/qr_scanner.dart';
import 'package:graphixui/pages/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Code Scanner App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/qr_scanner': (context) => QrScanner(),
      },
    );
  }
}
