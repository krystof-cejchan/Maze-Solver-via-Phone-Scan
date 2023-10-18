import 'dart:collection';

import 'package:flutter/material.dart' show Colors;
import 'package:phone_client/helpers/custom_image_class.dart' as custom;
import 'package:phone_client/helpers/lib_class.dart';

import 'package:phone_client/route_algorithms/classes_for_route_algorithm.dart';

class NormalizedPathDirections {
  final List<Coordinate> pathCoordinates;
  final custom.Image imageMaze;
  late final Queue<MappedDirectionsToCoordinates> mappedDirectionsToCoordinates;
  NormalizedPathDirections(this.pathCoordinates, this.imageMaze) {
    mappedDirectionsToCoordinates = _normalizedDirections();
  }

  /// Normalizes a list of directions by removing consecutive identical directions
  /// until a specified threshold is reached.
  Queue<MappedDirectionsToCoordinates> _normalizedDirections({
    int threshold = 25,
    bool crossroadPatch = false,
  }) {
    final Queue<Directions> history =
        Queue<Directions>(); //history of [Directions] looped through

    final Queue<MappedDirectionsToCoordinates> mapDirToCoo =
        Queue(); //queue holding a Directions item and list of Coordinates that go in that Direction

    Directions curr; // dummy for saving current Directions

    for (int i = 1; i < pathCoordinates.length; i++) {
      final S = i - 1; // constant for saving starting index of a direction

      var currDir = _directionFromPreviousCoordinates(
        pathCoordinates[i],
        pathCoordinates[S],
      ); // calculated new direction from the Coordinates of index [i] and Coordinates of index [S]

      history.add(
        curr = currDir,
      ); // a record added to the history and [curr] is assigned the value of [currDir]

      bool allEqual = history.every(
        (element) => element == curr,
      ); // checks whether all elements in history are equal to the [curr]
      if (allEqual && history.length >= threshold) {
        /* while:
         increased [i] is lower than the length of [pathCoordinates] and newly calculated direction is equal to [curr]
         then:
         continue*/
        while (++i < pathCoordinates.length &&
            (currDir = _directionFromPreviousCoordinates(
                  pathCoordinates[i],
                  pathCoordinates[i - 1],
                )) ==
                curr) {
          continue;
        }
        // if nothing has been added to the map yet or last direction is not equal to [currDir]
        // then add {currDir, sublist of all coordinates with that direction}
        if (mapDirToCoo.isEmpty || mapDirToCoo.last.directions != currDir) {
          mapDirToCoo.add(MappedDirectionsToCoordinates(
              curr,
              List<Coordinate>.from(
                pathCoordinates.sublist(S, --i),
              )));
        }
        // clear history and continue
        history.clear();
        continue;
      }
      // else if the directions are not the same before reacing the threshold; clear the history and start over
      else if (!allEqual) {
        history.clear();
      }
    }

    /*if (!crossroadPatch || mapDirToCoo.length <= 1) */ return mapDirToCoo;

    Queue<MappedDirectionsToCoordinates> patchedMap = Queue();

    MappedDirectionsToCoordinates map = mapDirToCoo.removeFirst(), nextMap;
    while (mapDirToCoo.isNotEmpty) {
      nextMap = mapDirToCoo.removeFirst();
      int S = 0;
      patchedMap.add(map);
      for (int i = 0; i < map.coordinates.length; i += 5) {
        var currCoo = map.coordinates[i];
        int counter = 0, x = currCoo.xCoordinate, y = currCoo.yCoordinate;
        while (_isValidRoute(x, y)) {
          switch (nextMap.directions) {
            case Directions.down:
              y++;
              break;
            case Directions.up:
              y--;
              break;
            case Directions.right:
              x++;
              break;
            case Directions.left:
              x--;
              break;
          }
          counter++;
        }

        if (counter <= 100) {
          continue;
        }

        patchedMap.add(
          MappedDirectionsToCoordinates(
            map.directions,
            List<Coordinate>.from(
              map.coordinates.sublist(S, S = i),
            ),
          ),
        );
      }
      map = nextMap;
    }
    patchedMap.forEach((element) {
      print(element.toString());
    });
    return patchedMap;
  }

  /// checks whether x and y are not border coordinates and whether the pixel places on these coordinates represents route
  bool _isValidRoute(int x, int y) {
    return x < imageMaze.w &&
        x > 0 &&
        y < imageMaze.h &&
        y > 0 &&
        Library.pixelColour(imageMaze.image.getPixel(x, y)) == Colors.white;
  }
  /* Queue<Directions> _crossroadPatch(Queue<Directions> directions) {
    for (Coordinate coo in pathCoordinates) {}
  }*/

  /// returns all directions based on every pixel and its previous pixel
/*  List<Directions> _allDirections() {
    List<Directions> allDirections = List.empty(growable: true);
    for (int i = 1; i < pathCoordinates.length; i++) {
      allDirections.add(_directionFromPreviousCoordinates(
          pathCoordinates[i], pathCoordinates[i - 1]));
    }
    return allDirections;
  }*/

  /// calculates Direction a pixel has taken since its previous pixel
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

  Queue<RobotInstructions> convertDirectionsToRobotInstructions() {
    if (mappedDirectionsToCoordinates.isEmpty) return Queue();
    var dirsCopy = mappedDirectionsToCoordinates;
    Queue<RobotInstructions> robotInstructions = Queue();
    var prevDirection = dirsCopy.removeFirst().directions;

    while (dirsCopy.isNotEmpty) {
      robotInstructions.add(_calculateRobotInstructionBasedOnPreviousDirection(
          prevDirection, prevDirection = dirsCopy.removeFirst().directions));
    }
    return robotInstructions;
  }

  RobotInstructions _calculateRobotInstructionBasedOnPreviousDirection(
      Directions prevDirection, Directions nextDirection) {
    /*  if (prevDirection.horizontal == nextDirection.horizontal) {
      throw WrongFollowupDirectionException();
    }*/
    if (prevDirection == nextDirection) return RobotInstructions.pass;
    switch (prevDirection) {
      case Directions.down:
        return nextDirection == Directions.right
            ? RobotInstructions.left
            : RobotInstructions.right;

      case Directions.up:
        return nextDirection.directionsToRobotInstruction();

      case Directions.left:
        return nextDirection == Directions.up
            ? RobotInstructions.right
            : RobotInstructions.left;

      case Directions.right:
        return nextDirection == Directions.up
            ? RobotInstructions.left
            : RobotInstructions.right;
    }
  }

  @override
  String toString() {
    return mappedDirectionsToCoordinates.toString();
  }
}
