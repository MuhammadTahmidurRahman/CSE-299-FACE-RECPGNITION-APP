import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class ArrangedPhotoPage extends StatefulWidget {
  final String eventCode;

  ArrangedPhotoPage({required this.eventCode});

  @override
  _ArrangedPhotoPageState createState() => _ArrangedPhotoPageState();
}

class _ArrangedPhotoPageState extends State<ArrangedPhotoPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _manualParticipants = [];

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
    _fetchManualParticipants();
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

  Future<void> _downloadImagesAsZip(List<String> imageUrls, String participantName) async {
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
              content: Text('Do you want to download this folder as a ZIP file?'),
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
          final sanitizedEventCode = widget.eventCode.replaceAll(RegExp(r'[^\w\s-]'), '');
          final sanitizedParticipantName = participantName.replaceAll(RegExp(r'[^\w\s-]'), '');
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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ZIP file saved to ${savedFile.path}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission is required.')),
        );
      }
    } catch (e) {
      print('Error downloading images as ZIP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save ZIP file.')),
      );
    }
  }

  // Updated function to send email using flutter_email_sender
  Future<void> _sendEmail(Map<String, dynamic> participant) async {
    final String email = participant['email'];
    final String name = participant['name'];
    final bool isManual = participant['isManual'];
    final String subject = 'Your Photos for ${widget.eventCode}';
    String body = '';

    if (isManual) {
      try {
        // Request storage permission
        if (await Permission.storage.request().isGranted ||
            await Permission.manageExternalStorage.request().isGranted) {

          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Center(child: CircularProgressIndicator());
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
          final sanitizedEventCode = widget.eventCode.replaceAll(RegExp(r'[^\w\s-]'), '');
          final sanitizedParticipantName = name.replaceAll(RegExp(r'[^\w\s-]'), '');
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
          final Email mail = Email(
            body: 'Please find attached your photos for the event "${widget.eventCode}".',
            subject: subject,
            recipients: [email],
            attachmentPaths: [savedFile.path],
            isHTML: false,
          );

          // Dismiss the loading indicator
          Navigator.pop(context);

          // Send the email
          await FlutterEmailSender.send(mail);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email sent to $email')),
          );
        } else {
          Navigator.pop(context); // Dismiss loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission is required.')),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Dismiss loading indicator
        print('Error sending email: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email.')),
        );
      }
    } else {
      // For regular participants, send email without attachment
      body = 'Hello $name,\n\nHere are your photos from the event "${widget.eventCode}".\n\nBest regards,\nEvent Team';

      final Email mail = Email(
        body: body,
        subject: subject,
        recipients: [email],
        isHTML: false,
      );

      try {
        await FlutterEmailSender.send(mail);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email sent to $email')),
        );
      } catch (e) {
        print('Error sending email: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email.')),
        );
      }
    }
  }

  Widget _buildParticipantItem(Map<String, dynamic> participant) {
    return GestureDetector(
      onTap: () async {
        final images = await _fetchImages(participant['folderPath']);
        if (images.isEmpty) {
          _showNoPhotosMessage();
        } else {
          _showImageGallery(images, participant['name'], participant['isManual'], participant);
        }
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: participant['photoUrl'] != null && participant['photoUrl'].isNotEmpty
              ? NetworkImage(participant['photoUrl'])
              : null,
          radius: 30,
          child: participant['photoUrl'] == null || participant['photoUrl'].isEmpty
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
        trailing: Icon(Icons.folder, color: Colors.blue),
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

  // Updated to include Send Mail button
  void _showImageGallery(List<String> images, String participantName, bool isManual, Map<String, dynamic> participant) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            children: [
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _downloadImagesAsZip(images, participantName);
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Arranged Photo',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/hpbg1.png', fit: BoxFit.cover),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Participants',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  ..._participants.map((participant) => _buildParticipantItem(participant)).toList(),
                  SizedBox(height: 16),
                  Text(
                    'Manual Guests',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  ..._manualParticipants.map((manualParticipant) => _buildParticipantItem(manualParticipant)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
