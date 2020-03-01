import 'package:flutter/material.dart';

enum DIRECTION { TOP, RIGHT }

class ChatBubbleTriangle extends CustomPainter {
  final DIRECTION direction;
  ChatBubbleTriangle({this.direction = DIRECTION.TOP});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color(0xFFEEEEEE);

    var path = Path();
    if (direction == DIRECTION.TOP) {
      path.lineTo(-5, 50);

      path.lineTo(5, 50);
    } else if (direction == DIRECTION.RIGHT) {
      path.lineTo(-50, -20);
      path.lineTo(-80, -20);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
