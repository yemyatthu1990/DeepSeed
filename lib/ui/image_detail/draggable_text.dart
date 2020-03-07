import 'dart:ui';
import 'package:deep_seed/main.dart';
import 'package:flutter/material.dart';

class DraggableText extends StatefulWidget {
  DraggableTextState _draggableTextState = DraggableTextState();
  void setWidth(double width) {
    _draggableTextState.setWidth(width);
  }

  void setMaxXY(double maxX, double maxY) {
    _draggableTextState.setMaxXY(maxX, maxY);
  }

  void setFontSize(double size) {
    _draggableTextState.setFontSize(size);
  }

  double getFontSize() {
    return _draggableTextState.getFontSize();
  }

  void setFont(String font) {
    _draggableTextState.setFont(font);
  }

  void setText(String value) {
    _draggableTextState.setText(value);
  }

  void setColor(List<Color> colors) {
    _draggableTextState.setColor(colors);
  }

  void setOffSet(Offset offset) {
    _draggableTextState.setOffSet(offset);
  }

  Color getColor() => _draggableTextState.currentColor;
  Color getFontColor() => _draggableTextState.currentFontColor;
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
  double fontSize = 0;
  String value = "";
  String currentFont = Encoding.isUnicode ? "Roboto" : "Zawgyi3";
  Color currentColor = Colors.black38;
  Color currentFontColor = Colors.white;
  double width = 0;
  double pixelRatio = 1;
  void setWidth(double width) {
    this.width = width;
  }

  void setPixelRatio(double pixelRatio) {
    this.pixelRatio = pixelRatio;
  }

  void setMaxXY(double maxX, double maxY) {
    this.maxY = maxY;
    this.maxX = maxX;
  }

  void setText(String value) {
    setState(() {
      this.value = value;
    });
  }

  void setFont(String font) {
    setState(() {
      currentFont = font;
    });
  }

  void setColor(List<Color> colors) {
    setState(() {
      currentColor = colors[0];
      currentFontColor = colors[1];
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
    offset = Offset(0, maxY / 4);
    if (width == 0) width = MediaQuery.of(context).size.width;
    if (fontSize == 0) fontSize = 14;
    super.initState();
  }

  Widget container() {
    double startOffset = 0;
    return Positioned(
        width: width,
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
                  child: TextField(
                      controller: value.length > 0
                          ? TextEditingController.fromValue(TextEditingValue(
                              text: value,
                              selection: TextSelection.collapsed(
                                  offset: value.length)))
                          : null,
                      onChanged: (changedText) {
                        value = changedText;
                      },
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      maxLines: 10000,
                      minLines: 1,
                      decoration: InputDecoration(border: InputBorder.none),
                      style: TextStyle(
                          height: 2 * pixelRatio,
                          color: currentFontColor,
                          fontSize: fontSize,
                          fontFamily: currentFont),
                      textAlign: TextAlign.center,
                      enableSuggestions: false,
                      autocorrect: false,
                      autofocus: true),
                  padding: EdgeInsets.only(
                      left: 16 * pixelRatio, right: 16 * pixelRatio),
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

  @override
  void dispose() {
    super.dispose();
  }
}
