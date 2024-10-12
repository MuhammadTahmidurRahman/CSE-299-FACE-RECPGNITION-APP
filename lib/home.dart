import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'; // For copying to clipboard
import 'package:path_provider/path_provider.dart'; // For saving the QR code image
import 'dart:io'; // For File handling
import 'dart:ui' as ui; // For capturing the QR image
import 'package:pretty_qr_code/pretty_qr_code.dart'; // Import the pretty_qr_code package
import 'join_event_page.dart'; // Join event page
import 'createorjoinroom.dart'; // Import CreateOrJoinRoomPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _eventCode = '';  // Initially empty
  bool _isEventCodeGenerated = false;
  String _qrData = '';
  GlobalKey _qrKey = GlobalKey();  // Key for QR widget

  // Function to generate a random event code
  String _generateEventCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    return String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }

  // Function to generate a QR code
  void _generateQrCode() {
    setState(() {
      _qrData = _generateEventCode();  // Generate a new unique code for QR
      _isEventCodeGenerated = true;    // Show the event code
    });
  }

  // Function to capture and save the QR code as an image file
  Future<void> _saveQrCode() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/qr_code.png');
      await file.writeAsBytes(buffer);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR Code saved at ${file.path}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save QR Code: $e')));
    }
  }

  // Function to share the QR code (this could integrate with a sharing package)
  void _shareQrCode() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share QR code logic')));
  }

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
          Image.asset(
            'assets/hpbg1.png',  // Background image
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Current location display
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Current Location\nDhaka, Bangladesh',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // Event code generation button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Generate event code', style: TextStyle(fontSize: 18, color: Colors.white)),
                    Switch(
                      value: _isEventCodeGenerated,
                      onChanged: (val) {
                        if (!_isEventCodeGenerated) {
                          setState(() {
                            _eventCode = _generateEventCode();  // Generate event code on button click
                            _isEventCodeGenerated = true;
                          });
                        }
                      },
                    ),
                  ],
                ),

                if (_isEventCodeGenerated) // Only show the event code if it's generated
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_eventCode, style: TextStyle(fontSize: 24)),
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _eventCode));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied to clipboard!')));
                          },
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _generateQrCode,  // Generate QR code when pressed
                  child: Text('Generate QR Code'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),

                SizedBox(height: 20),

                // Display the QR code if generated
                if (_qrData.isNotEmpty)
                  Column(
                    children: [
                      RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          height: 150,
                          width: 150,
                          child: PrettyQr(
                            // Using PrettyQr to generate the QR code
                            data: _qrData,
                            size: 200.0,
                            roundEdges: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.download),
                            onPressed: _saveQrCode,  // Save QR code logic
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: _shareQrCode,  // Share QR code logic
                          ),
                        ],
                      ),
                    ],
                  ),

                SizedBox(height: 30),

                // Join Room Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JoinEventPage()),  // Navigate to JoinEventPage
                    );
                  },
                  child: Text('Join Room'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),

                SizedBox(height: 20),

                // Back to Home Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateOrJoinRoomPage()),  // Navigate back to CreateOrJoinRoomPage
                    );
                  },
                  child: Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
