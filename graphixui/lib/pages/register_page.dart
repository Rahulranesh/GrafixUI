import 'package:flutter/material.dart';
import 'package:graphixui/components/my_button.dart';
import 'package:graphixui/components/my_textfield.dart';

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

  void onSubmit() {
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
      // Handle registration logic
      print("Registering...");
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
              image: AssetImage('assets/logo.png'),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Wrap the Column in a SingleChildScrollView
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
            DropdownButtonFormField<String>(
              padding: EdgeInsets.symmetric(horizontal: 25),
              borderRadius: BorderRadius.circular(18),
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
            SizedBox(height: 16),
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
                obscureText: !showPassword), // Show password conditionally
            SizedBox(height: 16),
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
            MyButton(
                onTap: onSubmit,
                text:
                    "Register") // Ensure the button calls the onSubmit function
          ],
        ),
      ),
    );
  }
}
