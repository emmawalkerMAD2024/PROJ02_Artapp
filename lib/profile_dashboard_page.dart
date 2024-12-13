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
  final TextEditingController bioController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  File? profileImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
      await uploadImageToFirebase(profileImage!);
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos/${currentUser!.uid}.jpg');
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('artists')
          .doc(currentUser!.uid)
          .update({'profilePhotoUrl': downloadUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile photo updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload profile photo: $e')),
      );
    }
  }

  Future<void> updateBio() async {
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('artists').doc(currentUser!.uid).update({
        'bio': bioController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bio updated successfully!')));
    }
  }

  void navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileSettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: navigateToSettings,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : AssetImage('lib/assets/default_avatar.png') as ImageProvider,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    currentUser?.displayName ?? 'Username',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: bioController,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: 'Short Bio',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: updateBio,
              child: Text('Update Bio'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSettingsPage extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'First Name')),
              TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Last Name')),
              TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
              TextField(controller: usernameController, decoration: InputDecoration(labelText: 'Username')),
              TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final User? currentUser = FirebaseAuth.instance.currentUser;

                  if (currentUser != null) {
                    await FirebaseFirestore.instance.collection('artists').doc(currentUser.uid).update({
                      'firstname': firstNameController.text,
                      'lastname': lastNameController.text,
                      'email': emailController.text,
                      'username': usernameController.text,
                      'password': passwordController.text,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
