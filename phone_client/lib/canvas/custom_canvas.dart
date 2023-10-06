import 'package:flutter/material.dart';

class CrossPainter extends CustomPainter {
  Offset crossCenter;
  Color? color;
  CrossPainter(this.crossCenter, {this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.pinkAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.05;

    const crossLength = 20;
    crossCenter = Offset(crossCenter.dx - 50, crossCenter.dy - 50);
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
