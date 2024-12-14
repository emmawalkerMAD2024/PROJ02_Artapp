import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileDashboardPage extends StatefulWidget {
  @override
  _ProfileDashboardPageState createState() => _ProfileDashboardPageState();
}

class _ProfileDashboardPageState extends State<ProfileDashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late Map<String, dynamic> _cachedArtistInfo;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchCachedArtistInfo();
  }

  Future<void> _fetchCachedArtistInfo() async {
    final user = _auth.currentUser;

    if (user != null) {
      final docSnapshot = await _firestore.collection('artists').doc(user.uid).get();
      if (docSnapshot.exists) {
        setState(() {
          _cachedArtistInfo = docSnapshot.data() ?? {};
        });
      }
    }
  }

  Future<void> _editProfilePhoto() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        final user = _auth.currentUser;
        if (user != null && _selectedImage != null) {
          final storageRef = _storage.ref().child('profile_photos/${user.uid}.jpg');
          await storageRef.putFile(_selectedImage!);
          final photoURL = await storageRef.getDownloadURL();

          await _firestore.collection('artists').doc(user.uid).update({
            'photoURL': photoURL,
          });

          setState(() {
            _cachedArtistInfo['photoURL'] = photoURL;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile photo updated successfully!")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile photo: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Dashboard"),
      ),
      body: _cachedArtistInfo == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _editProfilePhoto,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _cachedArtistInfo['photoURL'] != null
                              ? NetworkImage(_cachedArtistInfo['photoURL'])
                              : AssetImage('lib/assets/placeholder.jpg') as ImageProvider,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Today is the day ${_cachedArtistInfo['username']}!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    "Your Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow("First Name", _cachedArtistInfo['firstname']),
                  _buildInfoRow("Last Name", _cachedArtistInfo['lastname']),
                  _buildInfoRow("Email", _cachedArtistInfo['email']),
                  _buildInfoRow("Username", _cachedArtistInfo['username']),
                  _buildInfoRow("Password", "********"), // Avoid showing the password directly
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
