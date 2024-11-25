import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInPage extends StatefulWidget {
  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'], // Request email and profile data
  );

  bool isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() {
        isLoading = true; // Show loading spinner
      });

      // Attempt to sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // Get authentication details
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Extract ID Token and Access Token
        final String? idToken = googleAuth.idToken;
        final String? accessToken = googleAuth.accessToken;

        print("Google Sign-In successful!");
        print("ID Token: $idToken");
        print("Access Token: $accessToken");

        // Optionally display user details
        _showWelcomeMessage(googleUser.displayName, googleUser.email);
      } else {
        print("Google Sign-In was canceled.");
      }
    } catch (error) {
      _showErrorMessage("Error during Google Sign-In: $error");
    } finally {
      setState(() {
        isLoading = false; // Hide loading spinner
      });
    }
  }

  void _showWelcomeMessage(String? name, String? email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Welcome, $name! Email: $email"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Sign-In Example")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _handleGoogleSignIn,
                child: Text("Sign In with Google"),
              ),
      ),
    );
  }
}
