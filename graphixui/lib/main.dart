import 'package:flutter/material.dart';
import 'package:graphixui/models/ticket.dart';

import 'package:graphixui/pages/login_page.dart';
import 'package:graphixui/pages/qr_scanner.dart';
import 'package:graphixui/pages/register_page.dart';
import 'package:graphixui/pages/splash_screen.dart';


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
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/qr_scanner': (context) => PwaScanner(),
        
      },
      
    );
  }
}
