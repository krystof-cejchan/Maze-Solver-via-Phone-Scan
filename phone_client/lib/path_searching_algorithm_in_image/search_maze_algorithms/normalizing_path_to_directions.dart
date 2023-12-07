import 'dart:collection';

import 'package:phone_client/custom_image/custom_image_class.dart' as custom;
import 'package:phone_client/path_searching_algorithm_in_image/support_classes/enums/maze_representatives.dart';
import 'package:phone_client/path_searching_algorithm_in_image/support_classes/enums/should_continue.dart';

import '../../image_transformation/colour_picking/route_and_wall_global_constants.dart';
import '../support_classes/coordinate.dart';
import '../support_classes/enums/directions.dart';
import '../support_classes/enums/robot_instructions.dart';
import '../support_classes/exceptions/wrong_followup_direction.dart';
import '../support_classes/mapped_directions_to_coordinates.dart';

class NormalizedPathDirections {
  final List<Coordinate> _pathCoordinates;
  custom.Image _imageMaze;
  late final Queue<MappedDirectionsToCoordinates> mappedDirectionsToCoordinates;
  late final Queue<RobotInstructions> robotInstructions;

  NormalizedPathDirections(this._pathCoordinates, this._imageMaze) {
    mappedDirectionsToCoordinates = _normalizedDirections();
    robotInstructions = _patchMappedDirectionsToCoordinates();
  }

  final _thresholdPixels = 25;
  final _threshold = 25;
  final _percentCoordinatesLength = 15;
  final _minLengthOfCoordinates = 10;
  final _timesFoundWallLimit = 10;

  /// Normalizes a list of directions by removing consecutive identical directions
  /// until a specified threshold is reached.
  Queue<MappedDirectionsToCoordinates> _normalizedDirections() {
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
      history.add(curr = currDir);

      // checks whether all elements in history are equal to the [curr]
      bool allEqual = history.every((element) => element == curr);

      if (allEqual && history.length >= _threshold) {
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
        } else if (mapDirToCoo.last.directions == curr) {
          final last = mapDirToCoo.removeLast();
          mapDirToCoo.add(
            last
              ..coordinates = [
                ...last.coordinates,
                ..._pathCoordinates.sublist(S, --i),
              ],
          );
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

  /// calculates [RobotInstructions] based on previous and next [Directions]
  RobotInstructions _calcRobotIntruct(
      Directions prevDirection, Directions nextDirection) {
    if (prevDirection == nextDirection) {
      return RobotInstructions.pass;
    } else if (prevDirection.horizontal == nextDirection.horizontal) {
      throw WrongFollowupDirectionException;
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

  /// calculates if there is a crossroad that needs to be passed;
  /// if there is one, then in the robotinstructions a pass will be added among all the other instructions like right and left [RobotInstructions]
  Queue<RobotInstructions> _patchMappedDirectionsToCoordinates() {
    List<Coordinate> lc = List.empty(growable: true);

    /// [mappedDirectionsToCoordinates] is not empty if this method is called
    final mapDirToCoo = Queue<MappedDirectionsToCoordinates>.from(
        mappedDirectionsToCoordinates);
    MappedDirectionsToCoordinates curr = mapDirToCoo.removeFirst(), next;
    Queue<RobotInstructions> robotInstructions = Queue();

    ///looping through {Direction, List of its Coordinates} object
    while (mapDirToCoo.isNotEmpty) {
      next = mapDirToCoo.removeFirst();
      final int cooLength = curr.coordinates.length;
      if (cooLength >= _minLengthOfCoordinates) {
        //if next direction occurs, then we want to search for route; so the variable is set to true
        final int percentageLength = percentageFrom(
          cooLength,
          _percentCoordinatesLength,
        ).round();
        Maze mazeTarget = Maze.route;
        int timesFoundWall = 0;

        ///looping though Coordinates of the direction from the while loop; only if the coordinate length is not too short
        COORDINATES_FOR_LOOP:
        for (int i = percentageLength;
            i < cooLength - percentageLength;
            i += 1) {
          final coo = curr.coordinates[i];
          int x = coo.xCoordinate, y = coo.yCoordinate;
          int counter = 0;
          PxResult pxFound;
          while ((pxFound =
                  _handlePixelInLoopContext(x, y, mazeTarget, counter))
              .carryOnLooping) {
            switch (next.directions) {
              case Directions.left:
                x--;
                break;
              case Directions.right:
                x++;
                break;
              case Directions.up:
                y--;
                break;
              case Directions.down:
                y++;
                break;
            }
            lc.add(Coordinate(x, y));
            counter++;
          }

          switch (pxFound) {
            case PxResult.foundCrossroad:
              robotInstructions.add(RobotInstructions.pass);
              mazeTarget = Maze.wall;
              break;
            case PxResult.foundWall:
              if (++timesFoundWall < _timesFoundWallLimit) continue;
              mazeTarget = Maze.route;
              timesFoundWall = 0;
              break;
            default:
              continue COORDINATES_FOR_LOOP;
          }
        }
        robotInstructions
            .add(_calcRobotIntruct(curr.directions, next.directions));
      }
      curr = next;
    }
    var cim = _imageMaze.image;
    for (var c in lc) {
      cim.setPixelRgb(c.xCoordinate, c.yCoordinate, 255, 166, 0);
    }
    _imageMaze = custom.Image(cim);
    return robotInstructions;
  }

  PxResult _handlePixelInLoopContext(
    int x,
    int y,
    Maze searchingForMaze,
    int counter,
  ) {
    // Get the pixel color from the (x, y) coordinates of the image maze
    var pxColor = _imageMaze.getImagePixelColour(x, y);

    // Check if the threshold has been reached
    bool isThresholdReached = counter >= _thresholdPixels;

    if (searchingForMaze == Maze.route) {
      // We are searching for a route, and we expect white color
      if (pxColor == C.wall) {
        return PxResult
            .foundMismatch; // A black pixel was found; stop looking for a crossroad
      }

      // If a white color is found and the threshold is reached, we found a crossroad; otherwise, we keep on searching
      return isThresholdReached ? PxResult.foundCrossroad : PxResult.foundRoute;
    } else if (searchingForMaze == Maze.wall) {
      // We are searching for a wall
      if (pxColor == C.route) {
        // A white pixel was found, but we expect black
        return isThresholdReached
            ? PxResult.foundMismatch
            : PxResult.notYetWall;
      } else if (pxColor == C.wall) {
        return PxResult.foundWall;
      }
    }

    return PxResult.err;
  }

  num percentageFrom(num originalValue, num percentage) =>
      originalValue * (percentage / 100);

  /*@override
  String toString() {
    return mappedDirectionsToCoordinates.toString();
  }*/
}
