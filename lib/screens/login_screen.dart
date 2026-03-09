import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Memory ❤️", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.pink)),
              SizedBox(height: 30),
              TextField(decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder())),
              SizedBox(height: 10),
              TextField(decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()), obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                child: Text("دخول"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
