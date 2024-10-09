import 'package:flutter/material.dart';
import 'home_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/hpbg1.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back arrow icon
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Create an Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Please fill in the information below to create an account.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 40),
                  // Email field
                  TextField(
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
                    obscureText: _obscureTextPassword,
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
                          _obscureTextPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureTextPassword = !_obscureTextPassword;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Confirm password field
                  TextField(
                    obscureText: _obscureTextConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureTextConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer(),
                  // Signup Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to home page after signup
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
