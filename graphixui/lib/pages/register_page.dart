import 'package:flutter/material.dart';
import 'package:graphixui/components/my_button.dart';
import 'package:graphixui/components/my_textfield.dart';
import 'package:graphixui/services/api_service.dart';
// Import the ApiService
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
  bool checkbox = false;
  String selectedRole = 'User';
  bool showPassword = false;

  final List<String> roles = ['User', 'Organizer', 'Admin'];
  final ApiService _apiService = ApiService(); // Instantiate ApiService

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

    try {
      // Call the register method from ApiService
      final response = await _apiService.register(
        firstNameController.text,
        lastNameController.text,
        usernameController.text,
        emailController.text,
        passwordController.text,
        selectedRole,
      );

      // If registration is successful, show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration successful!")),
      );
      Navigator.pop(context); // Navigate back to login page or main page
    } catch (e) {
      // Handle any errors during the registration request
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
            Text('Make your events visible by ticketverse',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 16),

            // Role Selection Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
