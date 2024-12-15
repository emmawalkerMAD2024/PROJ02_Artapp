import 'package:flutter/material.dart';
import 'Checkout/CheckoutPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  final String currentUserId;

  CartPage({required this.currentUserId});

  Future<List<Map<String, dynamic>>> _getCartItems() async {
    try {
      final cartSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(currentUserId)
          .get();

      if (cartSnapshot.exists) {
        final data = cartSnapshot.data();
        List<dynamic> items = data?['items'] ?? [];
        return items.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching cart items: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getCartItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Your cart is empty.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final cartItems = snapshot.data!;

          double totalPrice = cartItems.fold(
            0.0,
            (sum, item) => sum + (item['price'] ?? 0.0),
          );

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: item['imageUrl'] != null
                              ? Image.network(
                                  item['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Icon(Icons.image, size: 50),
                          title: Text(item['title'] ?? "Untitled"),
                          subtitle: Text("Price: \$${item['price'] ?? 0.0}"),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Total: \$${totalPrice.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          currentUserId: currentUserId,
                          cartItems: cartItems, // Pass the cart items here
                        ),
                      ),
                    );
                  },
                  child: Text("Checkout"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
