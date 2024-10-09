import 'package:flutter/material.dart';
import 'welcome.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Preload the splash screen image
      precacheImage(AssetImage('assets/splash_logo.jpg'), context).then((_) {
        // Navigate to WelcomePage after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => WelcomePage()),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splash_logo.jpg',
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
                          padding: const EdgeInsets.only(bottom: 4),
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
