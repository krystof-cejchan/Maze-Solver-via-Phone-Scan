import 'dart:typed_data' show Uint8List;
import 'dart:ui';
import 'package:image/image.dart' as img show Image, decodeImage;
import 'package:phone_client/helpers/lib_class.dart';

class Image {
  final img.Image image;
  final Uint8List bytes;
  late final int w = image.width, h = image.height;
  late final int length = w * h;

  Image(this.image) : bytes = Library.imageAsBytes(image);
  Image.fromBytes(this.bytes) : image = img.decodeImage(bytes)!;

  bool isValid() => image.isValid;

  bool isNotValid() => !isValid();

  Color getImagePixelColour(int x, int y) =>
      Library.pixelColour(image.getPixel(x, y));

  bool isColourEqualToPixelColour(int x, int y, Color color) =>
      getImagePixelColour(x, y) == color;

  bool isXYWithinBounds(int x, int y) => x < w && x > 0 && y < h && y > 0;
}
