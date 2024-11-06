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
  bool checkbox = false; // For terms and conditions acceptance
  String selectedRole = 'User'; // Default selected role
  bool showPassword = false;

  // Roles options for registration
  final List<String> roles = ['User', 'Organizer', 'Admin'];

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> onSubmit() async {
    if (!checkbox) {
      _showErrorDialog("Please accept the terms and conditions");
      return;
    } else if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showErrorDialog("Please fill all the fields");
      return;
    }

    // Map of roles to corresponding API endpoints
    final roleEndpoints = {
      'User': 'https://yourapi.com/api/user/register',
      'Organizer': 'https://yourapi.com/api/organizer/register',
      'Admin':
          'https://mqnmrqvamm.us-east-1.awsapprunner.com/api/admin/register',
    };

    final String url = roleEndpoints[selectedRole]!;

    // Send the registration request
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registration successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration successful!")),
        );
        Navigator.pop(context); // Navigate back to login page or main page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${response.body}")),
        );
      }
    } catch (e) {
      // Handle any errors during the request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
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
              image: AssetImage('assets/logo.png'),
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
            Text(
              'Make your events visible by ticketverse',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),

            // Role Selection Dropdown
            Padding(
  padding: const EdgeInsets.all(20),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20), // Increase the radius for more circular edges
      
    ),
    child: DropdownButtonFormField<String>(
      value: selectedRole,
      items: roles.map((String role) {
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
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Optional for better padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20), // Ensure this matches the container's border radius
        ),
      ),
    ),
  ),
)
,
            SizedBox(height: 10),

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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),Text('Login',style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                    ),)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
