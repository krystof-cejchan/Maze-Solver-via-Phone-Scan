import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageTransformation extends StatelessWidget {
  const ImageTransformation({Key? key, required this.imageData})
      : super(key: key);
  final Uint8List imageData;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.memory(imageData),
    );
  }
}
