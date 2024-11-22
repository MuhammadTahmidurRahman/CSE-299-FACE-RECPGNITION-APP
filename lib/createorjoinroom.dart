import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'create_event.dart';
import 'join_event.dart';
import 'profile.dart';
import 'eventroom.dart';

class CreateOrJoinRoomPage extends StatefulWidget {
  @override
  _CreateOrJoinRoomPageState createState() => _CreateOrJoinRoomPageState();
}

class _CreateOrJoinRoomPageState extends State<CreateOrJoinRoomPage> {
  int _selectedIndex = 0;

  // Function to handle bottom navigation bar tap
  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Navigate to the EventRoom page when a room is tapped
  void _navigateToEventRoom(String roomCode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventRoom(eventCode: roomCode),
      ),
    );
  }

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
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Text(
                      'My Rooms',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.7),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
                    : Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      return _buildRoomCard(
                        rooms[index]['roomName']!,
                        rooms[index]['hostName']!,
                        rooms[index]['roomCode']!,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CreateEventPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                        child: Center(
                          child: Text(
                            'Create Room',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => JoinEventPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                        child: Center(
                          child: Text(
                            'Join Room',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
