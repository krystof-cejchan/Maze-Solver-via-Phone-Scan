import 'dart:collection';

import 'package:phone_client/route_algorithms/node.dart';

import '../helpers/custom_image_class.dart' as custom;

mixin ShortestPathIn2dArray {
  ///an algorithm to find the shortest path from a starting Node to an endNode
  ///in a black and white image
  ///(where white pixels represent a route and black pixels represent walls)
  static List<Node> findPath(custom.Image image, Node start, Node end) {
    final int numRows = image.h;
    final int numCols = image.w;
    final int length = numCols * numRows;
    List<int> row = List.of([-1, 0, 0, 1], growable: false);
    List<int> col = List.of([0, -1, 1, 0], growable: false);
    List<Node> path = List.empty(growable: true);
    Queue<Node> queue = Queue();
    queue.add(start
      ..parent = null
      ..visited = true);

    while (queue.isNotEmpty) {
      Node curr = queue.removeFirst();
      if (curr == end) {
        _findPath(curr, path);
        return path;
      }

      for (int i = 0; i < row.length; i++) {
        //can't use .. *i; the variable is just a dummy
        start.x = start.x + row[i] * i;
        start.y = start.y + col[i] * i;

        if (_isValid(start.x, start.y, length)) {
          Node next = Node(start.x, start.y, curr);
          if (!next.visited) {
            queue.add(next..visited = true);
          }
        }
      }
    }
    return [];
  }

// Utility function to find path from source to destination
  static void _findPath(Node? node, List<Node> path) {
    if (node != null) {
      _findPath(node.parent, path);
      path.add(node);
    }
  }

  static bool _isValid(int x, int y, int N) {
    return (x >= 0 && x < N) && (y >= 0 && y < N);
  }
}
