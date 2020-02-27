import 'dart:ui';

import 'package:deep_seed/main.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/rabbit.dart';
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
  double fontSize = 18;
  String value = "";
  Font currentFont = Font.SABAE;
  String zawgyiFontFamily = "Zawgyi";
  Color currentColor = Colors.black38;
  Color currentFontColor = Colors.white;
  FocusNode _focusNode = FocusNode();
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
    if (!Encoding.isUnicode) {
      bool isEncoding = false;
      _focusNode.addListener(() {
        if (!Encoding.isUnicode) {
          setState(() {
            if (isEncoding) return;
            isEncoding = true;
            if (_focusNode.hasFocus) {
              zawgyiFontFamily = "Zawgyi";
              value = Rabbit.uni2zg(value);
            } else {
              zawgyiFontFamily = currentFont.family;
              value = Rabbit.zg2uni(value);
            }
            isEncoding = false;
          });
        }
      });
    }
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
                      keyboardType: TextInputType.multiline,
                      maxLines: 100,
                      minLines: 1,
                      decoration: InputDecoration(border: InputBorder.none),
                      style: TextStyle(
                          height: 2,
                          color: currentFontColor,
                          fontSize: fontSize,
                          fontFamily: Encoding.isUnicode
                              ? currentFont.family
                              : zawgyiFontFamily),
                      textAlign: TextAlign.center,
                      enableSuggestions: false,
                      autocorrect: false,
                      focusNode: Encoding.isUnicode ? null : _focusNode,
                      autofocus: true),
                  padding: EdgeInsets.only(left: 16, right: 16),
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
    _focusNode.dispose();
    super.dispose();
  }
}
