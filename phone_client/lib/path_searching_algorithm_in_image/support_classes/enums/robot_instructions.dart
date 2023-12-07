/// [RobotInstructions] enum represents commands that the robot will follow
enum RobotInstructions {
  left,
  right,
  pass;

  @override
  String toString() => name.toUpperCase();
}
