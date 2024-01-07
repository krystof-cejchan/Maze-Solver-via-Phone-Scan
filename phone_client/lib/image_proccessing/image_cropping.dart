import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:crop/crop.dart';
import 'package:phone_client/custom_image/custom_image_class.dart' as custom;
import 'package:phone_client/image_transformation/reachability_input_picking/start_picker.dart';

import 'centered_rect_slider.dart';

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

    _nextActivitySync(null, cropped);
  }

  void _nextActivitySync(custom.Image? cImg, ui.Image uiImg) =>
      _nextActivity(context, cImg, uiImg);

  void _nextActivity(BuildContext context, custom.Image? cImg, ui.Image uiImg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageConversion(uiImg, widget.routeColour, widget.wallColour),
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
                      "Swapped (Height/Width)",
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
