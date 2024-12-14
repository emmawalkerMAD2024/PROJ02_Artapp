import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDashboardPage extends StatefulWidget {
  final String artistId;

  ProfileDashboardPage({required this.artistId});

  @override
  _ProfileDashboardPageState createState() => _ProfileDashboardPageState();
}

class _ProfileDashboardPageState extends State<ProfileDashboardPage> {
  late String _userName;
  late String _userEmail;
  late String _userProfileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load data from shared preferences (cache)
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Unknown User';
      _userEmail = prefs.getString('user_email') ?? 'No email';
      _userProfileImage = prefs.getString('user_profile_image') ??
          'lib/assets/default_profile_image.png'; // Placeholder image
    });
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user profile image
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(_userProfileImage),
            ),
            SizedBox(height: 20),
            
            // Display user name
            Text(
              'Name: $_userName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Display user email
            Text(
              'Email: $_userEmail',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Button to update profile details (for example, to update profile picture)
            ElevatedButton(
              onPressed: () {
                // Navigate to profile settings or update screen (this functionality should be implemented separately)
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => UpdateProfilePage()),
                // );
              },
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
