// main.dart
import 'package:flutter/material.dart';
import 'splash.dart';  // Import the splash screen file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}