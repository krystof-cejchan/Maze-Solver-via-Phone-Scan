import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:phone_client/helpers/lib_class.dart';
import '../../helpers/custom_image_class.dart' as custom;
import './wall_colour_picker.dart' as wall;

class ColorPickerWidget extends StatefulWidget {
  const ColorPickerWidget({super.key, required this.image});
  final custom.Image image;
  @override
  ColorPickerWidgetState createState() => ColorPickerWidgetState();
}

class ColorPickerWidgetState extends State<ColorPickerWidget> {
  late final custom.Image _image;
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  int toastTime = DateTime.timestamp().millisecondsSinceEpoch;
  Color pickedRouteColour = Colors.black;

  late GlobalKey currentKey;

  final StreamController<Color> _stateController = StreamController<Color>();
  final initColour = const Color.fromARGB(255, 36, 36, 36);
  @override
  void initState() {
    currentKey = imageKey;
    _image = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            RepaintBoundary(
              key: paintKey,
              child: GestureDetector(
                onPanDown: (details) {
                  searchPixel(details.globalPosition);
                },
                onPanUpdate: (details) {
                  searchPixel(details.globalPosition);
                },
                child: Center(
                  child: Image.memory(
                    _image.bytes,
                    key: imageKey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: StreamBuilder<Color>(
        initialData: initColour,
        stream: _stateController.stream,
        builder: (buildContext, snapshot) {
          final colour = snapshot.data ?? initColour;
          return FloatingActionButton.extended(
            backgroundColor: colour,
            foregroundColor: _invertColour(colour),
            onPressed: _saveAndMoveOn,
            icon: const Icon(Icons.save_as),
            label: Text('Save Route Colour',
                style: TextStyle(
                    color: _invertColour(colour), backgroundColor: colour)),
          );
        },
      ),
    );
  }

  Color _invertColour(Color color) {
    final r = 255 - color.red;
    final g = 255 - color.green;
    final b = 255 - color.blue;

    return Color.fromARGB((color.opacity * 255).round(), r, g, b);
  }

  void searchPixel(Offset globalPosition) {
    if (_image.isNotValid()) {
      return;
    }
    currentKey = imageKey;
    _calculatePixel(globalPosition);
  }

  void _calculatePixel(Offset position) {
    RenderBox box = currentKey.currentContext!.findRenderObject() as RenderBox;
    Offset localPosition = box.globalToLocal(position);

    double px = localPosition.dx;
    double py = localPosition.dy;
    double widgetScale = box.size.width / _image.w;
    px /= widgetScale;
    py /= widgetScale;

    try {
      img.Pixel pixel = _image.image.getPixel(px.toInt(), py.toInt());
      Color colour = Library.pixelColour(pixel);
      _stateController.add(colour);
      pickedRouteColour = colour;
    } on RangeError {
      if (_haveFiveSecondsPassed()) {
        Fluttertoast.showToast(
          msg: "Out of Range",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: const Color.fromARGB(255, 28, 2, 2),
          fontSize: 16.0,
        );
      }
    }
  }

  bool _haveFiveSecondsPassed() {
    final b = DateTime.timestamp().millisecondsSinceEpoch - toastTime >=
        const Duration(seconds: 5).inMilliseconds;
    if (b) toastTime = DateTime.timestamp().millisecondsSinceEpoch;
    return b;
  }

  void _saveAndMoveOn() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => wall.ColorPickerWidget(
                image: _image,
                routeColour: pickedRouteColour,
              )),
    );
  }
}
