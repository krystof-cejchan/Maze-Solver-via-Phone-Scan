import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageProccessing extends StatelessWidget {
  ImageProccessing({super.key, required this.bytes});
  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: Center(
        child: Image(
          image: Image.memory(bytes).image,
        ),
      ),
    );
  }

  img.Image? _convertBytesToImage(Uint8List B) {
    return img.decodeImage(B);
  }
}
