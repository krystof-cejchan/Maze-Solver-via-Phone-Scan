import 'dart:typed_data';

import 'package:image/image.dart' as img;

mixin Library on Object {
  static Uint8List imageAsBytes(img.Image imgImage) =>
      Uint8List.fromList(img.encodePng(imgImage));
}
