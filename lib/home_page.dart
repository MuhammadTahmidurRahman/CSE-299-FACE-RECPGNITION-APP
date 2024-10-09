// home_page.dart
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Room'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blueAccent, Colors.grey.shade200],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Current Location\nDhaka, Bangladesh',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Generate event code', style: TextStyle(fontSize: 18)),
                    Switch(value: true, onChanged: (val) {}),
                  ],
                ),

                // Event code
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ISKX6QUY', style: TextStyle(fontSize: 24)),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () {
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Generate QR Code Button
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Generate QR Code'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),

                SizedBox(height: 20),

                // QR Code Image
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.qr_code, size: 120, color: Colors.blueAccent),
                ),
              ],
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,  // Home is selected
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Event',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Photos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation between pages if necessary
        },
      ),
    );
  }
}
