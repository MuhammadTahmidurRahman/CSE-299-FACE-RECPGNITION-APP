import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mysql1/mysql1.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  // Image picker to select the profile image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Function to handle user sign-up
  Future<void> _signUp() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields and upload a profile picture")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Authentication for user sign-up
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Upload profile picture to Firebase Storage
        UploadTask uploadTask = _storage
            .ref('profile_pictures/${user.uid}.jpg')
            .putFile(_imageFile!);

        TaskSnapshot snapshot = await uploadTask;
        String imageUrl = await snapshot.ref.getDownloadURL();

        // Save user info in Firebase Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'profile_picture': imageUrl,
        });

        // Connect with SQL (Assuming you have MySQL setup)
        await _saveToMySQL(user.uid, name, email, imageUrl);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign up successful!")));
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to save sign-up info in MySQL database
  Future<void> _saveToMySQL(String uid, String name, String email, String imageUrl) async {
    final conn = await MySqlConnection.connect(ConnectionSettings(
      host: 'your-mysql-host',  // e.g., 'localhost'
      port: 3306,
      user: 'your-username',   // MySQL username
      db: 'your-database',     // MySQL database name
      password: 'your-password',   // MySQL password
    ));

    await conn.query(
      'INSERT INTO users (uid, name, email, profile_picture) VALUES (?, ?, ?, ?)',
      [uid, name, email, imageUrl],
    );

    await conn.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile == null
                  ? CircleAvatar(
                radius: 40,
                child: Icon(Icons.camera_alt),
              )
                  : CircleAvatar(
                radius: 40,
                backgroundImage: FileImage(_imageFile!),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _signUp,
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
