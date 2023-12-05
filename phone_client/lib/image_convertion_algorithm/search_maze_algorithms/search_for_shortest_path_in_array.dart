import 'package:collection/collection.dart';
import 'package:phone_client/image_convertion_algorithm/classes,enums,exceptions_for_route_algorithm/coordinate.dart';
import 'package:phone_client/image_convertion_algorithm/classes,enums,exceptions_for_route_algorithm/coordinates.dart';

import '../classes,enums,exceptions_for_route_algorithm/node.dart';

class PathInMatrix {
  late final List<Coordinate> foundPath;

  PathInMatrix(List<List<int>> grid, Coordinates coordinates) {
    foundPath = findPathUsingAStar(grid, coordinates);
  }

  ///an algorithm to find the shortest path from a starting [coordinates] to an end [coordinates]
  ///in a 2d matrix   (where 0 represent a route and 1 represent walls)
  /// https://www.geeksforgeeks.org/a-search-algorithm/
  List<Coordinate> findPathUsingAStar(
      List<List<int>> grid, Coordinates coordinates) {
    final openList = PriorityQueue<Node>((a, b) => (a.f - b.f).toInt());
    final closedList = <Node, Node>{};
    final startNode = Node(coordinates.startX, coordinates.startY);
    final endNode = Node(coordinates.endX, coordinates.endY);

    openList.add(startNode);

    while (openList.isNotEmpty) {
      final currentNode = openList.removeFirst();
      if (currentNode == endNode) {
        return _buildPath(currentNode, grid);
      }

      closedList[currentNode] = currentNode;

      for (final neighbor in _getNeighbors(grid, currentNode)) {
        if (closedList.containsKey(neighbor)) continue;

        final tentativeG = currentNode.g + 1.0; // Cardinal movement cost

        if (!openList.contains(neighbor) || tentativeG < neighbor.g) {
          neighbor.parent = currentNode;
          neighbor.g = tentativeG;
          neighbor.h = _heuristic(neighbor, endNode);
          neighbor.f = neighbor.g + neighbor.h;

          if (!openList.contains(neighbor)) {
            openList.add(neighbor);
          }
        }
      }
    }

    return []; // No path found
  }

  ///manhattan distance heuristic for horizontal and vertical movement
  double _heuristic(Node a, Node b) =>
      (a.x - b.x).abs().toDouble() + (a.y - b.y).abs().toDouble();

  /// returns neighbors from [directions]
  List<Node> _getNeighbors(List<List<int>> grid, Node node) {
    final neighbors = <Node>[];
    final directions = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];

    for (final List<int> dir in directions) {
      final int x = node.x + dir[0];
      final int y = node.y + dir[1];

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

  /// builds the path
  List<Coordinate> _buildPath(Node node, List<List<int>> grid) {
    final path = <Coordinate>[];
    var current = node;

    while (current.parent != null) {
      path.add(current);
      current = current.parent!;
    }

    path.add(current); // Add the start node
    return path.reversed.toList();
  }
}
