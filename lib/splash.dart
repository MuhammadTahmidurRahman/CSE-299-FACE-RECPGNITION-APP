import 'package:flutter/material.dart';
import 'home_page.dart';  // Import HomePage

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),  // Navigate to HomePage
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splash_logo.jpg',  // Your splash image file
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: 'PicT'),
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      TextSpan(text: 'ra'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
