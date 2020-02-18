import 'package:flutter/material.dart';
enum DIRECTION {
  TOP,RIGHT
}
class ChatBubbleTriangle extends CustomPainter {
  final DIRECTION direction;
  ChatBubbleTriangle({this.direction = DIRECTION.TOP});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color =Color(0xFFEEEEEE);

    var path = Path();
    if (direction == DIRECTION.TOP) {
    path.lineTo(-10, 10);
      path.lineTo(0, 10);
      path.lineTo(10, 10);
    } else if (direction == DIRECTION.RIGHT) {

        path.lineTo(-10, -10);
      path.lineTo(-10, 0);
      path.lineTo(-10, 10);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}