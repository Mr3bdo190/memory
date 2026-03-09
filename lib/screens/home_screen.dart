import 'package:flutter/material.dart';
import '../models/topic_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Topic> topics = [
    Topic(id: '1', title: 'أول لقاء لنا', isDiscussed: true, note: 'كان يوم جميل جداً'),
    Topic(id: '2', title: 'خطط الصيف الجاي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("مواضيعنا ❤️"), backgroundColor: Colors.pink),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: CheckboxListTile(
              title: Text(topics[index].title),
              subtitle: Text(topics[index].note.isEmpty ? "لا توجد ملاحظات" : topics[index].note),
              value: topics[index].isDiscussed,
              onChanged: (val) {
                setState(() => topics[index].isDiscussed = val!);
              },
              secondary: IconButton(
                icon: Icon(Icons.edit_note),
                onPressed: () {
                  // هنا ممكن تضيف كود لفتح نافذة تعديل الملاحظة
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
        onPressed: () {}, // إضافة موضوع جديد
      ),
    );
  }
}
