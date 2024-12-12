import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ChatRoomPage.dart';

class ChatListPage extends StatelessWidget {
  final String currentUserId;

  ChatListPage({required this.currentUserId});

  Stream<QuerySnapshot> getUserChats() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No messages yet.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = chat['participants'];
              final otherUserId = participants.firstWhere((id) => id != currentUserId);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final user = userSnapshot.data!;
                  final userName = user['name'];
                  final lastMessage = chat['lastMessage'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profilePicture']),
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
