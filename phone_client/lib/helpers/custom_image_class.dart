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

  bool isValid() {
    return image.isValid;
  }

  bool isNotValid() {
    return !isValid();
  }

  Color getImagePixelColour(int x, int y) {
    return Library.pixelColour(image.getPixel(x, y));
  }

  bool isColourEqualToPixelColour(int x, int y, Color color) {
    return getImagePixelColour(x, y) == color;
  }
}
