import 'package:flutter/material.dart';
import 'splash.dart';  // Import your splash screen
import 'package:firebase_core/firebase_core.dart';  // Import Firebase core

void main() async {
  // Ensure that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();  // This is crucial for Firebase to work properly

  // Run the main application
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),  // Your splash screen
    );
  }
}
