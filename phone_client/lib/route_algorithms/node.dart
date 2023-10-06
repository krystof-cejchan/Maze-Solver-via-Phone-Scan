class Node {
  int x;
  int y;
  Node? parent;
  late bool visited;

  Node(this.x, this.y, this.parent) : visited = false;

  @override
  bool operator ==(Object other) =>
      other is Node &&
      other.runtimeType == runtimeType &&
      other.x == x &&
      other.y == y;

  @override
  int get hashCode => x ~/ y;
}
