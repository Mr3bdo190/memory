import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/glass_container.dart';
import '../services/media_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final MediaService _mediaService = MediaService();
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final List<String> moods = ['😊 رايق', '😔 مضايق', '😡 متعصب', '🥺 محتاجك', '💼 مشغول', '😴 بفصل'];

  void _updateMood(String mood) async {
    await FirebaseFirestore.instance.collection('users').doc(currentUid).update({'mood': mood});
    Navigator.pop(context);
  }

  void _changeProfilePic() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50); // تقليل جودة الصورة لسرعة الرفع
    if (image == null) return;
    
    setState(() => _isUploading = true);
    String? imageUrl = await _mediaService.uploadImage(File(image.path));
    if (imageUrl != null) {
      await FirebaseFirestore.instance.collection('users').doc(currentUid).update({'profilePic': imageUrl});
    }
    setState(() => _isUploading = false);
  }

  void _showMoodPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          height: 350,
          child: Column(
            children: [
              Text("حالتك المزاجية إيه؟", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: moods.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Center(child: Text(moods[index], style: TextStyle(color: Colors.white, fontSize: 22))),
                    onTap: () => _updateMood(moods[index]),
                  )
                )
              )
            ]
          )
        )
      )
    );
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
            
            var myData = snapshot.data!.data() as Map<String, dynamic>;
            String partnerUid = myData['partnerUid'] ?? '';
            String myMood = myData['mood'] ?? '😊 رايق';
            String? myPic = myData['profilePic'];
            String myName = myData['name'] ?? 'أنا';
            String chatId = currentUid.compareTo(partnerUid) < 0 ? "${currentUid}_$partnerUid" : "${partnerUid}_$currentUid";

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GlassContainer(
                      height: 160,
                      padding: 15,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: _changeProfilePic,
                            onLongPress: _showMoodPicker,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.white24,
                                      backgroundImage: myPic != null ? CachedNetworkImageProvider(myPic) : null,
                                      child: myPic == null ? Icon(Icons.person, color: Colors.white, size: 35) : null,
                                    ),
                                    if (_isUploading) CircularProgressIndicator(color: Colors.redAccent),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(myName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                                  child: Text(myMood, style: TextStyle(color: Colors.white, fontSize: 12)),
                                )
                              ],
                            ),
                          ),
                          Icon(Icons.favorite, color: Colors.redAccent, size: 40),
                          if (partnerUid.isNotEmpty)
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance.collection('users').doc(partnerUid).snapshots(),
                              builder: (context, partnerSnap) {
                                if (!partnerSnap.hasData) return CircularProgressIndicator(color: Colors.white);
                                var partnerData = partnerSnap.data!.data() as Map<String, dynamic>;
                                String partnerPic = partnerData['profilePic'] ?? '';
                                String partnerMood = partnerData['mood'] ?? '😊 رايق';
                                String partnerName = partnerData['name'] ?? 'شريكي';

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.white24,
                                      backgroundImage: partnerPic.isNotEmpty ? CachedNetworkImageProvider(partnerPic) : null,
                                      child: partnerPic.isEmpty ? Icon(Icons.person, color: Colors.white, size: 35) : null,
                                    ),
                                    SizedBox(height: 8),
                                    Text(partnerName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                                      child: Text(partnerMood, style: TextStyle(color: Colors.white, fontSize: 12)),
                                    )
                                  ],
                                );
                              }
                            )
                        ],
                      ),
                    ),
                    SizedBox(height: 15),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildCard(context, "الشات الخاص", Icons.chat, () => Navigator.pushNamed(context, '/chat', arguments: {'partnerUid': partnerUid})),
                          _buildCard(context, "الذكريات", Icons.photo_album, () => Navigator.pushNamed(context, '/memories', arguments: {'chatId': chatId})),
                          _buildCard(context, "مواضيع النقاش", Icons.topic, () => Navigator.pushNamed(context, '/topics', arguments: {'chatId': chatId})),
                          _buildCard(context, "أيامنا الحلوة", Icons.calendar_month, () => Navigator.pushNamed(context, '/countdown', arguments: {'chatId': chatId})),
                          _buildCard(context, "قائمة السهرة", Icons.movie, () => Navigator.pushNamed(context, '/watchlist', arguments: {'chatId': chatId})),
                          _buildCard(context, "نوتة لقائنا", Icons.note_alt, () => Navigator.pushNamed(context, '/notes', arguments: {'chatId': chatId})),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        enableBlur: false, // هنا قفلنا الفلتر التقيل عن الزراير
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(height: 15),
            Text(title, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
