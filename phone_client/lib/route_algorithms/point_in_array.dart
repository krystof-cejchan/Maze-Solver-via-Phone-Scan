class Point {
  int x;
  int y;
  late bool visited;
  Point.visited(this.x, this.y) : visited = true;
  Point(this.x, this.y) : visited = false;
  Point.custom(this.x, this.y, this.visited);

  @override
  bool operator ==(Object other) =>
      other is Point &&
      other.runtimeType == runtimeType &&
      other.x == x &&
      other.y == y;

  @override
  int get hashCode => (x / y + y / x).toInt();
}
