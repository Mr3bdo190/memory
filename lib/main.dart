import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/connection_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/topics_screen.dart';
import 'screens/memories_screen.dart';
import 'screens/countdown_screen.dart';
import 'screens/time_capsule_screen.dart';
import 'screens/shared_notes_screen.dart';
import 'screens/location_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MemoryApp());
}

class MemoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory App',
      theme: ThemeData(primarySwatch: Colors.red, scaffoldBackgroundColor: Colors.black),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/connection': (context) => ConnectionScreen(),
        '/home': (context) => HomeScreen(),
        '/chat': (context) => ChatScreen(),
        '/topics': (context) => TopicsScreen(),
        '/memories': (context) => MemoriesScreen(),
        '/countdown': (context) => CountdownScreen(),
        '/capsule': (context) => TimeCapsuleScreen(),
        '/notes': (context) => SharedNotesScreen(),
        '/location': (context) => LocationScreen(),
      },
    );
  }
}
