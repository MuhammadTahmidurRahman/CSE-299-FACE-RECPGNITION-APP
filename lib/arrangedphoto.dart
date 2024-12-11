import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/services.dart'; // <-- Added import for PlatformException
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class ArrangedPhotoPage extends StatefulWidget {
  final String eventCode;
  final ScrollController _participantsController = ScrollController();
  final ScrollController _manualGuestsController = ScrollController();
  ArrangedPhotoPage({required this.eventCode});

  @override
  _ArrangedPhotoPageState createState() => _ArrangedPhotoPageState();
}

class _ArrangedPhotoPageState extends State<ArrangedPhotoPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _manualParticipants = [];
  String _roomName = '';
  bool _isPhotosSent = false; // Track if photos are sent

  @override
  void initState() {
    super.initState();
    _fetchRoomName();
    _fetchParticipants();
    _fetchManualParticipants();

    // Assuming you have access to the eventCode (e.g., from the widget)
    incrementSortPhotoRequest(widget.eventCode);
  }

  // Function to fetch room name from Firebase
  Future<void> _fetchRoomName() async {
    try {
      final ref = _database.ref('rooms/${widget.eventCode}/roomName');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        setState(() {
          _roomName = snapshot.value as String;
        });
      } else {
        setState(() {
          _roomName = 'Unknown Room';
        });
      }
    } catch (e) {
      print('Error fetching room name: $e');
      setState(() {
        _roomName = 'Unknown Room';
      });
    }
  }

  Future<void> _fetchParticipants() async {
    final ref = _database.ref('rooms/${widget.eventCode}/participants');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((participantId, participantData) {
        _participants.add({
          'id': participantId,
          'name': participantData['name'] ?? '',
          'email': participantData['email'] ?? '', // Fetch email
          'photoUrl': participantData['photoUrl'] ?? '',
          'folderPath': 'rooms/${widget.eventCode}/$participantId/photos',
          'isManual': false, // Indicate participant type
        });
      });
      setState(() {});
    }
  }

  Future<void> _fetchManualParticipants() async {
    final ref = _database.ref('rooms/${widget.eventCode}/manualParticipants');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((manualParticipantId, participantData) {
        _manualParticipants.add({
          'id': manualParticipantId,
          'name': participantData['name'] ?? '',
          'email': participantData['email'] ?? '', // Fetch email
          'photoUrl': participantData['photoUrl'] ?? '',
          'folderPath': 'rooms/${widget.eventCode}/$manualParticipantId/photos',
          'isManual': true, // Indicate participant type
        });
      });
      setState(() {});
    }
  }

  Future<List<String>> _fetchImages(String folderPath) async {
    try {
      final ref = _storage.ref(folderPath);
      final listResult = await ref.listAll();

      List<String> imageUrls = [];
      for (var item in listResult.items) {
        final url = await item.getDownloadURL();
        imageUrls.add(url);
      }
      return imageUrls;
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  Future<void> _downloadImagesAsZip(List<String> imageUrls,
      String participantName) async {
    try {
      // Request storage permission
      if (await Permission.storage.request().isGranted ||
          await Permission.manageExternalStorage.request().isGranted) {
        // Show confirmation dialog before downloading
        final confirmDownload = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Confirm Download'),
              content: Text(
                  'Do you want to download this folder as a ZIP file?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes'),
                ),
              ],
            );
          },
        );

        if (confirmDownload == true) {
          // Show downloading dialog using root navigator
          showDialog(
            context: context,
            useRootNavigator: true, // Use root navigator to manage dialogs consistently
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Expanded(child: Text('Downloading...')),
                  ],
                ),
              );
            },
          );

          // Temporary directory for intermediate processing
          final tempDir = await getTemporaryDirectory();
          final zipFilePath = '${tempDir.path}/images.zip';

          // Create ZIP file
          final encoder = ZipFileEncoder();
          encoder.create(zipFilePath);

          // Add images to ZIP
          for (int i = 0; i < imageUrls.length; i++) {
            final imageUrl = imageUrls[i];
            final imageName = 'image_$i.jpg';

            // Download image to a temporary file
            final response = await HttpClient().getUrl(Uri.parse(imageUrl));
            final tempFile = File('${tempDir.path}/$imageName');
            final imageStream = await response.close();
            await imageStream.pipe(tempFile.openWrite());

            // Add the file to the ZIP archive
            encoder.addFile(tempFile);

            // Clean up the temporary file
            await tempFile.delete();
          }

          encoder.close();

          // Define dynamic ZIP file name
          final sanitizedEventCode = widget.eventCode.replaceAll(
              RegExp(r'[^\w\s-]'), '');
          final sanitizedParticipantName = participantName.replaceAll(
              RegExp(r'[^\w\s-]'), '');
          final zipFileName = '${sanitizedEventCode}_$sanitizedParticipantName.zip';

          // Save the ZIP file to the Downloads directory
          final downloadsPath = '/storage/emulated/0/Download'; // General Downloads path
          final savePath = '$downloadsPath/$zipFileName';

          // Ensure the Downloads directory exists
          final downloadsDir = Directory(downloadsPath);
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }

          // Copy the ZIP file to Downloads
          final savedFile = await File(zipFilePath).copy(savePath);

          // Dismiss the downloading dialog
          Navigator.pop(context);

          // **Show download complete dialog using root navigator after a slight delay**
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              useRootNavigator: true, // Ensures the dialog appears above all others
              builder: (context) {
                return AlertDialog(
                  title: Text('Download Complete'),
                  content: Text('ZIP file saved to ${savedFile.path}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission is required.')),
        );
      }
    } catch (e) {
      // Dismiss the downloading dialog if open
      Navigator.pop(context);
      print('Error downloading images as ZIP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save ZIP file.')),
      );
    }
  }

  Future<void> incrementSortPhotoRequest(String eventCode) async {
    final DatabaseReference hostRef = FirebaseDatabase.instance
        .ref('rooms/$eventCode/host');

    try {
      // Get the current sortPhotoRequest value
      final snapshot = await hostRef.get();

      double currentSortValue = 0.0;  // Default to 0.0 if not found

      if (snapshot.exists) {
        final hostData = snapshot.value as Map<dynamic, dynamic>?;
        if (hostData != null && hostData.containsKey('sortPhotoRequest')) {
          final dynamic currentValue = hostData['sortPhotoRequest'];

          // Check if the value is an int or a double, and ensure it's a double
          if (currentValue is int) {
            currentSortValue = currentValue.toDouble();
          } else if (currentValue is double) {
            currentSortValue = currentValue;
          }
        }
      }

      // Increment the value by 1
      final newSortValue = currentSortValue + 1.0;

      // Update the sortPhotoRequest field in the database while preserving existing data
      await hostRef.update({
        'sortPhotoRequest': newSortValue,
      });

      print("sortPhotoRequest incremented to: $newSortValue");
    } catch (e) {
      print('Error updating sortPhotoRequest: $e');
    }
  }

  // Updated function to send email using flutter_email_sender with enhanced email content
  Future<void> _sendEmail(Map<String, dynamic> participant) async {
    final String email = participant['email'];
    final String name = participant['name'];
    final bool isManual = participant['isManual'];
    final String subject = 'Your Photos from $_roomName (${widget.eventCode})';
    String body = '';

    if (isManual) {
      try {
        // Request storage permission
        if (await Permission.storage.request().isGranted ||
            await Permission.manageExternalStorage.request().isGranted) {
          // Show "Please wait" dialog
          showDialog(
            context: context,
            useRootNavigator: true, // Use root navigator for consistency
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Expanded(child: Text('Please wait while your email is being created...')),
                  ],
                ),
              );
            },
          );

          // Temporary directory for intermediate processing
          final tempDir = await getTemporaryDirectory();
          final zipFilePath = '${tempDir.path}/images.zip';

          // Create ZIP file
          final encoder = ZipFileEncoder();
          encoder.create(zipFilePath);

          // Fetch images
          final images = await _fetchImages(participant['folderPath']);
          for (int i = 0; i < images.length; i++) {
            final imageUrl = images[i];
            final imageName = 'image_$i.jpg';

            // Download image to a temporary file
            final response = await HttpClient().getUrl(Uri.parse(imageUrl));
            final tempFile = File('${tempDir.path}/$imageName');
            final imageStream = await response.close();
            await imageStream.pipe(tempFile.openWrite());

            // Add the file to the ZIP archive
            encoder.addFile(tempFile);

            // Clean up the temporary file
            await tempFile.delete();
          }

          encoder.close();

          // Define dynamic ZIP file name
          final sanitizedEventCode = widget.eventCode.replaceAll(
              RegExp(r'[^\w\s-]'), '');
          final sanitizedParticipantName = name.replaceAll(
              RegExp(r'[^\w\s-]'), '');
          final zipFileName = '${sanitizedEventCode}_$sanitizedParticipantName.zip';

          // Save the ZIP file to the Downloads directory
          final downloadsPath = '/storage/emulated/0/Download'; // General Downloads path
          final savePath = '$downloadsPath/$zipFileName';

          // Ensure the Downloads directory exists
          final downloadsDir = Directory(downloadsPath);
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }

          // Copy the ZIP file to Downloads
          final savedFile = await File(zipFilePath).copy(savePath);

          // Prepare the email with attachment
          body = 'Hello $name,\n\n'
              'We are pleased to share with you the sorted photos of yours from the event $_roomName. '
              'Please find your photos from the event in the attached file.\n\n'
              'Best regards,\n'
              'Your Event Team\nDeveloped By:\nTahmid, Disha, Anika from NSU';

          final Email mail = Email(
            body: body,
            subject: subject,
            recipients: [email],
            attachmentPaths: [savedFile.path],
            isHTML: false,
          );

          // Send the email
          try {
            await FlutterEmailSender.send(mail);
            // Dismiss the "Please wait" dialog
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email sent to $email')),
            );
          } on PlatformException catch (ex) {
            // Dismiss the "Please wait" dialog
            Navigator.pop(context);
            if (ex.code == 'not_available') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(
                    'No email client found on this device. Please install an email app.')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(
                    'Failed to send email. Error: ${ex.message}')),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission is required.')),
          );
        }
      } catch (e) {
        // Dismiss the "Please wait" dialog in case of error
        Navigator.pop(context);
        print('Error sending email: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email.')),
        );
      }
    } else {
      // For regular participants, send email without attachment
      body = 'Hello $name,\n\n'
          'Your Photos have been sorted! Hurrah!!! Check our website at pictora.netlify.app or our app Pictora to get the photos from $_roomName (${widget.eventCode}).\n\n'
          'Best regards,\n'
          'Your Event Team\nDeveloped By:\nTahmid, Disha, Anika from NSU';

      final Email mail = Email(
        body: body,
        subject: subject,
        recipients: [email],
        isHTML: false,
      );

      try {
        // Show "Please wait" dialog
        showDialog(
          context: context,
          useRootNavigator: true, // Use root navigator for consistency
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Expanded(child: Text('Please wait while your email is being sent...')),
                ],
              ),
            );
          },
        );

        await FlutterEmailSender.send(mail);
        // Dismiss the "Please wait" dialog
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent to $email')),
        );
      } on PlatformException catch (ex) {
        // Dismiss the "Please wait" dialog
        Navigator.pop(context);
        if (ex.code == 'not_available') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(
                'No email client found on this device. Please install an email app.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to send email. Error: ${ex.message}')),
          );
        }
      } catch (e) {
        // Dismiss the "Please wait" dialog
        Navigator.pop(context);
        print('Error sending email: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email.')),
        );
      }
    }
  }

  // New function to send email to all participants
  Future<void> _sendEmailToAll() async {
    final List<String> emails =
    _participants.map((participant) => participant['email'] as String).toList();
    // Exclude manual guests' emails

    if (emails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No participants to send email to.')),
      );
      return;
    }

    final String subject = 'Your Photos from $_roomName (${widget.eventCode})';
    final String body = 'Hello everyone,\n\n'
        'Your Photos have been sorted! Hurrah!!! Check our website at pictora.netlify.app or our app Pictora to get the photos from $_roomName (${widget.eventCode}).\n\n'
        'Best regards,\n'
        'Your Event Team\nDeveloped By:\nTahmid, Disha, Anika from NSU';

    final Email mail = Email(
      body: body,
      subject: subject,
      recipients: emails,
      isHTML: false,
    );

    try {
      // Show "Please wait" dialog
      showDialog(
        context: context,
        useRootNavigator: true, // Use root navigator for consistency
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Expanded(child: Text('Please wait while your email is being sent...')),
              ],
            ),
          );
        },
      );

      await FlutterEmailSender.send(mail);
      // Dismiss the "Please wait" dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sent to all participants')),
      );
    } on PlatformException catch (ex) {
      // Dismiss the "Please wait" dialog
      Navigator.pop(context);
      if (ex.code == 'not_available') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              'No email client found on this device. Please install an email app.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email. Error: ${ex.message}')),
        );
      }
    } catch (e) {
      // Dismiss the "Please wait" dialog
      Navigator.pop(context);
      print('Error sending email to all: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send email to all participants.')),
      );
    }
  }

  Widget _buildParticipantItem(Map<String, dynamic> participant) {
    return GestureDetector(
      onTap: () async {
        // Show image gallery dialog with loading indicator
        showDialog(
          context: context,
          useRootNavigator: true, // Use root navigator for consistency
          builder: (context) {
            return Dialog(
              child: FutureBuilder<List<String>>(
                future: _fetchImages(participant['folderPath']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Show loading indicator while fetching images
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 20),
                          Expanded(child: Text('Loading photos...')),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // Show error message
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to load photos.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    );
                  } else {
                    final images = snapshot.data ?? [];
                    if (images.isEmpty) {
                      return AlertDialog(
                        title: Text('No Photos'),
                        content: Text('No photos uploaded for this participant.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          // Gallery Section
                          Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.all(8.0),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return Image.network(images[index], fit: BoxFit.cover);
                              },
                            ),
                          ),
                          // Buttons Section
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await _downloadImagesAsZip(images, participant['name']);
                                      Navigator.pop(context); // Close dialog after download
                                    },
                                    icon: Icon(Icons.download),
                                    label: Text('Download All'),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      await _sendEmail(participant);
                                    },
                                    icon: Icon(Icons.mail),
                                    label: Text('Send Mail'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green, // Correctly updated
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  }
                },
              ),
            );
          },
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: participant['photoUrl'] != null &&
              participant['photoUrl'].isNotEmpty
              ? NetworkImage(participant['photoUrl'])
              : null,
          radius: 30,
          child: participant['photoUrl'] == null ||
              participant['photoUrl'].isEmpty
              ? Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              participant['name'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              participant['email'],
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        trailing: Icon(Icons.folder, color: Colors.black),
      ),
    );
  }

  void _showNoPhotosMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('No Photos'),
          content: Text('No photos uploaded for this participant.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  final ScrollController _participantsController = ScrollController();
  final ScrollController _manualGuestsController = ScrollController();

  @override
  void dispose() {
    // Dispose of your ScrollControllers
    _participantsController.dispose();
    _manualGuestsController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // Removed the AppBar to allow the background image to occupy the entire screen
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/hpbg1.png',
              fit: BoxFit.cover,
            ),
          ),
          // Overlayed Buttons and Content
          SafeArea(
            child: Column(
              children: [
                // Top Row with Back Button and Send Email to All Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Title in the Middle
                    Text(
                      'Arranged Photo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // Send Email to All Participants Button
                    IconButton(
                      icon: Icon(Icons.email, color: Colors.black),
                      onPressed: _sendEmailToAll,
                      tooltip: 'Send Email to All Participants',
                    ),
                  ],
                ),
                // Participants and Manual Guests List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // Center-align the content
                      children: [
                        // Participants Section
                        Center(
                          child: Text(
                            'Participants',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),

                        // Scrollable Participants List
                        Expanded(
                          child: Scrollbar(
                            controller: _participantsController,
                            child: SingleChildScrollView(
                              controller: _participantsController,
                              child: Column(
                                children: _participants
                                    .map((participant) => _buildParticipantItem(participant))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8), // Reduced space to move Manual Guests up slightly
                        // Manual Guests Section (Moved up a bit)
                        Center(
                          child: Text(
                            'Manual Guests',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // Scrollable Manual Guests List
                        Expanded(
                          child: Scrollbar(
                            controller: _manualGuestsController,
                            child: SingleChildScrollView(
                              controller: _manualGuestsController,
                              child: Column(
                                children: _manualParticipants
                                    .map((manualParticipant) => _buildParticipantItem(manualParticipant))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
