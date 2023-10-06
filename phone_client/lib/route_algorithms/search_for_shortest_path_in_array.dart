import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:phone_client/helpers/lib_class.dart';
import 'package:phone_client/route_algorithms/point_in_array.dart';

import '../helpers/custom_image_class.dart' as custom;

mixin ShortestPathIn2dArray {
  ///an algorithm to find the shortest path from a starting point to an endpoint
  ///in a black and white image
  ///(where white pixels represent a route and black pixels represent walls)
  List<Point> findShortestPath(custom.Image image, Point start, Point end) {
    final int numRows = image.h;
    final int numCols = image.w;

    final List<List<Point?>> parent = List.generate(
      numRows,
      (_) => List<Point?>.generate(numCols, (_) => null),
    );

    final List<Point> directions = [
      Point(-1, 0), // Up
      Point(1, 0), // Down
      Point(0, -1), // Left
      Point(0, 1), // Right
    ];

    final Queue<Point> queue = Queue();
    queue.add(start..visited = true);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current == end) {
        final path = <Point>[];
        Point? at = end;
        while (at != null) {
          path.add(at);
          at = parent[at.x][at.y];
        }
        return path.reversed.toList();
      }

      for (final direction in directions) {
        final next = Point(current.x + direction.x, current.y + direction.y);

        if (next.x >= 0 &&
            next.x < numRows &&
            next.y >= 0 &&
            next.y < numCols) {
          if (!next.visited &&
              Library.pixelColour(image.image.getPixel(next.x, next.y)) ==
                  Colors.white) {
            queue.add(next..visited = true);
            parent[next.x][next.y] = current;
          }
        }
      }
    }

    // If no path is found, return an empty list.
    return [];
  }
}
