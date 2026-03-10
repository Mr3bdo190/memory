import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/glass_container.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  bool _isUpdating = false;

  Future<void> _updateMyLocation() async {
    setState(() => _isUpdating = true);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("شغل الـ GPS الأول يا برنس")));
      setState(() => _isUpdating = false); return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) { setState(() => _isUpdating = false); return; }
    }

    Position position = await Geolocator.getCurrentPosition();
    await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
      'location': { 'lat': position.latitude, 'lng': position.longitude, 'timestamp': FieldValue.serverTimestamp() }
    });
    setState(() => _isUpdating = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إرسال موقعك بنجاح 📍")));
  }

  void _openMaps(double lat, double lng) async {
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String partnerUid = args['partnerUid'];

    return Scaffold(
      appBar: AppBar(title: Text("رادار الحب 📍"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassContainer(
                  height: 150,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("موقعي الحالي", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      _isUpdating 
                        ? CircularProgressIndicator(color: Colors.redAccent)
                        : ElevatedButton.icon(
                            icon: Icon(Icons.my_location, color: Colors.white),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            onPressed: _updateMyLocation,
                            label: Text("إرسال موقعي الآن", style: TextStyle(color: Colors.white, fontSize: 16)),
                          )
                    ],
                  )
                ),
                SizedBox(height: 20),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(partnerUid).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Colors.redAccent));
                      var partnerData = snapshot.data!.data() as Map<String, dynamic>;
                      var loc = partnerData['location'];
                      
                      if (loc == null) return GlassContainer(child: Center(child: Text("لسه مفيش موقع متاح للشريك", style: TextStyle(color: Colors.white))));

                      DateTime lastUpdate = (loc['timestamp'] as Timestamp).toDate();
                      return GlassContainer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, color: Colors.redAccent, size: 60),
                            SizedBox(height: 10),
                            Text("موقع شريكك متاح", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text("تحديث: ${lastUpdate.hour}:${lastUpdate.minute}", style: TextStyle(color: Colors.white70)),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: Icon(Icons.map, color: Colors.white),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              onPressed: () => _openMaps(loc['lat'], loc['lng']),
                              label: Text("فتح في جوجل ماب", style: TextStyle(color: Colors.white, fontSize: 18)),
                            )
                          ],
                        )
                      );
                    }
                  )
                )
              ],
            ),
          )
        )
      )
    );
  }
}
