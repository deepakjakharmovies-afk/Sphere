import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoViewScreen extends StatelessWidget {
  final String imagePath;

  const PhotoViewScreen({Key? key, required this.imagePath}) : super(key: key);

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Request permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission denied")),
        );
        return;
      }

      // Load image bytes from asset
      final byteData = await rootBundle.load(imagePath);
      final result = await ImageGallerySaver.saveImage(
        Uint8List.view(byteData.buffer),
        quality: 100,
        name: "downloaded_image",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Image saved to gallery")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error saving image: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo View')),
      body: Center(
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveImage(context),
        label: Text("Download"),
        icon: Icon(Icons.download),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
