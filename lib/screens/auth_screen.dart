import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/glass_container.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  void authenticate() async {
    setState(() => isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());
      } else {
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());
        
        await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
          'uid': userCred.user!.uid,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'partnerUid': null,
        });
      }
      // التوجيه لصفحة الارتباط للتأكد من وجود شريك
      Navigator.pushReplacementNamed(context, '/connection');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.red.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: GlassContainer(
              height: isLogin ? 400 : 480,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Memory ❤️", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 20),
                  if (!isLogin)
                    TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(labelText: "الاسم", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54))),
                    ),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(labelText: "البريد الإلكتروني", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54))),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(labelText: "كلمة المرور", labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54))),
                  ),
                  SizedBox(height: 30),
                  isLoading 
                    ? CircularProgressIndicator(color: Colors.redAccent)
                    : ElevatedButton(
                        onPressed: authenticate,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withOpacity(0.8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: Padding(padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15), child: Text(isLogin ? "دخول" : "إنشاء حساب", style: TextStyle(color: Colors.white, fontSize: 18))),
                      ),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(isLogin ? "معندكش حساب؟ سجل دلوقتي" : "عندك حساب؟ ادخل من هنا", style: TextStyle(color: Colors.white70)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
