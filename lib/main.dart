import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // Import Firebase core
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'splash.dart';  // Import the Splash page
import 'login.dart';  // Import your login page
import 'createorjoinroom.dart';  // Import the Create or Join Room page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pictora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),  // Set SplashPage as the first page
    );
  }
}

// SplashScreen widget (assuming you already have it)
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserLoginStatus();
  }

  // Check if user is logged in and navigate accordingly
  void _checkUserLoginStatus() async {
    // Simulate a loading delay
    await Future.delayed(Duration(seconds: 2));

    // Check if user is authenticated
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is signed in, navigate to CreateOrJoinRoomPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CreateOrJoinRoomPage()),
      );
    } else {
      // User is not signed in, navigate to LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loading indicator while checking auth state
      ),
    );
  }
}
