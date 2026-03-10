import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/glass_container.dart';

class ConnectionScreen extends StatefulWidget {
  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final _emailController = TextEditingController();
  final currentUid = FirebaseAuth.instance.currentUser!.uid;

  void showGlassAlert(String title, String message, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 60),
              SizedBox(height: 15),
              Text(title, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(message, style: TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: Text("حسناً", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void sendRequest() async {
    final email = _emailController.text.trim();
    if(email.isEmpty) return;
    final query = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    
    if (query.docs.isNotEmpty) {
      final targetUid = query.docs.first.id;
      await FirebaseFirestore.instance.collection('users').doc(targetUid).update({
        'pendingRequestFrom': currentUid,
      });
      showGlassAlert("تم الإرسال ❤️", "تم إرسال طلب الارتباط بنجاح، في انتظار القبول!", Icons.send);
    } else {
      showGlassAlert("خطأ", "لم يتم العثور على حساب بهذا الإيميل", Icons.error_outline);
    }
  }

  void respondToRequest(String partnerUid, bool accept) async {
    if (accept) {
      await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
        'partnerUid': partnerUid,
        'pendingRequestFrom': FieldValue.delete(),
      });
      await FirebaseFirestore.instance.collection('users').doc(partnerUid).update({
        'partnerUid': currentUid,
        'pendingRequestFrom': FieldValue.delete(),
      });
    } else {
      await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
        'pendingRequestFrom': FieldValue.delete(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
            var userData = snapshot.data!.data() as Map<String, dynamic>?;
            
            if (userData != null && userData['partnerUid'] != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/home');
              });
              return Center(child: Text("جاري الدخول لعالمكم الخاص...", style: TextStyle(color: Colors.white)));
            }

            String? pendingReq = userData?['pendingRequestFrom'];

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: GlassContainer(
                  height: 450,
                  child: pendingReq != null 
                    ? FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('users').doc(pendingReq).get(),
                        builder: (context, senderSnap) {
                          if (!senderSnap.hasData) return Center(child: CircularProgressIndicator(color: Colors.white));
                          String senderName = senderSnap.data!['name'] ?? 'شخص ما';
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite, color: Colors.redAccent, size: 60),
                              SizedBox(height: 20),
                              Text("طلب ارتباط جديد! ❤️", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text("المرسل: $senderName", style: TextStyle(color: Colors.white70, fontSize: 18)),
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => respondToRequest(pendingReq, true),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: Text("قبول", style: TextStyle(color: Colors.white)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => respondToRequest(pendingReq, false),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
                                    child: Text("رفض", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              )
                            ],
                          );
                        }
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.redAccent, size: 60),
                          SizedBox(height: 20),
                          Text("ابحث عن شريك حياتك", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 30),
                          TextField(
                            controller: _emailController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "إيميل الشريك",
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54), borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: sendRequest,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12), child: Text("إرسال الطلب", style: TextStyle(color: Colors.white, fontSize: 18))),
                          )
                        ],
                      ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
