import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/image_proccessing/image_cropping.dart';

class ImageProccessing extends StatefulWidget {
  const ImageProccessing({super.key, required this.bytes});
  final Uint8List bytes;

  @override
  State<ImageProccessing> createState() => _ImageProccessingState();
}

class _ImageProccessingState extends State<ImageProccessing> {
  late final Image imgEditable = Image.memory(widget.bytes);

  void _gotoImageEditing() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ImageCropping(
                imageData: widget.bytes,
              )),
    );
  }

  static img.Image? convertBytesToImage(Uint8List B) {
    return img.decodeImage(B);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Image(
            image: Image.memory(widget.bytes).image,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.small(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.black87,
            onPressed: _gotoImageEditing,
            child: const Icon(Icons.mode_edit_sharp)));
  }
}
