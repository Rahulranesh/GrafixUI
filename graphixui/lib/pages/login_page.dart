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
  bool isLoading = false; // Track loading state
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedRole = 'User';
  final ApiService apiService = ApiService();
  final Color navbarColor = const Color.fromARGB(255, 8, 5, 61);
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

      setState(() {
        isLoading = true; // Show loading spinner
      });

      try {
        await apiService.login(
          usernameController.text,
          passwordController.text,
          roleEndpoints[selectedRole]!,
        );
        Navigator.pushNamed(context, '/qr_scanner');
      } catch (e) {
        _showError("Login failed: $e");
      } finally {
        setState(() {
          isLoading = false; // Hide loading spinner
        });
      }
    } else {
      _showError("Please fill all the fields");
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      setState(() {
        isLoading = true; // Show loading spinner
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        await apiService.googleLogin(googleAuth.idToken!);
        Navigator.pushNamed(context, '/qr_scanner');
      }
    } catch (e) {
      _showError("Error during Google login: $e");
    } finally {
      setState(() {
        isLoading = false; // Hide loading spinner
      });
    }
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
                'assets/logo.png',
                height: 80,
                width: double.infinity,
              ),
            ),
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
              'Make your events visible by ticketverse',
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
                SizedBox(height: 16),
                // Google Login Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(navbarColor),
                        )
                      : ElevatedButton.icon(
                          onPressed: _handleGoogleLogin,
                          icon: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              'assets/google.jpeg',
                              height: 20,
                              width: 20,
                            ),
                          ),
                          label: Text(
                            'Login with Google',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navbarColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            minimumSize: Size.fromHeight(50),
                          ),
                        ),
                ),
                SizedBox(height: 10),
                // Facebook Login Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(navbarColor),
                        )
                      : ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.facebook, color: Colors.white),
                          label: Text(
                            'Login with Facebook',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navbarColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            minimumSize: Size.fromHeight(50),
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
