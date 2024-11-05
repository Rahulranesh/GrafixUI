import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:graphixui/components/my_button.dart';
import 'package:graphixui/components/my_textfield.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'User';
  bool checkbox = false;
  bool showPassword = false;

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> onSubmit() async {
    if (!checkbox) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Please accept the terms and conditions"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Please fill all the fields"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      // Handle registration logic here
      final response = await http.post(
        Uri.parse('https://mqnmrqvamm.us-east-1.awsapprunner.com/api/admin/register'), // Replace with your API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
          'role': selectedRole,
        }),
      );

      if (response.statusCode == 201) {
        // Registration successful
        Navigator.pop(context); // Go back to login page or main page
      } else {
        // Handle error response
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Registration failed: ${response.body}"),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 5, 61),
        flexibleSpace: Container(
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/logo.png'), // Path to your logo image
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Create an Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text('Make your events visible by ticketverse',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),
            
            // Role Selection Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: DropdownButtonFormField<String>(
                value: selectedRole,
                items: <String>['User', 'Organizer', 'Admin'].map((String role) {
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
            ),
            SizedBox(height: 16),

            // Input Fields
            MyTextField(
                controller: firstNameController,
                hintText: "Firstname",
                obscureText: false),
            SizedBox(height: 16),
            MyTextField(
                controller: lastNameController,
                hintText: "Lastname",
                obscureText: false),
            SizedBox(height: 16),
            MyTextField(
                controller: usernameController,
                hintText: "Username",
                obscureText: false),
            SizedBox(height: 16),
            MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false),
            SizedBox(height: 16),
            MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: !showPassword),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: togglePasswordVisibility,
                  child: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Checkbox for Terms and Conditions
            Row(
              children: [
                Checkbox(
                  value: checkbox,
                  onChanged: (value) {
                    setState(() {
                      checkbox = value!;
                    });
                  },
                ),
                Expanded(
                  child: Text('I agree to terms & Policy.'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Register Button
            MyButton(onTap: onSubmit, text: "Register"),
            SizedBox(height: 20),

            // Login Option for Existing Users
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Already have an account? Login',
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
    );
  }
}
