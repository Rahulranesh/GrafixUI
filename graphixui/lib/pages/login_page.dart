// login_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:graphixui/components/my_button.dart';
import 'package:graphixui/components/my_textfield.dart';
import 'package:graphixui/pages/register_page.dart';
import 'package:graphixui/services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'User';
  final ApiService apiService = ApiService(); // Initialize ApiService

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void togglePasswordVisibility() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  Future<void> onLogin() async {
    if (usernameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      final roleEndpoints = {
        'User': '${apiService.baseUrl}/auth/login',
        'Organizer': '${apiService.baseUrl}/auth/org/login',
        'Admin': '${apiService.baseUrl}/admin/login',
      };

      try {
        await apiService.login(
          usernameController.text,
          passwordController.text,
          roleEndpoints[selectedRole]!,
        );
        Navigator.pushNamed(context, '/qr_scanner');
      } catch (e) {
        _showError("Login failed: $e");
      }
    } else {
      _showError("Please fill all the fields");
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        await apiService.googleLogin(googleAuth.idToken!);
        Navigator.pushNamed(context, '/qr_scanner');
      }
    } catch (e) {
      _showError("Error during Google login: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
<<<<<<< HEAD
              image: AssetImage('assets/logo.png'),
=======
              image: AssetImage('assets/logo.png'), // Path to your logo image
              fit: BoxFit.contain,
>>>>>>> 9f25595862d6331dc2bb7d67851f02a3ddfdd37b
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: GoogleFonts.roboto(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
<<<<<<< HEAD
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: DropdownButtonFormField<String>(
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
                        borderRadius: BorderRadius.circular(10),
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
                        onPressed: _handleGoogleLogin,
                        icon: Image.asset(
                          'assets/google.jpeg',
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
                        onPressed: () {},
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
=======
            SizedBox(height: 20),

            // Role Selection Dropdown
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // Same radius
                ),
                child: DropdownButtonFormField<String>(
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
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15), 
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Match radius
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Input Fields
            MyTextField(
                controller: usernameController,
                hintText: "Username",
                obscureText: false),
            SizedBox(height: 20),
            MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: !showPassword),
            SizedBox(height: 8),
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

            // Login Button
            MyButton(onTap: onLogin, text: "Login"),
            SizedBox(height: 25),

            // Google and Facebook Login Options
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
>>>>>>> 9f25595862d6331dc2bb7d67851f02a3ddfdd37b
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Link to Register Page
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RegisterPage()),
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
    );
  }
}
