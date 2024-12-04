import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';





class ArtistWorksListedPage extends StatelessWidget {
  final String artistId; // Unique ID for the logged-in artist

  ArtistWorksListedPage({required this.artistId});

  // Helper method to delete artwork
  Future<void> deleteArtwork(String artworkId, String imageUrl) async {
    try {
      // Remove from Firestore
      await FirebaseFirestore.instance.collection('artworks').doc(artworkId).delete();
      // Remove from Firebase Storage
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      print('Artwork deleted successfully.');
    } catch (error) {
      print('Failed to delete artwork: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Artworks'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/uploadArtwork'); // Navigate to the upload page
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('artworks')
            .where('artistId', isEqualTo: artistId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No artworks listed yet.'));
          }

          final artworks = snapshot.data!.docs;

          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: artworks.length,
            itemBuilder: (context, index) {
              final artwork = artworks[index];
              final artworkId = artwork.id;
              final title = artwork['title'];
              final price = artwork['price'];
              final availability = artwork['availability'] ? 'Available' : 'Sold';
              final imageUrl = artwork['imageUrl'];

              return Card(
                elevation: 5,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${price.toString()}', style: TextStyle(color: Colors.green)),
                          Text(availability, style: TextStyle(color: availability == 'Available' ? Colors.blue : Colors.red)),
                        ],
                      ),
                    ),
                    OverflowBar(
                      alignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            Navigator.pushNamed(context, '/editArtwork', arguments: artworkId);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteArtwork(artworkId, imageUrl);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
