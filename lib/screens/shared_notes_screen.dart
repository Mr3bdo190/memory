import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/glass_container.dart';

class SharedNotesScreen extends StatelessWidget {
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String chatId = args['chatId'];

    void _addNote() {
      if (_noteController.text.trim().isEmpty) return;
      FirebaseFirestore.instance.collection('chats').doc(chatId).collection('notes').add({
        'text': _noteController.text.trim(),
        'isDone': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _noteController.clear();
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: Text("نوتة لقائنا 📝"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('notes').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
            var docs = snapshot.data!.docs;
            if (docs.isEmpty) return Center(child: Text("النوتة فاضية.. هتخرجوا تروحوا فين؟", style: TextStyle(color: Colors.white70, fontSize: 16)));
            
            return ListView.builder(
              padding: EdgeInsets.only(top: 100, left: 15, right: 15),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: GlassContainer(
                    height: 80,
                    child: CheckboxListTile(
                      title: Text(doc['text'], style: TextStyle(color: Colors.white, fontSize: 18, decoration: doc['isDone'] ? TextDecoration.lineThrough : null)),
                      value: doc['isDone'],
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      onChanged: (val) => FirebaseFirestore.instance.collection('chats').doc(chatId).collection('notes').doc(doc.id).update({'isDone': val}),
                    )
                  )
                );
              }
            );
          }
        )
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
                  TextField(controller: _noteController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "هنعمل إيه...؟", hintStyle: TextStyle(color: Colors.white54))),
                  SizedBox(height: 20),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: _addNote, child: Text("إضافة للنوتة", style: TextStyle(color: Colors.white)))
                ]
              )
            )
          )
        )
      )
    );
  }
}
