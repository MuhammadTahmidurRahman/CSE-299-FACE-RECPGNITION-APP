import 'package:flutter/material.dart';
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image from assets
          Image.asset(
            'assets/splash_logo.jpg',  // Your splash image file
            fit: BoxFit.cover,         // Cover the entire screen
          ),
          // Centered logo text
          Positioned(
            bottom: 50,                // Position the text at the bottom
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Using Text.rich to combine text and icon
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: 'PicT'),  // "PicT" part of the logo
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Icon(
                            Icons.camera_alt,  // Camera icon
                            color: Colors.white,
                            size: 48,          // Same size as the text
                          ),
                        ),
                      ),
                      TextSpan(text: 'ra'),  // "ra" part of the logo
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