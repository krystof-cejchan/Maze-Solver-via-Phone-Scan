import 'robot_instructions.dart';

/// enum values representing a direction the robot or anything going from the start to the end has from the point of view of a 2d image/array
enum Directions {
  left(true),
  right(true),
  up(false),
  down(false);

  final bool horizontal;
  const Directions(this.horizontal);
  RobotInstructions directionsToRobotInstruction() =>
      RobotInstructions.values.firstWhere((element) => element.name == name);
}
