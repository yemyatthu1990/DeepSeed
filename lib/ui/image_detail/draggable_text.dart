import 'package:flutter/material.dart';

class DraggableText extends StatefulWidget {
  DraggableTextState _draggableTextState = DraggableTextState();
  void setMaxXY(double maxX, double maxY) {
    _draggableTextState.setMaxXY(maxX, maxY);
  }

  void setText(String value) {
    _draggableTextState.setText(value);
  }

  @override
  State<StatefulWidget> createState() {
    return _draggableTextState;
  }
}

class DraggableTextState extends State<DraggableText> {
  double maxY;
  double maxX;
  Offset offset;
  String value = "Default value";
  void setMaxXY(double maxX, double maxY) {
    this.maxY = maxY;
    this.maxX = maxX;
    print(maxY.toString() + "Max Y");
    print(maxX.toString() + "Max X");
  }

  void setText(String value) {
    setState(() {
      this.value = value;
    });
  }

  @override
  void initState() {
    offset = Offset(0, 0);
    super.initState();
  }

  Widget container() => Positioned(
      width: MediaQuery.of(context).size.width,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          if (offset.dy + details.delta.dy > maxY) return;
          if (offset.dy + details.delta.dy < 0 && details.delta.dy < 0) return;
          setState(() {
            print(details);
            offset = Offset(offset.dx, offset.dy + details.delta.dy);
            print(maxY);
            print(offset);
          });
        },
        child: Container(
          color: Colors.black12,
          child: Padding(
            child: Text(value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
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
