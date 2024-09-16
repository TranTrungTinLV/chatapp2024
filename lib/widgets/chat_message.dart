import 'package:chatapps2024/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});

  @override
  Widget build(BuildContext context) {
    var isMe = false;
    final authenticateUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createAt', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No messages found.'),
            );
          }
          if (chatSnapshot.hasError) {
            return Center(
              child: Text('Something went wrong...'),
            );
          }
          final loadMessage = chatSnapshot.data!.docs;
          return Expanded(
            child: ListView.builder(
                itemCount: loadMessage.length,
                reverse: true,
                itemBuilder: (ctx, index) {
                  final chatMessage = loadMessage[index].data();
                  final nextChatMessage = index + 1 < loadMessage.length
                      ? loadMessage[index + 1].data()
                      : null;
                  final currentMessageUserId = chatMessage['userId'];
                  final nextChatMessageUserId = nextChatMessage != null
                      ? nextChatMessage['userId']
                      : null;
                  final nextMessageIsSame =
                      nextChatMessageUserId == currentMessageUserId;
                  if (nextMessageIsSame) {
                    return MessageBubble.next(
                        message: chatMessage['text'],
                        isMe: authenticateUser.uid == currentMessageUserId);
                  } else {
                    return MessageBubble.first(
                        userImage: chatMessage['images'],
                        username: chatMessage['username'],
                        message: chatMessage['text'],
                        isMe: authenticateUser.uid == currentMessageUserId);
                  }
                  ;
                }),
          );
        });
  }
}
