import 'coordinate.dart';

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
