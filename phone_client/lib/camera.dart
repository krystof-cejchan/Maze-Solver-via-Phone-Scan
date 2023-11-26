import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_client/hero_tag/hero_tag_generator.dart';
import 'package:phone_client/image_proccessing/colour_picking/route_colour_picker.dart';
import './helpers/custom_image_class.dart' as custom;
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen(this.camera, {super.key});
  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureAndSaveImage() async {
    if (!_controller.value.isTakingPicture) {
      await _controller.setFlashMode(FlashMode.off);
      await _controller.setFocusMode(FocusMode.auto);

      final xFile = await _controller.takePicture();
      custom.Image customImage = custom.Image(
        img.decodeImage(
          File(
            xFile.path,
          ).readAsBytesSync(),
        )!,
        path: xFile.path,
      );

      //File(xFile.path).deleteSync();
      if (customImage.isValid()) {
        _openImageInNewRoute(customImage);
      }
    }
  }

  void _openImageInNewRoute(custom.Image data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColorPickerWidget(
          image: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  Expanded(
                    child: CameraPreview(_controller),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: HeroTag.distinguisher,
              backgroundColor: Colors.green,
              foregroundColor: Colors.black87,
              onPressed: _captureAndSaveImage,
              label: const Text(
                'Take a photo',
                style: TextStyle(letterSpacing: 1.1),
              ),
              icon: const Icon(Icons.camera_alt_rounded),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton.extended(
              heroTag: HeroTag.distinguisher,
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white70,
              onPressed: _browseGallery,
              label: const Text(
                'Pick from Gallery',
                style: TextStyle(fontSize: 10, letterSpacing: .7),
              ),
              icon: const Icon(Icons.image_search_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _browseGallery() async {
    final XFile? pickedImg = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (pickedImg == null) return;

    custom.Image customImage = custom.Image(
      img.decodeImage(await File(pickedImg.path).readAsBytes())!,
      path: pickedImg.path,
    );

    //File(pickedImg.path).deleteSync();
    if (customImage.isValid()) {
      _openImageInNewRoute(customImage);
    }
  }
}
