import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // for image file support

class ProfileDashboardPage extends StatefulWidget {
  final String artistId;

  ProfileDashboardPage({required this.artistId});

  @override
  _ProfileDashboardPageState createState() => _ProfileDashboardPageState();
}

class _ProfileDashboardPageState extends State<ProfileDashboardPage> {
  String _username = "Username";
  String _firstname = "FirstName";
  String _lastname = "LastName";
  String _email = "email@example.com";
  String _password = "******";
  Image? _profileImage; 

  // Cache for storing artist data
  Map<String, dynamic> _artistCache = {};

  @override
  void initState() {
    super.initState();
    _loadArtistData();
  }

  // Fetch artist data from Firestore and cache it
  Future<void> _loadArtistData() async {
    if (_artistCache.containsKey(widget.artistId)) {
      // If data is cached, use it directly
      var cachedData = _artistCache[widget.artistId];
      setState(() {
        _username = cachedData['username'];
        _firstname = cachedData['firstname'];
        _lastname = cachedData['lastname'];
        _email = cachedData['email'];
        _password = cachedData['password'];
      });
    } else {
      try {
        // Fetch artist data from Firestore
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('artists')
            .doc(widget.artistId)
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;

          // Cache the data
          _artistCache[widget.artistId] = data;

          setState(() {
            _username = data['username'];
            _firstname = data['firstname'];
            _lastname = data['lastname'];
            _email = data['email'];
            _password = data['password']; // Should hash the password in real app
          });
        }
      } catch (error) {
        print("Error fetching artist data: $error");
      }
    }
  }

  // Method to pick profile photo
  Future<void> _pickProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = Image.file(File(image.path)); // Replace with picked image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Photo with Edit option
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: _profileImage?.image ??
                    AssetImage('lib/assets/default_profile_pic.jpg')
                        as ImageProvider, // Default image if no custom one
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Today is the day $_username!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Display user details
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('First Name:', _firstname),
                  _buildDetailRow('Last Name:', _lastname),
                  _buildDetailRow('Email:', _email),
                  _buildDetailRow('Username:', _username),
                  _buildDetailRow('Password:', _password), // Password would be hashed or masked in real app
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
