import 'package:flutter/material.dart' show Colors, Color;

enum Maze {
  wall(Colors.black),
  route(Colors.white);

  final Color color;
  const Maze(this.color);

  Maze negate() {
    if (this == wall) return route;
    return wall;
  }
}
