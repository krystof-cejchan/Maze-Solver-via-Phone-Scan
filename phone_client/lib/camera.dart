import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:phone_client/helpers/camera_resolution_px.dart';
import 'package:phone_client/image_proccessing/colour_picking/route_colour_picker.dart';
import './helpers/custom_image_class.dart' as custom;
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);
  static const _res = ResolutionPreset.veryHigh;
  static final cameraPhotoResolution =
      CameraResolutionPixels.fromResolutionPreset(_res);
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
      CameraScreen._res,
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
      img.Image image = img.decodeImage(File(xFile.path).readAsBytesSync())!;
      custom.Image customImage = custom.Image(image);
      if (image.isValid) {
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
              )),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          foregroundColor: Colors.black87,
          onPressed: _captureAndSaveImage,
          label: const Text('Take a photo'),
          icon: const Icon(Icons.photo_camera_front_rounded),
        ),
      ),
    );
  }
}
