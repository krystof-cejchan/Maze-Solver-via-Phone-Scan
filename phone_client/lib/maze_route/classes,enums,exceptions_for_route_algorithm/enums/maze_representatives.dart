import 'package:flutter/material.dart' show Color;
import 'package:phone_client/image_proccessing/colour_picking/route_and_wall_global_constants.dart';

enum Maze {
  wall(C.wall),
  route(C.route);

  final Color color;
  const Maze(this.color);

  Maze negate() {
    if (this == wall) return route;
    return wall;
  }
}
