import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DetailedArtworkPage.dart';
import 'Chatbox/ChatRoomPage.dart';

class ArtistProfilePage extends StatelessWidget {
  final String artistId;
  final String currentUserId;

  ArtistProfilePage({required this.artistId, required this.currentUserId});

  Future<Map<String, dynamic>?> fetchArtistData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('artists')
          .where('artistId', isEqualTo: artistId)
          .limit(1)
          .get();

         // print("this is the id $artistId");

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching artist data: $e");
      return null;
    }
  }

  Stream<QuerySnapshot> fetchArtListings() {
    return FirebaseFirestore.instance
        .collection('artworks')
        .where('artistId', isEqualTo: artistId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artist Profile'),
       
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchArtistData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Artist not found.'));
          }

          final artistData = snapshot.data!;
          final artistName = "${artistData['firstname']} ${artistData['lastname']}";
          final bio = artistData['bio'] ?? "This artist hasn't added a bio yet.";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Artist Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: artistData['profilePicture'] != null
                          ? NetworkImage(artistData['profilePicture'])
                          : null,
                      child: artistData['profilePicture'] == null
                          ? Icon(Icons.person, size: 40)
                          : null,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        artistName,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                  // Artist Bio
                Text(
                  "Bio",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  bio,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),

                // Art Listings Title
                Text(
                  "Art Listings",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),

                // Art Listings
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: fetchArtListings(),
                    builder: (context, artSnapshot) {
                      if (artSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!artSnapshot.hasData || artSnapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No artworks available."));
                      }

                      final artListings = artSnapshot.data!.docs;

                      return ListView.builder(
                        itemCount: artListings.length,
                        itemBuilder: (context, index) {
                          final artwork = artListings[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            child: ListTile(
                              leading: artwork['imageUrl'] != null
                                  ? Image.network(
                                      artwork['imageUrl'],
                                      width: 100,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.image, size: 50),
                              title: Text(artwork['title'] ?? "Untitled"),
                              subtitle: Text(artwork['availability'] ? "\$${artwork['price'] ?? 0.0}" : "Sold",
                              style: TextStyle(color:  artwork['availability'] ? Colors.black : Colors.red),),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailedArtworkPage(
                                      artworkId: artwork.id,
                                      user: currentUserId,
                                      userName: artistName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),

                // Chat Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(
                            currentUserId: currentUserId,
                            otherUserId: artistId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("Chat with $artistName"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
