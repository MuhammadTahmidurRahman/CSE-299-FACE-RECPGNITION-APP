import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgot_password.dart'; // Forgot password page import
import 'createorjoinroom.dart'; // Home page import

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/hpbg1.png', // Background image for the login page
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back arrow icon
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Navigate back to Welcome Page
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Log in to PicTora',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Enter the email you have registered with.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(height: 40),
                    // Email field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText; // Toggle password visibility
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to Forgot Password page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Log in Button
                    ElevatedButton(
                      onPressed: _loginWithEmailPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Log in',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Google Sign-In Button
// Google Sign-In Button
                    ElevatedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Icon(Icons.login, color: Colors.white), // Set icon color to white
                      label: Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.white), // Set text color to white
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Set button background color to black
                        padding: EdgeInsets.symmetric(vertical: 15), // Same padding as the "Log in" button
                        minimumSize: Size(double.infinity, 50), // Make the button fill the width like the "Log in" button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Same border radius as the "Log in" button
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loginWithEmailPassword() async {
    try {
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      )).user;

      if (user != null) {
        _checkIfUserExists(user); // Check if user is new
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // The user canceled the sign-in
      }

      // Get the email of the Google user
      final String? email = googleUser.email;

      // Check if this email already exists in Firebase Authentication
      final List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email!);

      // If the user is already registered, allow sign-in
      if (signInMethods.isNotEmpty) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final User? user = (await _auth.signInWithCredential(credential)).user;

        if (user != null) {
          _checkIfUserExists(user); // Check if user is new
        }
      } else {
        // User is not registered, show error and don't sign them in
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('You are not registered. Sign up first.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Redirect to the previous page
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
    }
  }

  void _checkIfUserExists(User user) async {
    if (user.metadata.creationTime != user.metadata.lastSignInTime) {
      // Existing user, proceed to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CreateOrJoinRoomPage()),
      );
    } else {
      // User is new, prevent account from being saved and sign them out
      await _auth.signOut();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('You are not registered. Sign up first.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Redirect to the previous page
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
