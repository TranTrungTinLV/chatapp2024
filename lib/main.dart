import 'package:chatapps2024/screens/auth.screen.dart';
import 'package:chatapps2024/screens/chat.screen.dart';
import 'package:chatapps2024/screens/login.dart';
import 'package:chatapps2024/screens/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Splashscreen();
              }
              if (snapshot.hasData) {
                return ChatScreen();
              }
              return LoginScreen();
            }));
  }
}
