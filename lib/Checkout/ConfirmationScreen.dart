import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../BuyerMarketplacePage.dart';

class ConfirmationScreen extends StatelessWidget {
  final String currentUserId;
  final List<Map<String, dynamic>> cartItems; // Receive cart items

  ConfirmationScreen({required this.currentUserId, required this.cartItems});

  Future<String> _getUserEmail(String currentUserId) async {
    try {
      // Query the users collection where the artistId matches currentUserId
      final querySnapshot = await FirebaseFirestore.instance
          .collection('artists')
          .where('artistId', isEqualTo: currentUserId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first.data();
        return userDoc['email'] ?? "Unknown";
      } else {
        return "Email not found";
      }
    } catch (e) {
      return "Error retrieving email";
    }
  }

  Future<void> _updateArtworkAvailability() async {
    try {
      for (var item in cartItems) {
        final artworkId = item['title'];
        print("this is the id = $artworkId");
        await FirebaseFirestore.instance
            .collection('artworks')
            .doc(artworkId)
            .update({'availability': false});
      }
    } catch (e) {
      print("Error updating artwork availability: $e");
    }
  }

    Future<void> _clearCart() async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUserId)
          .update({'items': []});
    } catch (e) {
      print("Error clearing cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final confirmationNumber = random.nextInt(900000) + 100000; // Random 6-digit number

     // Update availability and clear the cart after checkout
    _updateArtworkAvailability();
    _clearCart();

    return FutureBuilder<String>(
      future: _getUserEmail(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Order Confirmation"),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Order Confirmation"),
            ),
            body: Center(
              child: Text(
                "Error: Could not retrieve email",
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          );
        }

        final email = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text("Order Confirmation"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Order Placed!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  "Confirmation Number: $confirmationNumber",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
                Text(
                  "Email sent to: $email",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyerMarketplacePage(currentUser:currentUserId)),
                      );
                  },
                  child: Text("Return to Home"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
