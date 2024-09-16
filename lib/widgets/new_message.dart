import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _message = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _message.dispose();
  }

  void _submitMessage() async {
    final enterMessage = _message.text;

    if (enterMessage.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    _message.clear();
 
    final userId = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId.uid)
        .get(); //getData

    // send to firebaseStore;
    await FirebaseFirestore.instance.collection('chat').add({
      'text': enterMessage,
      'createAt': Timestamp.now(),
      'userId': userId.uid,
      'username': userData.data()!['username'],
      'images': userData.data()!['images']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 1))),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _message,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.transparent)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.transparent)),
                hintText: 'Make',
                hintStyle: TextStyle(color: Color(0xff797C7B)),
                fillColor: Color(0xFFF3F6F6),
                filled: true),
          )),
          SizedBox(
            width: 18,
          ),
          GestureDetector(
              onTap: _submitMessage,
              child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green,
                  child: IconButton(
                      onPressed: _submitMessage,
                      icon: Icon(
                        Icons.send,
                        size: 20.0,
                        color: Colors.white,
                      ))))
        ],
      ),
    );
  }
}
