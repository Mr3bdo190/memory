import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/glass_container.dart';

class ChatScreen extends StatelessWidget {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _msgController = TextEditingController();

  void sendMessage(String chatId) {
    if (_msgController.text.trim().isEmpty) return;
    FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'text': _msgController.text.trim(),
      'senderId': currentUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String partnerUid = args['partnerUid'];
    // دمج الـ IDs عشان نعمل غرفة شات واحدة ليكم انتوا الاتنين بس
    final String chatId = currentUid.compareTo(partnerUid) < 0 ? "${currentUid}_$partnerUid" : "${partnerUid}_$currentUid";

    return Scaffold(
      appBar: AppBar(title: Text("الشات الخاص"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                    var docs = snapshot.data!.docs;
                    return ListView.builder(
                      reverse: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        bool isMe = docs[index]['senderId'] == currentUid;
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            child: GlassContainer(
                              padding: 15,
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 60, // تقريبي
                              child: Text(docs[index]['text'], style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        height: 60,
                        padding: 5,
                        child: TextField(
                          controller: _msgController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: "اكتب رسالة...", hintStyle: TextStyle(color: Colors.white54), border: InputBorder.none, contentPadding: EdgeInsets.only(left: 15)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => sendMessage(chatId),
                      child: GlassContainer(width: 60, height: 60, child: Icon(Icons.send, color: Colors.white)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
