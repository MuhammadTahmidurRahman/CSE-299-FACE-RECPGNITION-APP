import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Required for picking images
import 'dart:io'; // Required for handling file system
import 'package:permission_handler/permission_handler.dart'; // Required for handling permissions
import 'package:firebase_auth/firebase_auth.dart'; // Required for Firebase authentication
import 'package:firebase_storage/firebase_storage.dart'; // Required for Firebase storage
import 'package:google_sign_in/google_sign_in.dart'; // Required for Google Sign-In
import 'login.dart';  // Import the login page
import 'home.dart';   // Import the home page

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  File? _image; // File to store selected image
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isUploading = false; // To track upload status

  // Request camera permission
  Future<void> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      print("Camera permission granted");
    } else {
      print("Camera permission denied");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera permission is required to use this feature")),
      );
    }
  }

  // Pick image either from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      await _requestCameraPermission();
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

  // Method to show the image picker dialog
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

  // Method to upload image to Firebase Storage
  Future<void> _uploadImageToFirebase(File image) async {
    if (image == null) {
      print("No image selected");
      return; // Exit if no image is selected
    }

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

    try {
      setState(() {
        _isUploading = true; // Start uploading
      });
      UploadTask uploadTask = firebaseStorageRef.putFile(image);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      print("Upload complete: ${taskSnapshot.ref.fullPath}");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image uploaded successfully!")));
    } catch (e) {
      print("Upload failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload image: $e")));
    } finally {
      setState(() {
        _isUploading = false; // Finish uploading
      });
    }
  }

  // Method to register user with Firebase
  Future<void> _registerUser() async {
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password must be at least 6 characters long")),
      );
      return; // Exit if the password is too short
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // If the user is successfully created, upload the image
      if (_image != null) {
        await _uploadImageToFirebase(_image!);
      }

      // Navigate to the home page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print("Registration failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register: $e")));
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
      resizeToAvoidBottomInset: true, // Adjust layout for keyboard
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/hpbg1.png',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: SingleChildScrollView( // Allow scrolling when keyboard appears
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
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
