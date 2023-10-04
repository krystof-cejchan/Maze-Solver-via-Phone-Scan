import 'package:flutter/material.dart';
import 'package:phone_client/image_proccessing/colour_picker.dart';
import '../helpers/custom_image_class.dart' as custom;

class ImageProccessing extends StatefulWidget {
  const ImageProccessing({super.key, required this.image});
  final custom.Image image;

  @override
  State<ImageProccessing> createState() => _ImageProccessingState();
}

class _ImageProccessingState extends State<ImageProccessing> {
  void _gotoImageEditing() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ColorPickerWidget(
                image: widget.image,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Image(
            image: Image.memory(widget.image.bytes).image,
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
