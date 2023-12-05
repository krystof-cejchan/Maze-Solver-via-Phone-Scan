import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:phone_client/custom_image_class/custom_image_class.dart'
    as custom;

mixin Library on Object {
  static Uint8List imageAsBytes(img.Image imgImage) =>
      Uint8List.fromList(img.encodeJpg(imgImage));

  static Color pixelColour(img.Pixel p) =>
      Color.fromARGB(p.a.toInt(), p.r.toInt(), p.g.toInt(), p.b.toInt());

  // ignore: provide_deprecation_message
  @deprecated
  static Future<custom.Image> defImageToCustomImage(Image image) async {
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      Uint8List uint8List = byteData.buffer.asUint8List();
      return custom.Image(img.decodeImage(uint8List)!);
    } else {
      throw Exception('Failed to convert ui.Image to custom.Image');
    }
  }
}
