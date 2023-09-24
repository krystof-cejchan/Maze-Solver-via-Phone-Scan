import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:phone_client/image_transformation/image2graph.dart';

class ImageCropping extends StatefulWidget {
  const ImageCropping({Key? key, required this.imageData}) : super(key: key);
  final Uint8List imageData;

  @override
  State<ImageCropping> createState() => _ImageCroppingState(imageData);
}

class _ImageCroppingState extends State<ImageCropping>
    with WidgetsBindingObserver {
  _ImageCroppingState(this.imageData);

  final Uint8List imageData;
  final CropController _cropController = CropController();

  late Uint8List _croppedData = imageData;

  final Color backgroundColour = const Color.fromARGB(255, 0, 204, 17);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
          child: Crop(
            controller: _cropController,
            image: imageData,
            onCropped: (croppedData) => setState(() {
              _croppedData = croppedData;
            }),
            initialAreaBuilder: (rect) => Rect.fromLTRB(rect.left + 54,
                rect.top + 62, rect.right - 54, rect.bottom - 62),
            cornerDotBuilder: (size, edgeAlignment) =>
                const DotControl(color: Color.fromARGB(255, 0, 204, 17)),
            interactive: true,
            baseColor: backgroundColour,
            fixArea: false,
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndDocked,
        floatingActionButton: FloatingActionButton.small(
            backgroundColor: Colors.black87,
            foregroundColor: const Color.fromARGB(255, 75, 189, 0),
            onPressed: () => _crop(context),
            child: const Icon(Icons.done_all_rounded)));
  }

  void _crop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ImageTransformation(imageData: _croppedData)),
    );
  }
}
