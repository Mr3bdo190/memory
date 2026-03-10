import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/glass_container.dart';
import '../services/media_service.dart';

class MemoriesScreen extends StatefulWidget {
  @override
  _MemoriesScreenState createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final ImagePicker _picker = ImagePicker();
  final MediaService _mediaService = MediaService();
  bool _isUploading = false;

  void _uploadMemory(String chatId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    TextEditingController captionController = TextEditingController();

    // نافذة لكتابة تعليق على الصورة قبل الرفع
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("إضافة ذكرى جديدة ❤️", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(File(image.path), height: 100, width: 100, fit: BoxFit.cover),
              ),
              SizedBox(height: 15),
              TextField(
                controller: captionController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: "اكتب تعليق للذكرى...", hintStyle: TextStyle(color: Colors.white54), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54))),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  Navigator.pop(context);
                  _processUpload(chatId, File(image.path), captionController.text);
                },
                child: Text("حفظ الذكرى", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _processUpload(String chatId, File imageFile, String caption) async {
    setState(() => _isUploading = true);
    
    // رفع الصورة لـ Cloudinary
    String? imageUrl = await _mediaService.uploadImage(imageFile);
    
    if (imageUrl != null) {
      // حفظ البيانات في Firestore
      await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('memories').add({
        'imageUrl': imageUrl,
        'caption': caption,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم حفظ الذكرى بنجاح! ❤️")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل رفع الصورة، تأكد من الإنترنت.")));
    }
    
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String chatId = args['chatId'];

    return Scaffold(
      appBar: AppBar(title: Text("ذكرياتنا"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Stack(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').doc(chatId).collection('memories').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
                var docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Text("مفيش ذكريات لسه، ضيف أول ذكرى ليكم! ❤️", style: TextStyle(color: Colors.white70, fontSize: 18)));
                
                return GridView.builder(
                  padding: EdgeInsets.only(top: 100, left: 10, right: 10, bottom: 80),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    return GlassContainer(
                      padding: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(doc['imageUrl'], fit: BoxFit.cover, loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(child: CircularProgressIndicator(color: Colors.redAccent));
                              }),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(doc['caption'], style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            if (_isUploading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: GlassContainer(
                    height: 150, width: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.redAccent),
                        SizedBox(height: 15),
                        Text("جاري رفع الذكرى...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add_a_photo, color: Colors.white),
        onPressed: () => _uploadMemory(chatId),
      ),
    );
  }
}
