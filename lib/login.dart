import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgot_password.dart'; // Forgot password page import
import 'createorjoinroom.dart'; // Home page import
import 'signup.dart'; // Import the registration page

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;  // Instance of FirebaseAuth
  final GoogleSignIn _googleSignIn = GoogleSignIn();  // Instance of GoogleSignIn
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
                    ElevatedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Icon(Icons.login, color: Colors.white),
                      label: Text(
                        "Sign in with Google",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Don't have an account? Register option
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to Registration Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignupPage()),
                          );
                        },
                        child: Text(
                          "Don't have an account? Register",
                          style: TextStyle(color: Colors.white),
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

  // Login with email and password
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
      if (e is FirebaseAuthException) {
        // Check for specific error codes
        if (e.code == 'user-not-found') {
          // Show snackbar when no account is found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No account found. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (e.code == 'wrong-password') {
          // Show snackbar for wrong password
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email and password do not match. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Show general error message for other cases
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Handle any other types of errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Login with Google
  Future<void> _loginWithGoogle() async {
    try {
      // Initiate Google sign-in, which will display the account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a credential using the Google sign-in information
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in using the Google credential
      final User? user = (await _auth.signInWithCredential(credential)).user;

      if (user != null) {
        // Check if the user is new or existing
        _checkIfUserExists(user);
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      if (e is FirebaseAuthException && e.code == 'account-exists-with-different-credential') {
        _showErrorDialog('This Google account is already linked to another account.');
      } else {
        _showErrorDialog('No account found with this Google account. Please try again.');
      }
    }
  }


  // Check if the user exists (if the user is new or existing)
  void _checkIfUserExists(User user) async {
    try {
      // Check if the user is newly created or existing
      if (user.metadata.creationTime != user.metadata.lastSignInTime) {
        // Existing user, proceed to HomePage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CreateOrJoinRoomPage()),
              (Route<dynamic> route) => false,
        );
      } else {
        // New user, sign out and show error
        await _auth.signOut();
        _showErrorDialog('You are not registered. Please sign up first.');
      }
    } catch (e) {
      print('Error checking user existence: $e');
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
