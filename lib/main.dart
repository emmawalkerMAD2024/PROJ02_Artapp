import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'ArtistWorksListedPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artworks App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ArtistWorksListedPage(artistId: '101'),
    );
  }
}

  