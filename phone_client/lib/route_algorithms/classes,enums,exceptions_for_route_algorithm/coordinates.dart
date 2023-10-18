import 'package:phone_client/canvas/custom_canvas.dart';

import 'coordinate.dart';

class Coordinates extends Coordinate {
  final int startX, startY, endX, endY;
  Coordinates(this.startX, this.startY, this.endX, this.endY)
      : super(startX, startY);
  factory Coordinates.recalculate(int x, int y, int x2, int y2) {
    var localFingerOffset = CrossPainter.fingerOffset;
    return Coordinates(x - localFingerOffset, y - localFingerOffset,
        x2 - localFingerOffset, y2 - localFingerOffset);
  }
}
