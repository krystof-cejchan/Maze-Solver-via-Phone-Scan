import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:crop/crop.dart';
import 'package:phone_client/helpers/custom_image_class.dart' as custom;
import 'package:phone_client/image_transformation/image2routes.dart';

class ImageCropping extends StatefulWidget {
  const ImageCropping(
      {super.key,
      required this.image,
      required this.wallColour,
      required this.routeColour});
  final custom.Image image;
  final Color wallColour, routeColour;

  @override
  State<ImageCropping> createState() => _ImageCroppingState();
}

class _ImageCroppingState extends State<ImageCropping> {
  late final _defaultAspectRatio = widget.image.aspectRatio;
  late final controller = CropController(aspectRatio: _defaultAspectRatio);
  double _rotation = 0;
  BoxShape shape = BoxShape.rectangle;

  void _cropImage() async {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final ui.Image? cropped = await controller.crop(pixelRatio: pixelRatio);

    if (cropped == null || !mounted) {
      return;
    }
    //final custom.Image cImage = await Library.defImageToCustomImage(cropped);
    //print(cImage); //TODO on next activity, the image does not show up!
    _nextActivitySync(null, cropped);
  }

  void _nextActivitySync(custom.Image? cImg, ui.Image uiImg) =>
      _nextActivity(context, cImg, uiImg);

  void _nextActivity(BuildContext context, custom.Image? cImg, ui.Image uiImg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageConversion(uiImg, widget.wallColour, widget.routeColour),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: _cropImage,
            tooltip: 'Crop',
            icon: const Icon(Icons.crop),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(8),
              child: Crop(
                onChanged: (decomposition) {
                  if (_rotation != decomposition.rotation) {
                    setState(() {
                      _rotation = ((decomposition.rotation + 180) % 360) - 180;
                    });
                  }
                },
                controller: controller,
                shape: shape,
                /* It's very important to set `fit: BoxFit.cover`.*/
                helper: shape == BoxShape.rectangle
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const ui.Color.fromARGB(255, 101, 222, 100),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                      )
                    : null,
                child: Image.memory(
                  widget.image.bytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
                onPressed: () {
                  controller.rotation = 0;
                  controller.scale = 1;
                  controller.offset = Offset.zero;
                  setState(() {
                    _rotation = 0;
                  });
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: theme.sliderTheme.copyWith(
                    trackShape: CenteredRectangularSliderTrackShape(),
                  ),
                  child: Slider(
                    divisions: 360,
                    value: _rotation,
                    min: -180,
                    max: 180,
                    label: '$_rotation°',
                    onChanged: (n) {
                      setState(() {
                        _rotation = n.roundToDouble();
                        controller.rotation = _rotation;
                      });
                    },
                  ),
                ),
              ),
              PopupMenuButton<double>(
                icon: const Icon(Icons.aspect_ratio),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _defaultAspectRatio,
                    child: const Text(
                      "Original (Width/Height)",
                    ),
                  ),
                  PopupMenuItem(
                    value: widget.image.swappedAspectRatio,
                    child: const Text(
                      "Height/Width",
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 16.0 / 9.0,
                    child: Text("16:9"),
                  ),
                  const PopupMenuItem(
                    value: 4.0 / 3.0,
                    child: Text("4:3"),
                  ),
                  const PopupMenuItem(
                    value: 1,
                    child: Text("1:1"),
                  ),
                  const PopupMenuItem(
                    value: 3.0 / 4.0,
                    child: Text("3:4"),
                  ),
                  const PopupMenuItem(
                    value: 9.0 / 16.0,
                    child: Text("9:16"),
                  ),
                ],
                tooltip: 'Aspect Ratio',
                onSelected: (double selected) {
                  controller.aspectRatio = selected;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CenteredRectangularSliderTrackShape extends RectangularSliderTrackShape {
  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
  }) {
    if (sliderTheme.trackHeight! <= 0) {
      return;
    }

    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final trackCenter = trackRect.center;
    final Size thumbSize =
        sliderTheme.thumbShape!.getPreferredSize(isEnabled, isDiscrete);

    if (trackCenter.dx < thumbCenter.dx) {
      final Rect leftTrackSegment = Rect.fromLTRB(
          trackRect.left,
          trackRect.top,
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.bottom);
      if (!leftTrackSegment.isEmpty) {
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final activeRect = Rect.fromLTRB(
          trackCenter.dx, trackRect.top, thumbCenter.dx, trackRect.bottom);
      if (!activeRect.isEmpty) {
        context.canvas.drawRect(activeRect, activePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
          thumbCenter.dx + thumbSize.width / 2,
          trackRect.top,
          trackRect.right,
          trackRect.bottom);
      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    } else if (trackCenter.dx > thumbCenter.dx) {
      final Rect leftTrackSegment = Rect.fromLTRB(trackRect.left, trackRect.top,
          thumbCenter.dx + thumbSize.width / 2, trackRect.bottom);
      if (!leftTrackSegment.isEmpty) {
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final activeRect = Rect.fromLTRB(
        thumbCenter.dx + thumbSize.width / 2,
        trackRect.top,
        trackRect.center.dx,
        trackRect.bottom,
      );
      if (!activeRect.isEmpty) {
        context.canvas.drawRect(activeRect, activePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
        max(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
      );

      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    } else {
      final Rect leftTrackSegment = Rect.fromLTRB(
          trackRect.left,
          trackRect.top,
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.bottom);
      if (!leftTrackSegment.isEmpty) {
        context.canvas.drawRect(leftTrackSegment, inactivePaint);
      }

      final Rect rightTrackSegment = Rect.fromLTRB(
          min(trackCenter.dx, thumbCenter.dx - thumbSize.width / 2),
          trackRect.top,
          trackRect.right,
          trackRect.bottom);
      if (!rightTrackSegment.isEmpty) {
        context.canvas.drawRect(rightTrackSegment, inactivePaint);
      }
    }
  }
}
