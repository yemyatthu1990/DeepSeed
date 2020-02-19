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
      path.lineTo(-5, 30);

      path.lineTo(5, 30);
    } else if (direction == DIRECTION.RIGHT) {
      path.lineTo(-22, -18);
      path.lineTo(-50, -18);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
