import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'eventroom.dart';

class JoinEventPage extends StatefulWidget {
  @override
  _JoinEventPageState createState() => _JoinEventPageState();
}

class _JoinEventPageState extends State<JoinEventPage> {
  MobileScannerController cameraController = MobileScannerController();
  String scannedCode = '';
  String enteredCode = '';
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;
  String userName = '';
  String userEmail = '';
  String userPhotoUrl = '';

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userName = user!.displayName ?? 'Guest';
      userEmail = user!.email ?? 'guest@example.com';
      userPhotoUrl = user!.photoURL ?? '';
    }
  }

  Future<void> _joinRoomAsGuest(String eventCode, String roomName) async {
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to join the room!')),
      );
      return;
    }

    final guestData = {
      'guestId': user!.uid,
      'guestName': userName,
      'guestEmail': userEmail,
      'guestPhotoUrl': userPhotoUrl,
    };

    String sanitizedEmail = userEmail.replaceAll('.', '_');
    String compositeKey = '${eventCode}_${roomName}_${sanitizedEmail}_${userName}';

    final guestRef = _databaseRef.child('rooms/$eventCode/guests/$compositeKey');
    final guestSnapshot = await guestRef.get();

    if (!guestSnapshot.exists) {
      await guestRef.set(guestData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have already joined this room!')),
      );
    }

    FirebaseAuth.instance.userChanges().listen((user) async {
      if (user != null && user.uid == guestData['guestId']) {
        final updatedName = user.displayName ?? userName;
        final updatedPhotoUrl = user.photoURL ?? userPhotoUrl;

        await guestRef.update({
          'guestName': updatedName,
          'guestPhotoUrl': updatedPhotoUrl,
        });
      }
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EventRoom(eventCode: eventCode),
      ),
    );
  }

  Future<void> _navigateToEventRoom(String code) async {
    final snapshot = await _databaseRef.child('rooms/$code').get();

    if (snapshot.exists) {
      final roomData = snapshot.value as Map<dynamic, dynamic>;
      final roomName = roomData['roomName'] ?? 'No Room Name';
      await _joinRoomAsGuest(code, roomName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room does not exist!')),
      );
    }
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Spacer(),
                      Text(
                        'Join Room',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Spacer(flex: 2),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_rounded,
                            size: 120,
                            color: Colors.black,
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => StatefulBuilder(
                                  builder: (context, setState) {
                                    return Dialog(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (scannedCode.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Scanned Code: $scannedCode',
                                                style: TextStyle(fontSize: 16, color: Colors.black),
                                              ),
                                            ),
                                          Container(
                                            width: 300,
                                            height: 400,
                                            child: MobileScanner(
                                              controller: cameraController,
                                              onDetect: (capture) async {
                                                final List<Barcode> barcodes = capture.barcodes;
                                                if (barcodes.isNotEmpty) {
                                                  final String? code = barcodes.first.rawValue;

                                                  if (code != null && code != scannedCode) {
                                                    setState(() {
                                                      scannedCode = code;
                                                    });

                                                    final snapshot = await _databaseRef.child('rooms/$code').get();
                                                    if (snapshot.exists) {
                                                      final roomData = snapshot.value as Map<dynamic, dynamic>;
                                                      final roomName = roomData['roomName'] ?? 'No Room Name';

                                                      Navigator.of(context).pop();
                                                      await _joinRoomAsGuest(code, roomName);
                                                    } else {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text("The room doesn't exist!")),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancel'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              backgroundColor: Colors.black,
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
                          TextField(
                            onChanged: (value) {
                              enteredCode = value.trim();
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Enter event code to join',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _navigateToEventRoom(enteredCode);
                            },
                            child: Text(
                              'Go to EventRoom',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
