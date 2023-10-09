import 'dart:js_util';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/canvas/custom_canvas.dart';
import 'package:phone_client/helpers/lib_class.dart';
import 'package:phone_client/route_algorithms/coordinate.dart';
import 'package:phone_client/route_algorithms/search_for_shortest_path_in_array.dart';
import '../helpers/custom_image_class.dart' as custom;

/// This class serves to convert an image to an 2D array representing a maze;
/// Based on the image, it turns pixels into a 'R' or 'W' depending on the pixel colour.
class ImageConversion extends StatefulWidget {
  const ImageConversion._(
    this.customImage,
    this.edImage,
    this.routeColour,
    this.wallColour,
  );

  factory ImageConversion(
      custom.Image customImage, Color colourOfRoute, Color colourOfWall) {
    return ImageConversion._(
      customImage,
      customImage.image,
      colourOfRoute,
      colourOfWall,
    );
  }

  final custom.Image customImage;
  final img.Image edImage;
  final Color routeColour, wallColour;

  @override
  State<ImageConversion> createState() => _ImageConversionState();
}

class _ImageConversionState extends State<ImageConversion> {
  final mapColours = {
    'R': img.ColorInt8.rgb(0, 0, 0),
    'W': img.ColorInt8.rgb(255, 255, 255),
  };

  late custom.Image routedImage = _colourMap(widget.edImage);
  Offset crossCenter = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: GestureDetector(
            onTapDown: (details) => setState(() {
              crossCenter = details.localPosition;
            }),
            onPanUpdate: (details) => setState(() {
              crossCenter = details.localPosition;
            }),
            child: Stack(
              children: [
                Image.memory(
                  routedImage.bytes,
                  fit: BoxFit.scaleDown,
                  repeat: ImageRepeat.noRepeat,
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: CrossPainter(crossCenter,
                      color: const Color.fromARGB(255, 29, 167, 236)),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color.fromARGB(255, 0, 160, 5),
            foregroundColor: Colors.white,
            onPressed: _saveAndMoveOn,
            label: const Text('Pick the destination'),
            icon: const Icon(Icons.flag_circle)));
  }

  custom.Image _colourMap(
    final img.Image imgSource,
  ) {
    final filteredImg = imgSource;
    for (int x = 0; x < filteredImg.width; x++) {
      for (int y = 0; y < filteredImg.height; y++) {
        filteredImg.setPixel(
            x,
            y,
            mapColours[_isPixelRepresentingRoute(
                    Library.pixelColour(imgSource.getPixel(x, y)))
                ? 'R'
                : 'W']!);
      }
    }
    return custom.Image(filteredImg);
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
          builder: (context) => _DestinationPicker(routedImage, crossCenter)),
    );
  }
}

///another class for choosing the destination in the image
class _DestinationPicker extends StatefulWidget {
  const _DestinationPicker(this.customImage, this.start);
  final custom.Image customImage;
  final Offset start;
  @override
  State<_DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<_DestinationPicker> {
  Offset crossCenter = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: GestureDetector(
            onTapDown: (details) => setState(() {
              crossCenter = details.localPosition;
            }),
            onPanUpdate: (details) => setState(() {
              crossCenter = details.localPosition;
            }),
            child: Stack(
              children: [
                Image.memory(
                  widget.customImage.bytes,
                  fit: BoxFit.scaleDown,
                  repeat: ImageRepeat.noRepeat,
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: CrossPainter(crossCenter),
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: CrossPainter(
                    widget.start,
                    color: const Color.fromARGB(255, 29, 167, 236),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color.fromARGB(255, 79, 255, 85),
            foregroundColor: const Color.fromARGB(195, 0, 0, 0),
            onPressed: _saveAndMoveOn,
            label: const Text('Find the shortest path'),
            icon: const Icon(Icons.route_outlined)));
  }

  void _saveAndMoveOn() {
    final pixels = widget.customImage.image;
    final List<List<int>> grid = List.empty(growable: true);
    for (int i = 0; i < pixels.width; i++) {
      List<int> row = List.empty(growable: true);
      for (int j = 0; j < pixels.height; j++) {
        //if i&j are equal to picked start and destination add a special symbol
        /*if(widget.start == i j){
          row.add(7);
          continue;
        }*/
        row.add(
            Library.pixelColour(pixels.getPixel(i, j)) == Colors.black ? 1 : 0);
      }
      grid.add(row);
    }
    // routedImage.image.pixe
    print(ShortestPathIn2dArray.findPath(
      grid,
      Coordinate.recalculate(
        widget.start.dx.toInt(),
        widget.start.dy.toInt(),
        crossCenter.dx.toInt(),
        crossCenter.dy.toInt(),
      ),
    ));
  }
}
