import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:phone_client/image_transformation/image2routes.dart';
import '../helpers/custom_image_class.dart' as custom;

class ImageCropping extends StatefulWidget {
  const ImageCropping(
      {Key? key, required this.image, required this.pixelColour})
      : super(key: key);
  final custom.Image image;
  final Color pixelColour;

  @override
  State<ImageCropping> createState() => _ImageCroppingState();
}

class _ImageCroppingState extends State<ImageCropping>
    with WidgetsBindingObserver {
  final CropController _cropController = CropController();

  // ignore: unused_field
  late Uint8List _croppedData = widget.image.bytes;

  //final Color backgroundColour = const Color.fromARGB(255, 0, 204, 17);
  late final Color backgroundColour = widget.pixelColour;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
          child: Crop(
            controller: _cropController,
            image: widget.image.bytes,
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
          //uncomment when cropping works
          //builder: (context) => ImageConversion(custom.Image(_croppedData))),
          builder: (context) =>
              ImageConversion(widget.image, widget.pixelColour)),
    );
  }
}
