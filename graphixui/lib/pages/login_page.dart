import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:graphixui/components/my_button.dart';
import 'package:graphixui/components/my_textfield.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  //log-in

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //logo
          Icon(
            Icons.lock_open_rounded,
            size: 100,
            color: Colors.grey.shade400,
          ),
          SizedBox(
            height: 15,
          ),
          Text('Welcome Back ! You"ve been missed !'),
          SizedBox(
            height: 25,
          ),

          //welcome msg
          Text(
            'TicketVerse',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(
            height: 25,
          ),

          //email
          MyTextField(
              controller: emailController,
              hintText: 'Enter the email',
              obscureText: false),
          SizedBox(
            height: 10,
          ),

          //password
          MyTextField(
              controller: passwordController,
              hintText: 'Enter the password',
              obscureText: true),
          SizedBox(
            height: 15,
          ),

          //sign-in
          MyButton(onTap: () => () {}, text: 'Sign-In'),

          SizedBox(
            height: 25,
          ),

          //register
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Not a member ? ',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              GestureDetector(
                onTap: widget.onTap,
                child: Text(
                  'Register now ',
                  style: TextStyle(
                      color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
