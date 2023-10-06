import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

mixin Library on Object {
  static Uint8List imageAsBytes(img.Image imgImage) =>
      Uint8List.fromList(img.encodePng(imgImage));

  static Color pixelColour(img.Pixel p) =>
      Color.fromARGB(p.a.toInt(), p.r.toInt(), p.g.toInt(), p.b.toInt());
}
