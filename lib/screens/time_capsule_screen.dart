import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/glass_container.dart';

class TimeCapsuleScreen extends StatefulWidget {
  @override
  _TimeCapsuleScreenState createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends State<TimeCapsuleScreen> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _msgController = TextEditingController();
  DateTime? _unlockDate;

  void _createCapsule(String chatId) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            height: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("كبسولة زمنية جديدة ⏳", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 15),
                TextField(controller: _titleController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "عنوان الكبسولة", hintStyle: TextStyle(color: Colors.white54), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)))),
                SizedBox(height: 10),
                TextField(controller: _msgController, maxLines: 3, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "الرسالة السرية...", hintStyle: TextStyle(color: Colors.white54), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)))),
                SizedBox(height: 15),
                ElevatedButton.icon(
                  icon: Icon(Icons.lock_clock, color: Colors.white),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(Duration(days: 1)),
                      firstDate: DateTime.now().add(Duration(days: 1)),
                      lastDate: DateTime(2050),
                    );
                    if (picked != null) setStateDialog(() => _unlockDate = picked);
                  },
                  label: Text(_unlockDate == null ? "تاريخ الفتح" : "${_unlockDate!.year}-${_unlockDate!.month}-${_unlockDate!.day}", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    if (_titleController.text.isNotEmpty && _msgController.text.isNotEmpty && _unlockDate != null) {
                      FirebaseFirestore.instance.collection('chats').doc(chatId).collection('capsules').add({
                        'title': _titleController.text,
                        'message': _msgController.text,
                        'unlockDate': _unlockDate!.toIso8601String(),
                        'senderId': currentUid,
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                      _titleController.clear();
                      _msgController.clear();
                      _unlockDate = null;
                      Navigator.pop(context);
                    }
                  },
                  child: Text("دفن الكبسولة", style: TextStyle(color: Colors.white, fontSize: 18)),
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String chatId = args['chatId'];

    return Scaffold(
      appBar: AppBar(title: Text("كبسولة الزمن ⏳"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('capsules').orderBy('unlockDate').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
            var docs = snapshot.data!.docs;
            if (docs.isEmpty) return Center(child: Text("مفيش كبسولات مدفونة لسه! 🤫", style: TextStyle(color: Colors.white70, fontSize: 18)));

            return ListView.builder(
              padding: EdgeInsets.only(top: 100, left: 15, right: 15),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                DateTime unlockDate = DateTime.parse(doc['unlockDate']);
                bool isUnlocked = DateTime.now().isAfter(unlockDate) || DateTime.now().isAtSameMomentAs(unlockDate);

                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(doc['title'], style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Icon(isUnlocked ? Icons.lock_open : Icons.lock, color: isUnlocked ? Colors.greenAccent : Colors.white54),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (isUnlocked) ...[
                          Text(doc['message'], style: TextStyle(color: Colors.white, fontSize: 16)),
                          SizedBox(height: 10),
                          Text("المرسل: ${doc['senderId'] == currentUid ? 'أنا' : 'شريكي'}", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                        ] else ...[
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                            child: Center(child: Text("تفتح يوم: ${unlockDate.year}-${unlockDate.month}-${unlockDate.day}", style: TextStyle(color: Colors.white70))),
                          )
                        ]
                      ],
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
        onPressed: () => _createCapsule(chatId),
      ),
    );
  }
}
