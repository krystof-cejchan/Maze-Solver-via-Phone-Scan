import 'package:flutter/material.dart';
import 'package:phone_client/helpers/custom_image_class.dart' as custom;
import 'package:phone_client/maze_route/search_maze_algorithms/normalizing_path_to_directions.dart';

class NormalizedPathWidget extends StatefulWidget {
  const NormalizedPathWidget(this.normDirections, {super.key, this.pathImage});
  final NormalizedPathDirections normDirections;
  final custom.Image? pathImage;
  @override
  State<StatefulWidget> createState() => _NormalizedPathState();
}

/// shows the shortest path with its directions
class _NormalizedPathState extends State<NormalizedPathWidget> {
  @override
  Widget build(BuildContext context) {
    /*print(widget.normDirections.mappedDirectionsToCoordinates
        .map((e) => e.directions)
        .toList()
        .toString());
    print(widget.normDirections.mappedDirectionsToCoordinates
        .map((e) => e.coordinates.length)
        .toList());*/
    return Column(
      children: [
        Image.memory(widget.pathImage!.bytes),
        /*Flexible(
          child: Text(
            widget.normDirections.mappedDirectionsToCoordinates.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ),*/
        Flexible(
          child: Text(
            widget.normDirections.robotInstructions.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
