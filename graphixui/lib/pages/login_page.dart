import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:graphixui/components/my_button.dart';
import 'package:graphixui/components/my_textfield.dart';
import 'package:graphixui/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'User'; // Default role

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> onLogin() async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      final response = await http.post(
        Uri.parse('https://mqnmrqvamm.us-east-1.awsapprunner.com/api/admin/login'), // Replace with your API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': usernameController.text,
          'password': passwordController.text,
          'role': selectedRole,
        }),
      );

      if (response.statusCode == 200) {
        // Successful login
        Navigator.pushNamed(context, '/qr_scanner'); // Navigate to QR Scanner
      } else {
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response.body}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all the fields")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 5, 61),
        flexibleSpace: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo.png'), // Path to your logo image
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              'Login ',
              style: GoogleFonts.roboto(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown for user role selection
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: <String>['User', 'Organizer', 'Admin']
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 25),
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
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: togglePasswordVisibility,
                        child: Text(
                          showPassword ? "Hide Password" : "Show Password",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: MyButton(onTap: onLogin, text: "Login"),
                  ),
                  SizedBox(height: 25),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Google login handler
                          },
                          icon: Image.asset(
                            'assets/google.jpeg', // Path to Google icon
                            height: 20,
                            width: 20,
                          ),
                          label: Text(
                            'Login with Google',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Facebook login handler
                          },
                          icon: Icon(Icons.facebook, color: Colors.white),
                          label: Text(
                            'Login with Facebook',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        'New User? Sign Up',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
