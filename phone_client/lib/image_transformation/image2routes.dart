import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/exceptions/picture_size.dart';

/// This class serves to convert an image to an 2D array representing a maze;
/// Based on the image, it turns pixels into a 'R' or 'W' depending on the pixel colour.
class ImageConversion extends StatelessWidget {
  ImageConversion({Key? key, required this.imageData}) : super(key: key);

  final double threshold = 20;

  final Uint8List imageData;
  final Color routeColour = const Color.fromARGB(206, 0, 0, 0);
  late final Image image = Image.memory(imageData);

  late final img.Image edImage = img.Image.fromBytes(
      width: image.width!.toInt(),
      height: image.height!.toInt(),
      bytes: imageData.buffer);

  late final imageMap = _convertImageToArray(edImage);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.memory(_leaveoutAllExceptRoutes(edImage).getBytes()));
  }

  List<List<String>> _convertImageToArray(
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
  }

  /// could be change to be only linear time
  img.Image _leaveoutAllExceptRoutes(
    final img.Image imgSource,
  ) {
    final widthAndHeight = {'w': imgSource.width, 'h': imgSource.height};
    final filteredImg = img.Image.from(imgSource);
    for (int x = 0; x < filteredImg.width; x++) {
      for (int y = 0; y < filteredImg.height; y++) {
        if (_isPixelSimilarToColour(filteredImg.getPixel(x, y))) {
          filteredImg.setPixel(x, y, img.ColorInt32.rgb(255, 255, 255));
        } else {
          filteredImg.setPixel(x, y, img.ColorInt32.rgb(0, 0, 0));
        }
      }
    }
    imgSource.forEach((pixel) {});

    return filteredImg;
  }

  img.Image _pixelsToImage(int w, int h, List<img.Pixel> pixels) {
    if (w * h != pixels.length) {
      throw PictureSizeDoesNotMatchArrayLength();
    }
    img.Image image = img.Image(width: w, height: h);
    for (int i = 0; i < pixels.length; i++) {
      image.setPixel(i ~/ w, i % w, pixels[i]);
    }
    return image;
  }

  bool _isPixelSimilarToColour(img.Pixel pixel, {Color? colour}) {
    colour ??= routeColour;
    return _euclideanDistanceBetweenColours(_getPixelColour(pixel), colour) <=
        threshold;
  }

  Color _getPixelColour(img.Pixel pixel) {
    return Color.fromARGB(
        255, pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt());
  }

  /// https://www.cuemath.com/euclidean-distance-formula/
  double _euclideanDistanceBetweenColours(Color c1, Color c2) {
    return sqrt(pow(c2.red - c1.red, 2) +
        pow(c2.green - c1.green, 2) +
        pow(c2.blue - c1.blue, 2));
  }

  /*List<List<String>> _smoothMazeMap(List<List<String>> rw) {
    for (var i = 0; i < rw.length; i++) {
      for (var j = 0; j < rw[i].length; j++) {
        if (rw[i][j] == "W") {
          continue;
        }

      }
    }
  }*/
}
