import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/glass_container.dart';

class CountdownScreen extends StatefulWidget {
  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;

  void _addEvent(String chatId) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassContainer(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("مناسبة جديدة ⏳", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    TextField(
                      controller: _titleController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "اسم المناسبة (عيد ميلاد، ذكرى...)",
                        hintStyle: TextStyle(color: Colors.white54),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54))
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.calendar_month, color: Colors.white),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2)),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(), // عشان يختار تواريخ في المستقبل
                          lastDate: DateTime(2050),
                        );
                        if (picked != null) {
                          setStateDialog(() => _selectedDate = picked);
                        }
                      },
                      label: Text(
                        _selectedDate == null ? "اختر التاريخ" : "${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}",
                        style: TextStyle(color: Colors.white)
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        if (_titleController.text.isNotEmpty && _selectedDate != null) {
                          FirebaseFirestore.instance.collection('chats').doc(chatId).collection('countdowns').add({
                            'title': _titleController.text,
                            'date': _selectedDate!.toIso8601String(),
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          _titleController.clear();
                          _selectedDate = null;
                          Navigator.pop(context);
                        }
                      },
                      child: Padding(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10), child: Text("حفظ", style: TextStyle(color: Colors.white, fontSize: 18))),
                    )
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String chatId = args['chatId'];

    return Scaffold(
      appBar: AppBar(title: Text("أيامنا الحلوة ⏳"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('countdowns').orderBy('date').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
            var docs = snapshot.data!.docs;
            
            if (docs.isEmpty) return Center(child: Text("مفيش مناسبات لسه متسجلة! ❤️", style: TextStyle(color: Colors.white70, fontSize: 18)));

            return ListView.builder(
              padding: EdgeInsets.only(top: 100, left: 15, right: 15),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                DateTime eventDate = DateTime.parse(doc['date']);
                int daysLeft = eventDate.difference(DateTime.now()).inDays;
                
                // لو المناسبة النهارده أو عدت
                String timeText = daysLeft > 0 ? "باقي $daysLeft يوم" : (daysLeft == 0 ? "النهاردة! 🎉" : "عدت من ${daysLeft.abs()} يوم");

                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: GlassContainer(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(doc['title'], style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text("${eventDate.year}-${eventDate.month}-${eventDate.day}", style: TextStyle(color: Colors.white54, fontSize: 14)),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(15)),
                          child: Text(timeText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        )
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
        child: Icon(Icons.add_alarm, color: Colors.white),
        onPressed: () => _addEvent(chatId),
      ),
    );
  }
}
