import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PhotoGalleryPage extends StatefulWidget {
  final String eventCode;
  final String folderName;
  final String userId;

  PhotoGalleryPage({
    required this.eventCode,
    required this.folderName,
    required this.userId,
  });

  @override
  _PhotoGalleryPageState createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> _photoUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please sign in to view photos.")),
      );
      return;
    }

    try {
      final DatabaseReference ref = FirebaseDatabase.instance.ref();
      final DataSnapshot snapshot = await ref
          .child("rooms")
          .child(widget.eventCode)
          .child("participants")
          .child(widget.userId)
          .child("folderPath")
          .get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Photo folder path not found.")),
        );
        return;
      }

      final String folderPath = snapshot.value as String;
      print("Folder Path: $folderPath"); // Debug line for path

      // Fetch images from Firebase Storage
      final ListResult result = await _storage.ref(folderPath).listAll();
      print("Number of images found: ${result.items.length}"); // Log item count

      if (result.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No images found in the folder.")),
        );
      }

      final urls = await Future.wait(result.items.map((item) async {
        final url = await item.getDownloadURL();
        print("Fetched URL: $url"); // Log each fetched URL
        return url;
      }).toList());

      setState(() {
        _photoUrls = urls;
      });
    } catch (e) {
      print("Error loading photos: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading photos")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Gallery'),
        backgroundColor: Colors.black,
      ),
      body: _photoUrls.isEmpty
          ? Center(child: Text("No photos uploaded.", style: TextStyle(fontSize: 18)))
          : GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: _photoUrls.length,
        itemBuilder: (context, index) {
          return Image.network(_photoUrls[index], fit: BoxFit.cover);
        },
      ),
    );
  }
}