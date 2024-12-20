// signup_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SignUpPage extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String generateArtistId() {
    final Random random = Random();
    return List.generate(12, (index) => random.nextInt(10).toString()).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset('lib/assets/signupwelcome.png'),
              TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'First Name')),
              TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Last Name')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username')),
              TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
              TextField(controller: confirmPasswordController, obscureText: true, decoration: InputDecoration(labelText: 'Confirm Password')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match!')));
                  } else {
                    try {
                      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                     // String artistId = generateArtistId();
                      await FirebaseFirestore.instance.collection('artists').doc(usernameController.text).set({
                        'email': emailController.text,
                        'firstname': firstNameController.text,
                        'lastname': lastNameController.text,
                        'username': usernameController.text,
                        'password': passwordController.text,
                        'artistId': usernameController.text,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign up successful!')));
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
