import 'package:flutter/material.dart';

class CreateOrJoinRoomPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create or Join Room'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Create or Join Room Page'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the Home Page
                Navigator.pop(context);
              },
              child: Text('Back to Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
