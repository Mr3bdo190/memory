import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/connection_screen.dart';

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
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(),
        '/connection': (context) => ConnectionScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
