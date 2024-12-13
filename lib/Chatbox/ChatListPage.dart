import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatRoomPage.dart';

class ChatListPage extends StatelessWidget {
  final String currentUserId;

  ChatListPage({required this.currentUserId});

  Stream<QuerySnapshot> getUserChats() {
     print('Fetching chats for user: $currentUserId');
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();

  }

  Future<List<String>> fetchUserDocIds(String otherUserId) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('artists')
        .where('artistId', isEqualTo: otherUserId)
        .get();

    // Extract document IDs
    List<String> docIds = querySnapshot.docs.map((doc) => doc.id).toList();

    
    return docIds;
  } catch (e) {
    print('Error fetching user document IDs: $e');
    return [];
  }
}

Future<Map<String, dynamic>> fetchUserDetailsByUserId(String otherUserId) async {
  try {
    List<String> userDocIds = await fetchUserDocIds(otherUserId);
    if (userDocIds.isNotEmpty) {
      // Fetch the first matching user's details
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('artists')
          .doc(userDocIds.first)
          .get();
      print(userSnapshot.data() as Map<String, dynamic>);
      return userSnapshot.data() as Map<String, dynamic>;

        
    }
    return {}; // Return empty if no matching user found
  } catch (e) {
    print('Error fetching user details: $e');
    return {};
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
if (!snapshot.hasData) {
      print('No data received from Firestore.');
      return Center(child: Text('No messages yet.'));
    }

    final chats = snapshot.data!.docs;
    print('Number of chats found: ${chats.length}');
    chats.forEach((chat) => print(chat.data()));

    if (chats.isEmpty) {
     // return Center(child: Text('No messages yet.'));
    }
        
          

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = chat['participants'];
              final otherUserId = participants.firstWhere((id) => id != currentUserId);


              return FutureBuilder<Map<String, dynamic>>(
                future: fetchUserDetailsByUserId(otherUserId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final user = userSnapshot.data!;
                  
                  final userName = user['firstname'] + " " + user['lastname'] ?? 'Unknown User';
                  final lastMessage = chat['lastMessage'];
                  
                  return ListTile(
                    leading: CircleAvatar(
                     // backgroundImage: NetworkImage(user['profilePicture']),
                    ),
                    title: Text(userName),
                    subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomPage(
                            currentUserId: currentUserId,
                            otherUserId: otherUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
