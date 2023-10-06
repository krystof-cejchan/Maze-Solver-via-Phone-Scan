  /* List<List<String>> _convertImageToArray(
    img.Image imgSource,
  ) {
    final List<List<String>> area = List.empty(growable: true);
    for (var i = 0; i < imgSource.width; i += 5) {
      List<String> line = List.empty(growable: true);
      for (var j = 0; j < imgSource.height; j += 5) {
        line.add(_isPixelSimilarToColour(imgSource.getPixel(i, j)) ? "R" : "W");
      }
      area.add(line);
    }
    return area;
  }*/

   /*img.Image _pixelsToImage(int w, int h, List<img.Color> colourPixels) {
    if (w * h != colourPixels.length) {
      throw PictureSizeDoesNotMatchArrayLength();
    }
    img.Image image = img.Image(width: w, height: h);
    for (int i = 0; i < colourPixels.length; i += 5) {
      var x = i ~/ w, y = i % w;
      image.setPixel(x, y, colourPixels[i]);
    }
    return image;
  }*/



















  /*
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
    _controller =
        CameraController(widget.camera, CameraScreen._res, enableAudio: false);
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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton.extended(
                backgroundColor: Colors.green,
                foregroundColor: Colors.black87,
                onPressed: _captureAndSaveImage,
                label: const Text('Take a photo'),
                icon: const Icon(Icons.photo_camera_front_rounded))));
  }
}

   */













   /*import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phone_client/image_proccessing/colour_picking/route_colour_picker.dart';
import './helpers/custom_image_class.dart' as custom;
import 'package:image/image.dart' as img;

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraPage(),
    );
  }
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: CameraAwesomeBuilder.awesome(
          saveConfig: SaveConfig.photo(pathBuilder: () async {
            final Directory extDir = await getTemporaryDirectory();
            final testDir = await Directory(
              '${extDir.path}/maze_photos',
            ).create(recursive: true);

            return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
          }),
          enablePhysicalButton: true,
          sensor: Sensors.back,
          flashMode: FlashMode.auto,
          enableAudio: false,
          aspectRatio: CameraAspectRatios.ratio_16_9,
          previewFit: CameraPreviewFit.fitWidth,
          onMediaTap: (mediaCapture) =>
              _openImageInNewRoute(mediaCapture, context),
        ),
      ),
    );
  }

  void _openImageInNewRoute(MediaCapture mc, BuildContext c) async {
    var a = await _compressFile(File(mc.filePath));
    custom.Image image = custom.Image(img.decodeImage(a.readAsBytesSync())!);
    // ignore: use_build_context_synchronously
    Navigator.push(
      c,
      MaterialPageRoute(
          builder: (context) => ColorPickerWidget(
                image: image,
              )),
    );
  }

  Future<File> _compressFile(File file) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 25,
    );
    return compressedFile;
  }
}
 */