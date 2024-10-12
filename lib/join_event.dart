import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Import the mobile scanner package

class JoinEventPage extends StatefulWidget {
  @override
  _JoinEventPageState createState() => _JoinEventPageState();
}

class _JoinEventPageState extends State<JoinEventPage> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notification click
            },
          ),
        ],
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Current Location',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            Text(
              'Dhaka, Bangladesh',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/hpbg1.png', // Replace with your background image asset
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // QR Code Icon
                Icon(
                  Icons.qr_code_rounded,
                  size: 120,
                  color: Colors.white,
                ),
                SizedBox(height: 30),

                // Scan to join button
                ElevatedButton(
                  onPressed: () {
                    // Open the QR scanner in a dialog
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Container(
                          width: 300,
                          height: 400,
                          child: MobileScanner(
                            controller: cameraController,
                            onDetect: (capture) {
                              // Accessing the list of barcodes detected
                              final List<Barcode> barcodes = capture.barcodes;
                              if (barcodes.isNotEmpty) {
                                // Getting the rawValue from the first barcode detected
                                final String? code = barcodes.first.rawValue;
                                if (code != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventPage(eventCode: code), // Pass the scanned event code to the event page
                                    ),
                                  );
                                  Navigator.of(context).pop(); // Close the dialog
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    backgroundColor: Colors.blue, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Scan to join',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // Input field for entering event code
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Enter event code to join',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Event Page after scanning QR code
class EventPage extends StatelessWidget {
  final String eventCode;

  EventPage({required this.eventCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Event Joined"),
      ),
      body: Center(
        child: Text("You've joined the event with code: $eventCode"),
      ),
    );
  }
}
