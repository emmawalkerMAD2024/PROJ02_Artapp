import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CartPage.dart';
import 'Chatbox/ChatRoomPage.dart';

class DetailedArtworkPage extends StatelessWidget {
  final String artworkId;
  final String user;

  DetailedArtworkPage({required this.artworkId, required this.user});

  

  void addToCart(String userId, Map<String, dynamic> artwork, BuildContext context) async {
  try {
    final cartDoc = FirebaseFirestore.instance.collection('carts').doc(userId);
    DocumentSnapshot cartSnapshot = await cartDoc.get();

    if (cartSnapshot.exists) {
      // Check if the item already exists in the cart
      final data = cartSnapshot.data() as Map<String, dynamic>;
      List<dynamic> items = data['items'] ?? [];
      bool itemExists = items.any((item) => item['artworkId'] == artwork['artworkId']);

      if (itemExists) {
        // Show a notification if the item is already in the cart
           final snackBar = SnackBar( content: const Text("Item Already in Cart\nYou can't add the same item to your cart twice."),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return ;
      }

      // Add the new item to the cart
      await cartDoc.update({
        "items": FieldValue.arrayUnion([artwork]),
      });
    } else {
      // Create a new cart if it doesn't exist
      await cartDoc.set({
        "items": [artwork],
      });
    }

    // Show a success notification
    print("test");

    final snackBar = SnackBar( content: const Text("Added to Cart\nThe item has been added to your cart!"),
              action: SnackBarAction(
              label: 'View Cart',
              onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CartPage(currentUserId: userId),
              )
              );  // Navigate to the upload page
            },
            ),
          );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
  } catch (e) {
    print("Error adding to cart: $e");
    
  }
}


  Future<Map<String, dynamic>?> fetchArtworkData() async {

    final artworkDoc = await FirebaseFirestore.instance
        .collection('artworks')
        .doc(artworkId)
        .get();
  

    if (artworkDoc.exists) {

      final artworkData = artworkDoc.data()!;
      final artistId = artworkDoc['artistId'];

    
      // Fetch the artist data
      final artistQuery = await FirebaseFirestore.instance
          .collection('artists')
          .where('artistId', isEqualTo: artistId)
          .limit(1)
          .get();

      final artistName = artistQuery.docs.isNotEmpty
          ? (artistQuery.docs.first['firstname'] +" "+ artistQuery.docs.first['lastname'])
          : 'Unknown Artist';
       

      return {
        'title': artworkData['title'],
        'price': artworkData['price'],
        'imageUrl': artworkData['imageUrl'],
        'createdAt': artworkData['createdAt'],
        'availability': artworkData['availability'],
        'artistName': artistName,
        'artistId': artistId,
      };
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artwork Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchArtworkData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Artwork not found. $artworkId'));
          }

          final artwork = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Artwork Image
                Center(
                  child: Image.network(
                    artwork['imageUrl'],
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.image_not_supported,
                      size: 100,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Artwork Title
                Text(
                  artwork['title'],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                // Price
                Text(
                  'Price: \$${artwork['price'].toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18),
                ),

                

                // Availability
                Text(
                  'Availability: ${artwork['availability'] ? 'Available' : 'Sold Out'}',
                  style: TextStyle(
                    fontSize: 16,
                    color: artwork['availability'] ? Colors.green : Colors.red,
                  ),
                ),
                SizedBox(height: 16),

                // Artist Name
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ArtistProfilePage(artistId: artwork['artistId'], user: user,),
                      ),
                    );
                  },
                  child: Text(
                    'Artist: ${artwork['artistName']}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Spacer(),

                // Checkout Button
                ElevatedButton(
                  onPressed: artwork['availability'] ? ()  { final artworkData = {
                  "artworkId": artworkId,
                  "title": artwork['title'],
                  "price": artwork['price'],
                   "thumbnailUrl": artwork['imageUrl'],
                   };
                  addToCart(user, artworkData, context);
                  }: null, 
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(artwork['availability'] ?'Add to Cart' : 'Sold Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Placeholder for Artist Profile Page
class ArtistProfilePage extends StatelessWidget {
  final String artistId;
  final String user;

  ArtistProfilePage({required this.artistId, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artist Profile'),
      ),
      body: Center(
        child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                           ChatRoomPage(currentUserId: artistId, otherUserId: user,),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('chatbox'),
                ),
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
