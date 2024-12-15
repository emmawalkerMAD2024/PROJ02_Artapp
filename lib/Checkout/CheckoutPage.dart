import 'package:flutter/material.dart';
import 'ConfirmationScreen.dart';

class CheckoutPage extends StatefulWidget {
  final String currentUserId;
  final List<Map<String, dynamic>> cartItems; // Pass cart items

  CheckoutPage({required this.currentUserId, required this.cartItems});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _shippingController = TextEditingController();
  final _cardController = TextEditingController();

  @override
  void dispose() {
    _shippingController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Shipping Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _shippingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Shipping Address",
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Payment Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cardController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Card Information",
                hintText: "e.g., Visa **** 1234",
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_shippingController.text.isEmpty || _cardController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please fill in all fields."),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmationScreen(
                          currentUserId: widget.currentUserId,
                          cartItems: widget.cartItems, // Pass cart items
                        ),
                      ),
                    );
                  }
                },
                child: Text("Place Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
