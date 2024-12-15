import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDashboardPage extends StatefulWidget {
  final String userId;

  ProfileDashboardPage({required this.userId});

  @override
  _ProfileDashboardPageState createState() => _ProfileDashboardPageState();
}

class _ProfileDashboardPageState extends State<ProfileDashboardPage> {
  final _bioController = TextEditingController();
  final _profilePictureController = TextEditingController();
  String userName = "";
  String bio = "";
  String profilePicture = "";
  int soldListings = 0;
  double totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchSoldListingsData();
  }

  Future<void> fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('artists').doc(widget.userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        setState(() {
          userName = "${userData['firstname']} ${userData['lastname']}";
          bio = userData['bio'] ?? "";
          profilePicture = userData['profilePicture'] ?? "";
          _bioController.text = bio;
          _profilePictureController.text = profilePicture;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<void> fetchSoldListingsData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('artworks')
          .where('artistId', isEqualTo: widget.userId)
          .where('availability', isEqualTo: false)
          .get();

      int soldCount = querySnapshot.docs.length;
      double revenue = querySnapshot.docs.fold(
        0.0,
        (sum, doc) => sum + (doc['price'] ?? 0.0),
      );

      setState(() {
        soldListings = soldCount;
        totalRevenue = revenue;
      });
    } catch (e) {
      print("Error fetching sold listings: $e");
    }
  }

  Future<void> updateUserData() async {
    try {
      await FirebaseFirestore.instance.collection('artists').doc(widget.userId).update({
        'bio': _bioController.text,
        'profilePicture': _profilePictureController.text,
      });

      setState(() {
        bio = _bioController.text;
        profilePicture = _profilePictureController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      print("Error updating user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profilePicture.isNotEmpty
                      ? NetworkImage(profilePicture)
                      : null,
                  child: profilePicture.isEmpty
                      ? Icon(Icons.person, size: 40)
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    userName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Sold Listings and Revenue
            Text(
              "Statistics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Sold Listings: $soldListings"),
            Text("Total Revenue: \$${totalRevenue.toStringAsFixed(2)}"),
            SizedBox(height: 20),

            // Editable Profile Info
            Text(
              "Update Your Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _profilePictureController,
              decoration: InputDecoration(
                labelText: "Profile Picture URL",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: updateUserData,
                style: ElevatedButton.styleFrom(
                 
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
