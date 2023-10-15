import 'dart:collection';

import 'package:phone_client/route_algorithms/classes_for_route_algorithm.dart';

class NormalizedPathDirections {
  final List<Coordinate> pathCoordinates;
  late final Queue<Directions> directions;
  NormalizedPathDirections(this.pathCoordinates) {
    directions = _normalizedDirections();
  }

  /// Normalizes a list of directions by removing consecutive identical directions
  /// until a specified threshold is reached.
  Queue<Directions> _normalizedDirections({int threshold = 25}) {
    var directions = _allDirections();
    Queue<Directions> normalizedDirections = Queue(), history = Queue();
    Directions curr;

    for (int i = 0; i < directions.length; i++) {
      history.add(curr = directions[i]);
      bool allEqual = history.every((element) => element == curr);
      if (allEqual && history.length >= threshold) {
        while (++i < directions.length && directions[i] == curr) {
          continue;
        }
        if (normalizedDirections.lastOrNull != curr) {
          normalizedDirections.add(directions[--i]);
        }
        history.clear();
        continue;
      } else if (!allEqual) {
        history.clear();
      }
    }

    return normalizedDirections;
  }

  List<Directions> _allDirections() {
    List<Directions> allDirections = List.empty(growable: true);
    for (int i = 1; i < pathCoordinates.length; i++) {
      allDirections.add(_directionFromPreviousCoordinates(
          pathCoordinates[i], pathCoordinates[i - 1]));
    }
    return allDirections;
  }

  Directions _directionFromPreviousCoordinates(
      Coordinate curr, Coordinate prev) {
    if (curr.xCoordinate > prev.xCoordinate) {
      return Directions.right;
    } else if (curr.xCoordinate < prev.xCoordinate) {
      return Directions.left;
    } else if (curr.yCoordinate > prev.yCoordinate) {
      return Directions.down;
    } else {
      return Directions.up;
    }
  }

  @override
  String toString() {
    return directions.toString();
  }
}
