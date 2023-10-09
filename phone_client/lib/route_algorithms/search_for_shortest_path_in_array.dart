import 'package:collection/collection.dart';
import 'package:phone_client/route_algorithms/coordinate.dart';
import 'package:phone_client/route_algorithms/node.dart';

mixin ShortestPathIn2dArray {
  ///an algorithm to find the shortest path from a starting Node to an endNode
  ///in a black and white image
  ///(where white pixels represent a route and black pixels represent walls)
  static List<List<int>> findPath(List<List<int>> grid, Coordinate coordinate) {
    final openList = PriorityQueue<Node>((a, b) => (a.f - b.f).toInt());
    final closedList = <Node, Node>{};
    final startNode = Node(coordinate.startX, coordinate.startY);
    final endNode = Node(coordinate.endX, coordinate.endY);

    openList.add(startNode);

    while (openList.isNotEmpty) {
      final currentNode = openList.removeFirst();
      if (currentNode == endNode) {
        return _buildPath(currentNode);
      }

      closedList[currentNode] = currentNode;

      for (final neighbor in _getNeighbors(grid, currentNode)) {
        if (closedList.containsKey(neighbor)) continue;

        final tentativeG = currentNode.g + 1;
        bool tentativeIsBetter = false;

        if (!openList.contains(neighbor)) {
          openList.add(neighbor);
          tentativeIsBetter = true;
        } else if (tentativeG < neighbor.g) {
          tentativeIsBetter = true;
        }

        if (tentativeIsBetter) {
          neighbor.parent = currentNode;
          neighbor.g = tentativeG;
          neighbor.h = _heuristic(neighbor, endNode);
          neighbor.f = neighbor.g + neighbor.h;
        }
      }
    }

    return []; // No path found
  }

  static List<Node> _getNeighbors(List<List<int>> grid, Node node) {
    final neighbors = <Node>[];
    final directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1]
    ];

    for (final dir in directions) {
      final x = node.x + dir[0];
      final y = node.y + dir[1];

      if (x >= 0 &&
          x < grid.length &&
          y >= 0 &&
          y < grid[0].length &&
          grid[x][y] == 0) {
        neighbors.add(Node(x, y));
      }
    }

    return neighbors;
  }

  static double _heuristic(Node a, Node b) {
    return (a.x - b.x).abs().toDouble() + (a.y - b.y).abs().toDouble();
  }

  static List<List<int>> _buildPath(Node node) {
    final path = <List<int>>[];
    var current = node;

    while (current.parent != null) {
      path.add([current.x, current.y]);
      current = current.parent!;
    }

    path.reversed;
    return path;
  }
}
