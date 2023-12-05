import 'dart:typed_data' show Uint8List;
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:phone_client/helpers/lib_class.dart';

class Image {
  late final img.Image image;
  late final Uint8List bytes;
  late final int w = image.width, h = image.height;
  late final int length = w * h;
  late final double aspectRatio = h / w, swappedAspectRatio = w / h;
  final String? path;

  Image(this.image, {this.path}) : bytes = Library.imageAsBytes(image);
  Image.preResized(img.Image image, {this.path, int? height, int? width}) {
    this.image = img.Image.fromResized(image,
        width: width ?? 1080, height: height ?? 1920);
    bytes = Library.imageAsBytes(this.image);
  }
  /*Image.preResizedFromBytes(this.bytes, {this.path, int? height, int? width}) {
    var x = img.decodeImage(bytes);
    image =
        img.Image.fromResized(x!, width: width ?? 1080, height: height ?? 1920);
  }*/
  Image.fromBytes(this.bytes, {this.path}) : image = img.decodeImage(bytes)!;

  bool isValid() => (image.isValid && bytes.isNotEmpty);

  bool isNotValid() => !isValid();

  Color getImagePixelColour(int x, int y) =>
      Library.pixelColour(image.getPixel(x, y));

  bool isColourEqualToPixelColour(int x, int y, Color color) =>
      getImagePixelColour(x, y) == color;

  bool isXYWithinBounds(int x, int y) => x < w && x > 0 && y < h && y > 0;

  @override
  String toString() =>
      image.map((e) => [e.a, e.r, e.g, e.b]).toList().toString();
}
