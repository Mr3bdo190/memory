import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                GlassContainer(
                  height: 100,
                  child: Center(child: Text("مرحباً بك في عالمكم الخاص ❤️", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildCard(context, "الذكريات", Icons.photo_album, () {}),
                      _buildCard(context, "مواضيع النقاش", Icons.topic, () {}),
                      _buildCard(context, "الشات الخاص", Icons.chat, () {}),
                      _buildCard(context, "تسجيل خروج", Icons.exit_to_app, () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/');
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 45),
            SizedBox(height: 15),
            Text(title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
