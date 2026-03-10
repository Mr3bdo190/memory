import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double padding;

  GlassContainer({required this.child, this.width = double.infinity, this.height = double.infinity, this.padding = 20});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // شفافية خفيفة
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, spreadRadius: 5)
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
