class Coordinate {
  final int startX, startY, endX, endY;
  Coordinate(this.startX, this.startY, this.endX, this.endY);
  factory Coordinate.recalculate(int x, int y, int x2, int y2) {
    return Coordinate(x - 50, y - 50, x2 - 50, y2 - 50);
  }
}
