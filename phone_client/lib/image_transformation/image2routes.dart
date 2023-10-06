import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/helpers/lib_class.dart';
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

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Image.memory(
      _colourMap(widget.edImage).bytes,
      fit: BoxFit.scaleDown,
      repeat: ImageRepeat.noRepeat,
    ));
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
}
