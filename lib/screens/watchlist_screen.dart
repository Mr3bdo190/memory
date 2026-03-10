import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/glass_container.dart';

class WatchlistScreen extends StatelessWidget {
  final TextEditingController _movieController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String chatId = args['chatId'];

    void _addMovie() {
      if (_movieController.text.trim().isEmpty) return;
      FirebaseFirestore.instance.collection('chats').doc(chatId).collection('watchlist').add({
        'title': _movieController.text.trim(),
        'isWatched': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _movieController.clear();
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: Text("قائمة السهرة 🍿"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('watchlist').orderBy('timestamp', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
            var docs = snapshot.data!.docs;
            if (docs.isEmpty) return Center(child: Text("القائمة فاضية.. مفيش حاجة عايزين تشوفوها؟", style: TextStyle(color: Colors.white70, fontSize: 16)));
            
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
                      title: Text(doc['title'], style: TextStyle(color: Colors.white, fontSize: 18, decoration: doc['isWatched'] ? TextDecoration.lineThrough : null)),
                      value: doc['isWatched'],
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                      onChanged: (val) => FirebaseFirestore.instance.collection('chats').doc(chatId).collection('watchlist').doc(doc.id).update({'isWatched': val}),
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
                  TextField(controller: _movieController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "مثلاً: مسلسل Teen Wolf...", hintStyle: TextStyle(color: Colors.white54))),
                  SizedBox(height: 20),
                  ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: _addMovie, child: Text("إضافة للقائمة", style: TextStyle(color: Colors.white)))
                ]
              )
            )
          )
        )
      )
    );
  }
}
