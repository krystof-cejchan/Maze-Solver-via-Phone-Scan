import 'package:phone_client/canvas/custom_canvas.dart';

class Coordinate {
  final int startX, startY, endX, endY;
  Coordinate(this.startX, this.startY, this.endX, this.endY);
  factory Coordinate.recalculate(int x, int y, int x2, int y2) {
    var localFingerOffset = CrossPainter.fingerOffset;
    return Coordinate(x - localFingerOffset, y - localFingerOffset,
        x2 - localFingerOffset, y2 - localFingerOffset);
  }
}
