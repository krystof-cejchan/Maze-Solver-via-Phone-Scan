import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path/path.dart';
import 'package:phone_client/image_transformation/image2graph.dart';

class ImageCropping extends StatefulWidget {
  const ImageCropping({Key? key, required this.imageData}) : super(key: key);
  final Uint8List imageData;

  @override
  State<ImageCropping> createState() => _ImageCroppingState(imageData);
}

class _ImageCroppingState extends State<ImageCropping> {
  _ImageCroppingState(this.imageData);
  final Uint8List imageData;

  final _cropController = CropController();
  Uint8List? _croppedData;
  final Color backgroundColour = const Color.fromARGB(255, 0, 204, 17);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Visibility(
                  visible: _croppedData == null,
                  replacement: Center(
                    child: _croppedData == null
                        ? const SizedBox.shrink()
                        : Image.memory(_croppedData!),
                  ),
                  child: Stack(
                    children: [
                      Crop(
                        controller: _cropController,
                        image: imageData,
                        onCropped: (croppedData) => setState(() {
                          _croppedData = croppedData;
                        }),
                        initialAreaBuilder: (rect) => Rect.fromLTRB(
                            rect.left + 54,
                            rect.top + 62,
                            rect.right - 54,
                            rect.bottom - 62),
                        cornerDotBuilder: (size, edgeAlignment) =>
                            const DotControl(
                                color: Color.fromARGB(255, 0, 204, 17)),
                        interactive: true,
                        baseColor: backgroundColour,
                      )
                    ],
                  ),
                ),
              ),
              if (_croppedData == null)
                Container(
                  color: Colors.amberAccent,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 1),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _crop(context),
                        child: const Text('Transform it!'),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _crop(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ImageTransformation(imageData: _croppedData!)),
    );
  }
}

Future<dynamic> _saveScreenShot(Uint8List bytes) async {
  var buffer = bytes.buffer.asUint8List();
  final result = await ImageGallerySaver.saveImage(buffer,
      quality: 100,
      name: join('maze_pic_', DateTime.now().toString()).toString());

  return result;
}
