import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:graphixui/components/my_button.dart';
import 'package:graphixui/components/my_textfield.dart';
import 'package:graphixui/pages/qr_scanner.dart';
import 'package:graphixui/pages/register_page.dart';
import 'package:graphixui/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = false;
  bool isLoading = false; // Track loading state
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'Organizer'; // Default to 'Organizer'
  final ApiService apiService = ApiService();
  final Color navbarColor = const Color.fromARGB(255, 8, 5, 61);
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'], // Request email scope for Google Sign-In
  );

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> onLogin() async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      final roleEndpoints = {
        'Organizer': '${apiService.baseUrl}/auth/org/login',
        'Admin': '${apiService.baseUrl}/admin/login',
      };

      try {
        await apiService.login(
          usernameController.text,
          passwordController.text,
          roleEndpoints[selectedRole]!,
        );

        await saveSession(); // Save session after successful login

        // Smooth transition to the scanner page
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PwaScanner(), // Replace with your scanner page widget
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
          ),
        );
      } catch (e) {
        _showError("Login failed: $e");
      }
    } else {
      _showError("Please fill all the fields");
    }
  }

  Future<void> saveSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true); // Save login state
    await prefs.setString('username', usernameController.text); // Save username
  }

  Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    Navigator.pushReplacementNamed(context, '/login'); // Redirect to login page
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: navbarColor,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Image.asset(
              'assets/ticklogo_white.png',
              width: 200,
              height: 200,
            )),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
            .copyWith(top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            Text(
              'Login your Account ',
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: navbarColor),
            ),
            SizedBox(height: 5),
            Text(
              'Make your events visible by ticketverz',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: <String>['Organizer', 'Admin'] // Only these roles
                        .map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRole = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Select Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                MyTextField(
                  controller: usernameController,
                  hintText: "Username",
                  obscureText: false,
                ),
                SizedBox(height: 16),
                MyTextField(
                  controller: passwordController,
                  hintText: "Password",
                  obscureText: !showPassword,
                  suffixIcon: GestureDetector(
                    onTap: togglePasswordVisibility,
                    child: Icon(
                      showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(navbarColor),
                        ) // Show loading spinner while logging in
                      : ElevatedButton(
                          onPressed: onLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navbarColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            minimumSize: Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New User?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: navbarColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
