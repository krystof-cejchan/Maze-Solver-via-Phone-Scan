import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/custom_image_class/custom_image_class.dart'
    as custom;
import 'package:phone_client/helpers/hero_tag/hero_tag_generator.dart';
import 'package:phone_client/image_transformation/colour_picking/route_and_wall_global_constants.dart';
import 'package:phone_client/image_convertion_algorithm/classes,enums,exceptions_for_route_algorithm/coordinate.dart';
import 'package:phone_client/image_convertion_algorithm/classes,enums,exceptions_for_route_algorithm/coordinates.dart';
import 'package:phone_client/image_convertion_algorithm/search_maze_algorithms/normalizing_path_to_directions.dart';
import 'package:phone_client/image_convertion_algorithm/search_maze_algorithms/search_for_shortest_path_in_array.dart';

import '../../canvas/custom_canvas.dart';
import '../normalized_path_widget.dart';

///another class for choosing the destination in the image
class DestinationPicker extends StatefulWidget {
  const DestinationPicker(this.customImage, this.localCrossOffset, this.start,
      {super.key});
  final custom.Image customImage;

  /// local coordinates to show the cross
  final Offset localCrossOffset;

  /// x and y of the pixel picked as the start
  final Offset start;

  @override
  State<DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<DestinationPicker> {
  Offset crossCenter = Offset.zero, localCrossCenter = Offset.zero;
  final GlobalKey imageKey = GlobalKey();
  late GlobalKey currentKey;

  @override
  void initState() {
    currentKey = imageKey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: GestureDetector(
            onTapDown: (details) => setState(() {
              _onGuestureDetected(
                  details.globalPosition, details.localPosition);
            }),
            onPanUpdate: (details) => setState(() {
              _onGuestureDetected(
                  details.globalPosition, details.localPosition);
            }),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.redAccent)),
                  child: Image.memory(
                    widget.customImage.bytes,
                    key: imageKey,
                  ),
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: CrossPainter(localCrossCenter),
                ),
                CustomPaint(
                  size: const Size(200, 200),
                  painter: CrossPainter(
                    widget.localCrossOffset,
                    color: const Color.fromARGB(255, 29, 167, 236),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: FloatingActionButton.extended(
            heroTag: HeroTag.distinguisher,
            backgroundColor: const Color.fromARGB(255, 79, 255, 85),
            foregroundColor: const Color.fromARGB(195, 0, 0, 0),
            onPressed: _saveAndMoveOn,
            label: const Text('Save and find the shortest path'),
            icon: const Icon(Icons.route_outlined)));
  }

  void _onGuestureDetected(Offset globalPosition, Offset localPosition) {
    crossCenter = recalibrateOffset(globalPosition);
    localCrossCenter = localPosition;
  }

  Offset recalibrateOffset(Offset globalPosition) {
    currentKey = imageKey;
    RenderBox box = currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(
      Offset(
        globalPosition.dx - CrossPainter.fingerOffset,
        globalPosition.dy - CrossPainter.fingerOffset,
      ),
    );
    double widgetScale = box.size.width / widget.customImage.w;
    double px = localPosition.dx / widgetScale,
        py = localPosition.dy / widgetScale;

    return Offset(px, py);
  }

  void _saveAndMoveOn() {
    custom.Image customImageCopy = widget.customImage;
    final coordinateStartToFinish = Coordinates(
      widget.start.dx.toInt(),
      widget.start.dy.toInt(),
      crossCenter.dx.toInt(),
      crossCenter.dy.toInt(),
    );

    final List<List<int>> grid = List.empty(growable: true);
    for (int i = 0; i < customImageCopy.w; i++) {
      List<int> col = List.filled(customImageCopy.h, 0);
      for (int j = 0; j < customImageCopy.h; j++) {
        if (customImageCopy.isColourEqualToPixelColour(i, j, C.wall)) {
          col[j] = 1;
        }
      }
      //print(col);
      grid.add(col);
    }

    final List<Coordinate> shortestPath = PathInMatrix(
      grid,
      coordinateStartToFinish,
    ).foundPath;

    final normalizedDirections = NormalizedPathDirections(
      shortestPath,
      customImageCopy,
    );

    final img.Image imgImageCopy = widget.customImage.image;

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
        ));
  }
}
