import 'package:flutter/material.dart';
import 'signup.dart';
import 'login.dart';

class WelcomePage extends StatelessWidget {
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
          // Title and message
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 3.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    children: [
                      TextSpan(text: 'Welcome to PicT'),
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                      TextSpan(text: 'ra'),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Welcome to PicTora! Create an account with us and enjoy effortless photo organization at your fingertips!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1.5, 1.5),
                          blurRadius: 2.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Buttons at the bottom
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Create Account button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Center(
                    child: Text(
                      "Create an Account",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Login button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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
