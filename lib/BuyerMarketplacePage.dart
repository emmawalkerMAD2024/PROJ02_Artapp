import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p2_artapp/Chatbox/ChatListPage.dart';
import 'ArtistWorksPage/ArtistWorksListedPage.dart';
import 'CartPage.dart';
import 'profile_dashboard_page.dart';
import 'main.dart';
import 'DetailedArtworkPage.dart';

class BuyerMarketplacePage extends StatefulWidget {
final String currentUser;

  BuyerMarketplacePage({required this.currentUser});

  @override
  _BuyerMarketplacePageState createState() => _BuyerMarketplacePageState(currentUser: currentUser);
}

class _BuyerMarketplacePageState extends State<BuyerMarketplacePage> {

  final String currentUser;

 _BuyerMarketplacePageState({required this.currentUser});

  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Cache to store artistId -> artistName mapping
  Map<String, String> _artistCache = {};

  Future<String> _getArtistName(String artistId) async {

  // Check if the artistName is already cached
  if (_artistCache.containsKey(artistId)) {
    return _artistCache[artistId]!;
  }

   try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('artists')
          .where('artistId', isEqualTo: artistId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final artistFName = querySnapshot.docs.first['firstname'] ?? 'Unknown';
      final artistLName = querySnapshot.docs.first['lastname'] ?? 'Unknown';
         _artistCache[artistId] = "$artistFName $artistLName";
        return "$artistFName $artistLName";
      } else {
        print('No artist found for artistId: $artistId');
      }
    } catch (error) {
      print('Error fetching artist name for artistId $artistId: $error');
    }

     return 'Unknown Artist';
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ArtLink Studio Marketplace'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('lib/assets/newgradient.jpg'),
                ),
              ),
              
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Profile Dashboard'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileDashboardPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.brush),
              title: Text('Your Artwork'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArtistWorksListedPage(artistId: currentUser )),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage(currentUserId: currentUser)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Messages'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListPage(currentUserId: currentUser)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Log Out'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by artwork name or artist',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('artworks')
                  .where('artistId', isNotEqualTo: currentUser)
                 // .where('availability', isEqualTo: true )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return Center(child: Text('(has not data) No artworks found. $currentUser'));
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No artworks found. $currentUser'));
                }

                final artworks = snapshot.data!.docs.where((doc) {
                  final title = (doc['title'] as String).toLowerCase();
                  final artistId = (doc['artistId']);
                  final matchesTitle = title.contains(_searchQuery);
                  final matchesArtist = _artistCache[artistId]?.toLowerCase().contains(_searchQuery) ?? false;
                  return matchesTitle || matchesArtist;
                }).toList();

                if (artworks.isEmpty) {
                  return Center(child: Text('No artworks match your search.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: artworks.length,
                  itemBuilder: (context, index) { 
                      final artwork = artworks[index];
                    return FutureBuilder<String>(
                      future: _getArtistName(artwork['artistId']),
                      builder: (context, artistSnapshot) {
                        if (artistSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final artistName = artistSnapshot.data ?? 'Unknown Artist';
                        return _buildArtworkCard(artwork, artistName);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkCard(QueryDocumentSnapshot artwork, String artistName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailedArtworkPage(artworkId: artwork.id, user: currentUser),
          ),
        );
      },
      child: Card(
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                artwork['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                artwork['title'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'By $artistName',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                artwork['availability'] ? '\$${artwork['price'].toStringAsFixed(2)}' : 'Sold Out',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: artwork['availability'] ? Colors.black : Colors.red
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
