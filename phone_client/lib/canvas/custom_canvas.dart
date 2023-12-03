import 'package:flutter/material.dart';

/// custom canvas for painting crosses
/// used for marking the start and end of a route
class CrossPainter extends CustomPainter {
  static int fingerOffset = 50;
  Offset crossCenter;
  Color color;
  CrossPainter(this.crossCenter, {this.color = Colors.pinkAccent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.05;

    const crossLength = 20;
    crossCenter = Offset(
      crossCenter.dx - fingerOffset,
      crossCenter.dy - fingerOffset,
    );
    //print("${crossCenter.dx} ${crossCenter.dy}");

    //horizontal line of the cross
    canvas.drawLine(
      Offset(crossCenter.dx - crossLength, crossCenter.dy),
      Offset(crossCenter.dx + crossLength, crossCenter.dy),
      paint,
    );

    //vertical line of the cross
    canvas.drawLine(
      Offset(crossCenter.dx, crossCenter.dy - crossLength),
      Offset(crossCenter.dx, crossCenter.dy + crossLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
