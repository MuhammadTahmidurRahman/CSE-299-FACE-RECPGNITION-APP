import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart';
import 'home.dart';
=======
import 'package:image_picker/image_picker.dart'; // Required for picking images
import 'dart:io'; // Required for handling file system
import 'package:permission_handler/permission_handler.dart'; // Required for handling permissions
import 'package:firebase_auth/firebase_auth.dart'; // Required for Firebase authentication
import 'package:firebase_storage/firebase_storage.dart'; // Required for Firebase storage
import 'package:google_sign_in/google_sign_in.dart'; // Required for Google Sign-In
import 'login.dart';  // Import the login page
import 'home.dart';   // Import the home page
>>>>>>> 042d254b00a0e7b140cee3afc980a06d8df3c182

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  File? _image;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isUploading = false;

  // Request permissions for camera or gallery
  Future<void> _requestPermission(Permission permission) async {
    PermissionStatus status = await permission.request();
    if (status.isGranted) {
      print("Permission granted");
    } else {
      print("Permission denied");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Permission is required to use this feature")),
      );
    }
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await _requestPermission(Permission.camera);
    } else if (source == ImageSource.gallery) {
      await _requestPermission(Permission.storage);
    }

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Show the image picker dialog
  Future<void> _showImagePickerDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImageToFirebase(File? image) async {
    if (image == null) {
      print("No image selected");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select an image first.")));
      return null;
    }

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

    try {
      setState(() {
        _isUploading = true;
      });
      UploadTask uploadTask = firebaseStorageRef.putFile(image);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("Image uploaded. URL: $downloadUrl");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image uploaded successfully!")));
      return downloadUrl;
    } catch (e) {
      print("Upload failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload image: ${e.toString()}")));
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Register user with Firebase (Email/Password)
  Future<void> _registerUser() async {
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must be at least 6 characters long")),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (_image != null) {
        await _uploadImageToFirebase(_image!);
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print("Registration failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register: ${e.toString()}")));
    }
  }

  // Sign in with Google and upload image
  Future<void> _signInWithGoogle() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload an image before signing up with Google")),
      );
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // Upload the image after Google Sign-In
        String? imageUrl = await _uploadImageToFirebase(_image!);

        if (imageUrl != null) {
          // You can store the image URL in the user's Firestore profile or other database if needed
          print("Image URL after Google Sign-In: $imageUrl");
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No Google account found")),
        );
      }
    } catch (e) {
      print("Google Sign-In failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in with Google: ${e.toString()}")));
    }
  }

  // Method to sign in with Google
  Future<void> _signInWithGoogle() async {
    if (_image == null) {
      // Show caution text if no image is uploaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload an image before signing up with Google")),
      );
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // Navigate to the home page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No Google account found")),
        );
      }
    } catch (e) {
      print("Google Sign-In failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in with Google: $e")));
    }
  }

  // Method to sign in with Google
  Future<void> _signInWithGoogle() async {
    if (_image == null) {
      // Show caution text if no image is uploaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload an image before signing up with Google")),
      );
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

        // Navigate to the home page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No Google account found")),
        );
      }
    } catch (e) {
      print("Google Sign-In failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to sign in with Google: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/hpbg1.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    TextField(
                      controller: _passwordController,
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
                    TextField(
                      controller: _confirmPasswordController,
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
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: Column(
                        children: [
                          CircleAvatar(
<<<<<<< Updated upstream
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            backgroundImage: _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? Icon(Icons.add_a_photo, color: Colors.white, size: 40)
                                : null,
                          ),
                          SizedBox(height: 10), // Add space between the avatar and text
                          Text(
                            'Please upload your image',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
=======
<<<<<<< HEAD
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                                : null,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Upload a profile picture',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _registerUser,
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.login),
                      label: Text("Sign Up with Google"),
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
=======
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            backgroundImage: _image != null ? FileImage(_image!) : null,
                            child: _image == null
                                ? Icon(Icons.add_a_photo, color: Colors.white, size: 40)
                                : null,
                          ),
                          SizedBox(height: 10), // Add space between the avatar and text
                          Text(
                            'Please upload your image',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
>>>>>>> Stashed changes
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white, fontSize: 16),
>>>>>>> 042d254b00a0e7b140cee3afc980a06d8df3c182
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
<<<<<<< Updated upstream
=======
<<<<<<< HEAD
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text("Already have an account? Log In", style: TextStyle(color: Colors.white)),
=======
>>>>>>> Stashed changes
                    ElevatedButton(
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
<<<<<<< Updated upstream
                      ),
                      child: Center(
                        child: Text(
                          'Sign in with Google',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Already have an account? Log in button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),  // Navigate to LoginPage
                          );
                        },
                        child: Text(
                          "Already have an account? Log in",
                          style: TextStyle(color: Colors.white),
                        ),
=======
>>>>>>> Stashed changes
                      ),
                      child: Center(
                        child: Text(
                          'Sign in with Google',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    // Already have an account? Log in button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),  // Navigate to LoginPage
                          );
                        },
                        child: Text(
                          "Already have an account? Log in",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
>>>>>>> 042d254b00a0e7b140cee3afc980a06d8df3c182
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
}
