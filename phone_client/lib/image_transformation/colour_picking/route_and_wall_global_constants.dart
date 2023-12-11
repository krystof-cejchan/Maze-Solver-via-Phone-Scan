import 'package:flutter/material.dart' show Color, Colors;
import 'package:image/image.dart' as img;

mixin C {
  static const Color route = Colors.white, wall = Colors.black;
  static img.ColorInt8 wallInt8 = img.ColorInt8.rgba(0, 0, 0, 255),
      routeInt8 = img.ColorInt8.rgba(255, 255, 255, 255);
}
