import 'package:flutter/material.dart';

import '../utils/constants.dart';

class VerticalTimeSlider extends StatelessWidget {
  const VerticalTimeSlider({
    super.key,
    this.color,
    this.thickness = 1.0,
  });

  final Color? color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        double.infinity,
        thickness,
      ),
      painter: _VerticalSliderPainter(),
    );
  }
}

class _VerticalSliderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = kInactiveSliderWidth; // Width
    const double dashSpace = kInactiveSliderWidth;

    final Paint paint = Paint()
      ..color = kTimeSliderInactiveColor
      ..strokeWidth = kSliderHeight // Height
      ..style = PaintingStyle.stroke;

    double currentX = 0;
    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX + dashWidth, 0),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
