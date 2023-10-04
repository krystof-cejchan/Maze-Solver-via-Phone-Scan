import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/exceptions/picture_size.dart';
import 'package:phone_client/helpers/lib_class.dart';
import '../helpers/custom_image_class.dart' as custom;

/// This class serves to convert an image to an 2D array representing a maze;
/// Based on the image, it turns pixels into a 'R' or 'W' depending on the pixel colour.
class ImageConversion extends StatefulWidget {
  const ImageConversion._(this.customImage, this.edImage, this.routeColour);

  factory ImageConversion(custom.Image customImage, Color? colourOfRoute) {
    return ImageConversion._(customImage, customImage.image,
        colourOfRoute ?? const Color.fromARGB(206, 0, 0, 0));
  }

  final custom.Image customImage;
  final img.Image edImage;
  final Color routeColour;

  @override
  State<ImageConversion> createState() => _ImageConversionState();
}

class _ImageConversionState extends State<ImageConversion> {
  final double THRESHOLD = 20;

  final mapColours = {
    'R': img.ColorInt32.rgb(0, 0, 0),
    'W': img.ColorInt32.rgb(255, 255, 255)
  };

  late final imageMap = _convertImageToArray(widget.edImage);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.memory(
      _colourMap(widget.edImage),
      fit: BoxFit.scaleDown,
      repeat: ImageRepeat.noRepeat,
    ));
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

  Uint8List _colourMap(
    final img.Image imgSource,
  ) {
    final filteredImg = imgSource;
    for (int x = 0; x < filteredImg.width; x++) {
      for (int y = 0; y < filteredImg.height; y++) {
        if (_isPixelSimilarToColour(imgSource.getPixel(x, y))) {
          filteredImg.setPixel(x, y, img.ColorInt32.rgb(255, 255, 255));
        } else {
          filteredImg.setPixel(x, y, img.ColorInt32.rgb(0, 0, 0));
        }
      }
    }
    return Library.imageAsBytes(filteredImg);
  }

  img.Image _pixelsToImage(int w, int h, List<img.Color> colourPixels) {
    if (w * h != colourPixels.length) {
      throw PictureSizeDoesNotMatchArrayLength();
    }
    img.Image image = img.Image(width: w, height: h);
    for (int i = 0; i < colourPixels.length; i += 5) {
      var x = i ~/ w, y = i % w;
      image.setPixel(x, y, colourPixels[i]);
    }
    return image;
  }

  bool _isPixelSimilarToColour(img.Pixel pixel, {Color? colour}) {
    return _euclideanDistanceBetweenColours(
            _getPixelColour(pixel), colour ?? widget.routeColour) <=
        THRESHOLD;
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
}
