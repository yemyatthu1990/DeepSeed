import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:flutter/material.dart';

class DraggableText extends StatefulWidget {
  DraggableTextState _draggableTextState = DraggableTextState();
  void setMaxXY(double maxX, double maxY) {
    _draggableTextState.setMaxXY(maxX, maxY);
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


  @override
  State<StatefulWidget> createState() {
    return _draggableTextState;
  }
}

class DraggableTextState extends State<DraggableText> {
  double maxY;
  double maxX;
  Offset offset;
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
  @override
  void initState() {
    offset = Offset(0, maxY/2);
    super.initState();
  }

  Widget container() => Positioned(
      width: MediaQuery.of(context).size.width,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (offset.dy + details.delta.dy+ context.size.height> maxY) return;
          if (offset.dy + details.delta.dy < 0 && details.delta.dy< 0) return;
          setState(() {
            offset = Offset(offset.dx, offset.dy + details.delta.dy);
          });
        },
        child: Container(
          color: currentColor,
          child: Padding(
            child: Text(value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: currentFont.family
                ),
                textAlign: TextAlign.center),
            padding: EdgeInsets.all(24),
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return container();
  }


}
