import 'package:flutter/material.dart';
import 'package:graphixui/pages/login_page.dart';
import 'package:graphixui/pages/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterPage(),
    );
  }
}
