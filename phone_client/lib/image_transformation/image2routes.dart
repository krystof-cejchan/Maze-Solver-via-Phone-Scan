import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/canvas/custom_canvas.dart';
import 'package:phone_client/helpers/lib_class.dart';
import 'package:phone_client/image_transformation/widget__normalized_path.dart';
import 'package:phone_client/route_algorithms/classes_for_route_algorithm.dart';
import 'package:phone_client/route_algorithms/normalizing_path_to_directions.dart';
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

  final GlobalKey imageKey = GlobalKey();
  late GlobalKey currentKey;
  late custom.Image routedImage = _colourMap(widget.edImage);
  Offset crossCenter = Offset.zero, localCrossCenter = Offset.zero;
  @override
  void initState() {
    currentKey = imageKey;
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
                Image.memory(
                  routedImage.bytes,
                  fit: BoxFit.scaleDown,
                  repeat: ImageRepeat.noRepeat,
                  key: imageKey,
                ),
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

  Offset recalibrateOffset(Offset globalPosition) {
    currentKey = imageKey;
    RenderBox box = currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(Offset(
        globalPosition.dx - CrossPainter.fingerOffset,
        globalPosition.dy - CrossPainter.fingerOffset));
    double widgetScale = box.size.width / routedImage.w;
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
              _DestinationPicker(routedImage, localCrossCenter, crossCenter)),
    );
  }
}

///another class for choosing the destination in the image
class _DestinationPicker extends StatefulWidget {
  const _DestinationPicker(this.customImage, this.localCrossOffset, this.start);
  final custom.Image customImage;

  /// local coordinates to show the cross
  final Offset localCrossOffset;

  /// x and y of the pixel picked as the start
  final Offset start;
  @override
  State<_DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<_DestinationPicker> {
  Offset crossCenter = Offset.zero, localCrossCenter = Offset.zero;
  final GlobalKey imageKey = GlobalKey();
  late GlobalKey currentKey;

  @override
  void initState() {
    currentKey = imageKey;
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
                Image.memory(
                  widget.customImage.bytes,
                  fit: BoxFit.scaleDown,
                  repeat: ImageRepeat.noRepeat,
                  key: imageKey,
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: CrossPainter(localCrossCenter),
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: CrossPainter(
                    widget.localCrossOffset,
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

  Offset recalibrateOffset(Offset globalPosition) {
    currentKey = imageKey;
    RenderBox box = currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(Offset(
        globalPosition.dx - CrossPainter.fingerOffset,
        globalPosition.dy - CrossPainter.fingerOffset));
    double widgetScale = box.size.width / widget.customImage.w;
    double px = localPosition.dx / widgetScale,
        py = localPosition.dy / widgetScale;

    return Offset(px, py);
  }

  void _saveAndMoveOn() {
    final pixels = widget.customImage.image;

    final List<List<int>> grid = List.empty(growable: true);
    for (int i = 0; i < pixels.width; i++) {
      List<int> col = List.filled(pixels.height, 0);
      for (int j = 0; j < pixels.height; j++) {
        if (Library.pixelColour(pixels.getPixel(i, j)) == Colors.black) {
          col[j] = 1;
        }
      }
      grid.add(col);
    }

    final shortestPath = ShortestPathIn2dArray.findPath(
        grid,
        Coordinates(
          widget.start.dx.toInt(),
          widget.start.dy.toInt(),
          crossCenter.dx.toInt(),
          crossCenter.dy.toInt(),
        ));
    var normalizedDirections = NormalizedPathDirections(shortestPath);
    img.Image imageCopy = widget.customImage.image;

    for (int i = 0; i < shortestPath.length; i++) {
      final pieceOfPath = shortestPath[i];

      imageCopy.setPixel(
        pieceOfPath.xCoordinate,
        pieceOfPath.yCoordinate,
        img.ColorInt8.rgb(0, 255, 0),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NormalizedPathWidget(normalizedDirections,
            pathImage: custom.Image(imageCopy)),
      ),
    );
  }
}
