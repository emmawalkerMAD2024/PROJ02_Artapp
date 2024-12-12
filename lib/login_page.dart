import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'BuyerMarketplacePage.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset('lib/assets/loginwelcome.png'),
              TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username')),
              TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                        .collection('artists')
                        .where('username', isEqualTo: usernameController.text)
                        .where('password', isEqualTo: passwordController.text)
                        .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful!')));
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyerMarketplacePage()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid username or password')));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
