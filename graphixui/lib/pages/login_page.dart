import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphixui/components/my_button.dart';
import 'package:graphixui/components/my_textfield.dart';

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

  void onLogin() {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      // Implement your login logic here, use selectedRole as needed
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
        backgroundColor: const Color.fromARGB(255, 8, 5, 61), // AppBar color
        flexibleSpace: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo.png'), // Your logo path here
              // Ensure the image covers the area
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
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    borderRadius: BorderRadius.circular(18),
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
                      border: OutlineInputBorder(),
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
                    obscureText: true,
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
                            'assets/google.jpeg', // Your Google icon path here
                            height: 20, // Adjust icon size
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
                          icon: Icon(Icons.facebook,
                              color: Colors
                                  .white), // Placeholder for Facebook icon
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
                        // Navigate to the registration screen
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
