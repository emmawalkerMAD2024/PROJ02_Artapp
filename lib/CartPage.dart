import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CartPage extends StatelessWidget {
  final String currentUserId;

  CartPage({required this.currentUserId});

  Future<DocumentSnapshot> fetchCart() async {
    return FirebaseFirestore.instance.collection('carts').doc(currentUserId).get();
  }

  @override
  Widget build(BuildContext context) {

      

    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchCart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Your cart is empty."));
          }

          final cartData = snapshot.data!.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(cartData['items']);
          double total = items.fold(0, (sum, item) => sum + item['price']);

          double tax = total * 0.10; // 10% tax
          double totalWithTax = total + tax;


          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: Image.network(item['thumbnailUrl'], width: 150, height: 150),
                      title: Text(item['title'],style:TextStyle(fontSize: 20)),
                      subtitle: Text("\$${item['price'].toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('carts')
                              .doc(currentUserId) 
                              .update({
                            "items": FieldValue.arrayRemove([item]),
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                   Text("Tax: \$${tax.toStringAsFixed(2)}\nTotal (with tax): \$${totalWithTax.toStringAsFixed(2)}",style:TextStyle(fontSize: 18)),
                        ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutPage( artworkId: '',)),
                        );
                      },
                      child: Text("Checkout",style:TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


// Placeholder for Checkout Page
class CheckoutPage extends StatelessWidget {
  final String artworkId;

  CheckoutPage({required this.artworkId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Center(
        child: Text('Proceed to checkout for artwork ID: $artworkId'),
      ),
    );
  }
}
