import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/glass_container.dart';

class TopicsScreen extends StatelessWidget {
  final TextEditingController _topicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String chatId = args['chatId'];

    void addTopic() {
      if (_topicController.text.trim().isEmpty) return;
      FirebaseFirestore.instance.collection('chats').doc(chatId).collection('topics').add({
        'title': _topicController.text.trim(),
        'isDiscussed': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _topicController.clear();
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: Text("مواضيع النقاش"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('topics').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            var docs = snapshot.data!.docs;
            return ListView.builder(
              padding: EdgeInsets.only(top: 100, left: 15, right: 15),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: GlassContainer(
                    height: 80,
                    child: CheckboxListTile(
                      title: Text(doc['title'], style: TextStyle(color: Colors.white, fontSize: 18, decoration: doc['isDiscussed'] ? TextDecoration.lineThrough : null)),
                      value: doc['isDiscussed'],
                      checkColor: Colors.black,
                      activeColor: Colors.white,
                      onChanged: (val) {
                        FirebaseFirestore.instance.collection('chats').doc(chatId).collection('topics').doc(doc.id).update({'isDiscussed': val});
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: GlassContainer(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(controller: _topicController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "موضوع جديد...", hintStyle: TextStyle(color: Colors.white54))),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: addTopic, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: Text("إضافة", style: TextStyle(color: Colors.white)))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
