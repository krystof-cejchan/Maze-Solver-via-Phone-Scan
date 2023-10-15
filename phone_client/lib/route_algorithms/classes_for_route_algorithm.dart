import 'package:phone_client/canvas/custom_canvas.dart';

class Node extends Coordinate {
  int x, y;
  double f = 0, g = 0, h = 0;
  Node? parent;

  Node(this.x, this.y) : super(x, y);

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  @override
  bool operator ==(Object other) =>
      other is Node &&
      other.runtimeType == runtimeType &&
      other.x == x &&
      other.y == y;
}

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

class Coordinate {
  final int xCoordinate, yCoordinate;
  Coordinate(this.xCoordinate, this.yCoordinate);
}

/// enum values representing a direction the robot or anything going from the start to the end has from the point of view of a 2d image/array
enum Directions { left, right, up, down }

enum Turns {
  left,
  right,
}
