import 'package:flutter/material.dart';

class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatting'),
        // centerTitle: true,
      ),
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}
