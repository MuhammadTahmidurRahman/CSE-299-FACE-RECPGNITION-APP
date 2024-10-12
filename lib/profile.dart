import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login.dart'; // Import your login page for sign-out

class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current logged-in user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black, // Customize the app bar color
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut(); // Also sign out from Google if signed in via Google

              // Navigate back to the LoginPage after signing out
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                user?.displayName ?? 'Anonymous User',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                user?.email ?? 'No Email',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            SizedBox(height: 40),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              onTap: () {
                // Logic to edit the profile (you can create a separate edit profile page)
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Logic to open settings page (if needed)
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                // Logic to open help page (if needed)
              },
            ),
          ],
        ),
      ),
    );
  }
}
