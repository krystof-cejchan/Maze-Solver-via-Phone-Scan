import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui show Image;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/canvas/custom_canvas.dart';
import 'package:phone_client/helpers/lib_class.dart';
import 'package:phone_client/hero_tag/hero_tag_generator.dart';
import '../helpers/custom_image_class.dart' as custom;
import 'destination_picker.dart';

/// This class serves to convert an image to an 2D array representing a maze;
/// Based on the image, it turns pixels into a 'R' or 'W' depending on the pixel colour.
class ImageConversion extends StatefulWidget {
  const ImageConversion._(
    this.uiImage,
    this.routeColour,
    this.wallColour,
  );

  factory ImageConversion(
      ui.Image uiImg, Color colourOfRoute, Color colourOfWall) {
    return ImageConversion._(
      uiImg,
      colourOfRoute,
      colourOfWall,
    );
  }
  final ui.Image uiImage;
  final Color routeColour, wallColour;

  @override
  State<ImageConversion> createState() => _ImageConversionState();
}

class _ImageConversionState extends State<ImageConversion> {
  final mapColours = {
    'R': img.ColorInt8.rgba(0, 0, 0, 255),
    'W': img.ColorInt8.rgba(255, 255, 255, 255),
  };
  final GlobalKey imageKey = GlobalKey();
  late GlobalKey currentKey;
  custom.Image? customImage, routedImage;
  img.Image? imgImage;
  Offset crossCenter = Offset.zero, localCrossCenter = Offset.zero;
  final StreamController<custom.Image> _stateController =
      StreamController<custom.Image>();

  /// sets values to late variables and after they're set,
  /// they are used to calculate the rest of the late variables using [_colourMap]
  @override
  void initState() {
    currentKey = imageKey;

    convertFlutterUiToImage(widget.uiImage).then((img.Image image) {
      setState(() {
        customImage = custom.Image(image);
        imgImage = customImage!.image;
      });
    }).whenComplete(() => _colourMap(imgImage!));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTapDown: (details) => setState(() {
            crossCenter = recalibrateOffset(details.globalPosition);
            localCrossCenter = details.localPosition;
          }),
          onPanUpdate: (details) => setState(() {
            crossCenter = recalibrateOffset(details.globalPosition);
            localCrossCenter = details.localPosition;
          }),
          child: Stack(
            children: [
              (routedImage != null
                  ? Image.memory(
                      routedImage!.bytes,
                      key: imageKey,
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orangeAccent,
                      ),
                    )),
              CustomPaint(
                size: const Size(200, 200),
                painter: CrossPainter(localCrossCenter,
                    color: const Color.fromARGB(255, 29, 167, 236)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: HeroTag.distinguisher,
        backgroundColor: const Color.fromARGB(255, 0, 160, 5),
        foregroundColor: Colors.white,
        onPressed: _saveAndMoveOn,
        label: const Text('Save the start and pick the destination'),
        icon: const Icon(Icons.flag_circle),
      ),
    );
  }

  void _colourMap(final img.Image imgSource) {
    final filteredImg = img.Image.from(imgSource);
    for (int x = 0; x < filteredImg.width; x++) {
      for (int y = 0; y < filteredImg.height; y++) {
        var b = _isPixelRepresentingRoute(
            Library.pixelColour(imgSource.getPixel(x, y)));
        filteredImg.setPixel(x, y, mapColours[b ? 'R' : 'W']!);
      }
    }
    _updateRoutedImage(custom.Image(filteredImg));
  }

  void _updateRoutedImage(final custom.Image updatee) {
    _stateController.add(updatee);
    routedImage = updatee;
  }

  Offset recalibrateOffset(Offset globalPosition) {
    currentKey = imageKey;
    RenderBox box = currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(Offset(
        globalPosition.dx - CrossPainter.fingerOffset,
        globalPosition.dy - CrossPainter.fingerOffset));
    double widgetScale = box.size.width / routedImage!.w;
    double px = localPosition.dx / widgetScale,
        py = localPosition.dy / widgetScale;

    return Offset(px, py);
  }

  ///true if pixel colour is more likely to be a route than a wall
  bool _isPixelRepresentingRoute(Color color) =>
      _euclideanDistanceBetweenColours(color, widget.routeColour) <
      _euclideanDistanceBetweenColours(color, widget.wallColour);

  /// https://www.cuemath.com/euclidean-distance-formula/
  double _euclideanDistanceBetweenColours(Color c1, Color c2) {
    return sqrt(pow(c2.red - c1.red, 2) +
        pow(c2.green - c1.green, 2) +
        pow(c2.blue - c1.blue, 2));
  }

  void _saveAndMoveOn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DestinationPicker(routedImage!, localCrossCenter, crossCenter),
      ),
    );
  }

  Future<img.Image> convertFlutterUiToImage(ui.Image uiImage) async {
    final uiBytes = await uiImage.toByteData();

    final image = img.Image.fromBytes(
        width: uiImage.width,
        height: uiImage.height,
        bytes: uiBytes!.buffer,
        format: img.Format.uint8,
        numChannels: 4);

    return image;
  }
}
