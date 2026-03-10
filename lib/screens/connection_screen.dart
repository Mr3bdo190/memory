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

  void sendRequest() async {
    final email = _emailController.text.trim();
    final query = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    
    if (query.docs.isNotEmpty) {
      final targetUid = query.docs.first.id;
      await FirebaseFirestore.instance.collection('users').doc(targetUid).update({
        'pendingRequestFrom': currentUid,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إرسال الطلب بنجاح! ❤️")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("لم يتم العثور على حساب بهذا الإيميل")));
    }
  }

  void acceptRequest(String partnerUid) async {
    await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
      'partnerUid': partnerUid,
      'pendingRequestFrom': FieldValue.delete(),
    });
    await FirebaseFirestore.instance.collection('users').doc(partnerUid).update({
      'partnerUid': currentUid,
      'pendingRequestFrom': FieldValue.delete(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
            
            var userData = snapshot.data!.data() as Map<String, dynamic>?;
            
            // لو مرتبطين فعلاً، حوله للرئيسية فوراً
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
                  height: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.redAccent, size: 60),
                      SizedBox(height: 20),
                      Text("الارتباط بشريك حياتك", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 30),
                      if (pendingReq != null) ...[
                        Text("لديك طلب ارتباط جديد! ❤️", style: TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => acceptRequest(pendingReq),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          child: Padding(padding: EdgeInsets.all(12), child: Text("قبول الطلب", style: TextStyle(color: Colors.white, fontSize: 18))),
                        )
                      ] else ...[
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "إيميل الشريك للبحث",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54), borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: sendRequest,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          child: Padding(padding: EdgeInsets.all(12), child: Text("إرسال طلب ارتباط", style: TextStyle(color: Colors.white, fontSize: 18))),
                        )
                      ]
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
