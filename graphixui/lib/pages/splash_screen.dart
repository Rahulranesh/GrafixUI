import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphixui/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    Future.delayed(Duration(seconds: 2), () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/qr_scanner');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
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
