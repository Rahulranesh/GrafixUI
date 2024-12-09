import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphixui/pages/login_page.dart';
// Replace with your main app page

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Color navbarColor = const Color.fromARGB(255, 8, 5, 61); // Navbar color

  @override
  void initState() {
    super.initState();
    // Delay for the splash screen
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the main page after the delay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()), // Replace with your main page
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set the status bar color to match splash screen
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor:
          navbarColor, // Choose a background color that contrasts with your logo text
      body: Stack(
        children: [
          Container(
            color: Color.fromARGB(
                255, 8, 5, 61), // Set a light background color for contrast
          ),
          Center(
            child: Image.asset(
              'assets/ticklogo_white.png',
              width: 200,
              height: 200,
              // Optional overlay effect for logo
              colorBlendMode: BlendMode.srcATop,
            ),
          ),
        ],
      ),
    );
  }
}
