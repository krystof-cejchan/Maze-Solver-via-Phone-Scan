import 'dart:collection';

import 'package:flutter/material.dart' show Colors;
import 'package:phone_client/helpers/custom_image_class.dart' as custom;
import 'package:phone_client/helpers/lib_class.dart';

import 'classes,enums,exceptions_for_route_algorithm/coordinate.dart';
import 'classes,enums,exceptions_for_route_algorithm/enums/directions.dart';
import 'classes,enums,exceptions_for_route_algorithm/enums/robot_instructions.dart';
import 'classes,enums,exceptions_for_route_algorithm/exceptions/wrong_followup_direction.dart';
import 'classes,enums,exceptions_for_route_algorithm/mapped_directions_to_coordinates.dart';

class NormalizedPathDirections {
  final List<Coordinate> _pathCoordinates;
  final custom.Image imageMaze;
  late final Queue<MappedDirectionsToCoordinates> mappedDirectionsToCoordinates;
  NormalizedPathDirections(this._pathCoordinates, this.imageMaze) {
    mappedDirectionsToCoordinates = _normalizedDirections();
  }

  /// Normalizes a list of directions by removing consecutive identical directions
  /// until a specified threshold is reached.
  Queue<MappedDirectionsToCoordinates> _normalizedDirections(
      {int threshold = 25}) {
    //history of [Directions] looped through
    final Queue<Directions> history = Queue<Directions>();

    //queue holding a Directions item and list of Coordinates that go in that Direction
    final Queue<MappedDirectionsToCoordinates> mapDirToCoo = Queue();

    Directions curr; // dummy for saving current Directions

    for (int i = 1; i < _pathCoordinates.length; i++) {
      final S = i - 1; // constant for saving starting index of a direction

      // calculated new direction from the Coordinates of index [i] and Coordinates of index [S]
      var currDir = _directionFromPreviousCoordinates(
        _pathCoordinates[i],
        _pathCoordinates[S],
      );

      // a record added to the history and [curr] is assigned the value of [currDir]
      history.add(
        curr = currDir,
      );

      // checks whether all elements in history are equal to the [curr]
      bool allEqual = history.every((element) => element == curr);

      if (allEqual && history.length >= threshold) {
        /* while:
         increased [i] is lower than the length of [pathCoordinates] and newly calculated direction is equal to [curr]
         then:
         continue*/
        while (++i < _pathCoordinates.length &&
            (currDir = _directionFromPreviousCoordinates(
                  _pathCoordinates[i],
                  _pathCoordinates[i - 1],
                )) ==
                curr) {}
        // if nothing has been added to the map yet or last direction is not equal to [currDir]
        // then add {currDir, sublist of all coordinates with that direction}
        if (mapDirToCoo.isEmpty || mapDirToCoo.last.directions != curr) {
          mapDirToCoo.add(MappedDirectionsToCoordinates(
              curr,
              List<Coordinate>.from(
                _pathCoordinates.sublist(S, --i),
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

    return mapDirToCoo;
  }

  /// checks whether x and y are not border coordinates and whether the pixel places on these coordinates represents route
  bool _isValidRoute(int x, int y) {
    return x < imageMaze.w &&
        x > 0 &&
        y < imageMaze.h &&
        y > 0 &&
        Library.pixelColour(imageMaze.image.getPixel(x, y)) == Colors.white;
  }

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
    if (prevDirection.horizontal == nextDirection.horizontal) {
      throw WrongFollowupDirectionException();
    }
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
