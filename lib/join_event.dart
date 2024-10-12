import 'package:flutter/material.dart';

class JoinEventPage extends StatefulWidget {
  @override
  _JoinEventPageState createState() => _JoinEventPageState();
}

class _JoinEventPageState extends State<JoinEventPage> {
  final _roomCodeController = TextEditingController();

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  // Dummy function to simulate joining the event
  void _joinEvent() {
    String roomCode = _roomCodeController.text.trim();

    if (roomCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid room code.')),
      );
    } else {
      // Simulate event joining
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joining event with code: $roomCode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Event'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Event Code',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _roomCodeController,
              decoration: InputDecoration(
                labelText: 'Event Code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _joinEvent,
                child: Text('Join Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
