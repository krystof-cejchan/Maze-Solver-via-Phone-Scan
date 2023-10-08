import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:phone_client/helpers/lib_class.dart';

class Image {
  final img.Image image;
  final Uint8List bytes;
  late final int w = image.width, h = image.height;
  late final int length = w * h;

  Image(this.image) : bytes = Library.imageAsBytes(image);

  bool isValid() {
    return image.isValid;
  }
}
