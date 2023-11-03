import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/image_proccessing/colour_picking/route_and_wall_global_constants.dart';
import 'package:phone_client/image_transformation/widget__normalized_path.dart';
import 'package:phone_client/route_algorithms/classes,enums,exceptions_for_route_algorithm/coordinate.dart';
import 'package:phone_client/route_algorithms/classes,enums,exceptions_for_route_algorithm/coordinates.dart';
import 'package:phone_client/route_algorithms/normalizing_path_to_directions.dart';
import 'package:phone_client/route_algorithms/search_for_shortest_path_in_array.dart';

import '../helpers/custom_image_class.dart' as custom;

class LoadingScreenForPath extends StatefulWidget {
  final custom.Image pixels;
  final Coordinates coordinateStartToFinish;
  const LoadingScreenForPath(this.pixels, this.coordinateStartToFinish,
      {super.key});

  @override
  State<StatefulWidget> createState() => _LoadingScreenForPathWidget();
}

class _LoadingScreenForPathWidget extends State<LoadingScreenForPath> {
  @override
  Widget build(BuildContext context) {
    //TODO
    a();
    return Text(" *describe what is happening in the background* ");
  }

//TODO
  void a() {
    custom.Image customImageCopy = widget.pixels;

    final List<List<int>> grid = List.empty(growable: true);
    for (int i = 0; i < customImageCopy.w; i++) {
      List<int> col = List.filled(customImageCopy.h, 0);
      for (int j = 0; j < customImageCopy.h; j++) {
        if (customImageCopy.isColourEqualToPixelColour(i, j, C.wall)) {
          col[j] = 1;
        }
      }
      grid.add(col);
    }

    final List<Coordinate> shortestPath = PathInMatrix(
      grid,
      widget.coordinateStartToFinish,
    ).foundPath;

    final normalizedDirections = NormalizedPathDirections(
      shortestPath,
      customImageCopy,
    );

    final img.Image imgImageCopy = widget.pixels.image;

    for (int i = 0; i < shortestPath.length; i++) {
      final pieceOfPath = shortestPath[i];
      imgImageCopy.setPixel(
        pieceOfPath.xCoordinate,
        pieceOfPath.yCoordinate,
        img.ColorInt8.rgb(50, 255, 0),
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NormalizedPathWidget(normalizedDirections,
            pathImage: custom.Image(imgImageCopy)),
      ),
    );
  }
}
