import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class RouletteScreen extends StatefulWidget {
  @override
  _RouletteScreenState createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen> with SingleTickerProviderStateMixin {
  // شوية اقتراحات افتراضية جاهزة للروقان
  List<String> options = [
    'نطلب أوبر أو إن درايف ونعقد في حتة هادية',
    'لفة سريعة بالموتوسيكل الهوجان',
    'نحلي بكنافة بالقشطة',
    'نتمشى ونجيب قهوة',
    'نتفرج على فيلم في البيت',
    'نروح مكان جديد أول مرة نجربه'
  ];
  
  String selectedOption = "اضغط على الزرار عشان تختاروا!";
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    _controller.forward(from: 0.0);
    int randomIndex = Random().nextInt(options.length);
    setState(() {
      selectedOption = "جاري الاختيار... 🎲";
    });
    
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        selectedOption = options[randomIndex];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("عجلة الحظ 🎲"), backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Colors.red.shade900], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassContainer(
                  height: 200,
                  child: Center(
                    child: FadeTransition(
                      opacity: Tween(begin: 0.5, end: 1.0).animate(_controller),
                      child: Text(
                        selectedOption,
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: _spinWheel,
                  child: Text("هنعمل إيه لسندس النهاردة؟", style: TextStyle(color: Colors.white, fontSize: 20)),
                )
              ],
            ),
          )
        )
      )
    );
  }
}
