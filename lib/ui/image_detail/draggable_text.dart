import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';

class DraggableText extends StatefulWidget {
  DraggableTextState _draggableTextState = DraggableTextState();
  void setMaxXY(double maxX, double maxY) {
    _draggableTextState.setMaxXY(maxX, maxY);
  }

  void setFontSize(double size) {
    _draggableTextState.setFontSize(size);
  }

  double getFontSize() {
    return _draggableTextState.getFontSize();
  }

  void setFont(Font font) {
    _draggableTextState.setFont(font);
  }

  void setText(String value) {
    _draggableTextState.setText(value);
  }

  void setColor(Color color) {
    _draggableTextState.setColor(color);
  }

  void setOffSet(Offset offset) {
    _draggableTextState.setOffSet(offset);
  }

  Color getColor() => _draggableTextState.currentColor;

  double getHeight() => _draggableTextState.context.size.height;

  @override
  State<StatefulWidget> createState() {
    return _draggableTextState;
  }
}

class DraggableTextState extends State<DraggableText> {
  double maxY;
  double maxX;
  Offset offset;
  double fontSize = 18;
  String value = "Write something here";
  Font currentFont = Font.CHERRY;
  Color currentColor = Colors.black12;
  void setMaxXY(double maxX, double maxY) {
    this.maxY = maxY;
    this.maxX = maxX;
  }

  void setText(String value) {
    setState(() {
      this.value = value;
    });
  }

  void setFont(Font font) {
    setState(() {
      currentFont = font;
    });
  }

  void setColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  void setOffSet(Offset offset) {
    setState(() {
      this.offset = offset;
    });
  }

  Size getSize() {
    return context.size;
  }

  @override
  void initState() {
    offset = Offset(0, maxY / 2);
    super.initState();
  }

  Widget container() {
    double startOffset = 0;
    return Positioned(
        width: MediaQuery.of(context).size.width,
        top: offset.dy,
        child: GestureDetector(
            onPanStart: (value) {
              startOffset = value.localPosition.dy;
            },
            onPanUpdate: (value) {
              setState(() {
                if (offset.dy + value.delta.dy + context.size.height > maxY &&
                    startOffset - value.localPosition.dy <= 0) return;
                if (offset.dy + value.delta.dy < 0 && value.delta.dy < 0)
                  return;

                setState(() {
                  offset = Offset(offset.dx, offset.dy + value.delta.dy);
                });
              });
            },
            child: Container(
                color: currentColor,
                child: Padding(
                  child: Text(value,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontFamily: currentFont.family),
                      textAlign: TextAlign.center),
                  padding: EdgeInsets.all(24),
                ))));
  }

  @override
  Widget build(BuildContext context) {
    return container();
  }

  void setFontSize(double size) {
    setState(() {
      fontSize = size;
    });
  }

  double getFontSize() {
    return fontSize;
  }
}
