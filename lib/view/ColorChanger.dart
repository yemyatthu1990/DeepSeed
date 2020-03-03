import 'package:deep_seed/ui/util/block_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnColorPicked(Color bgColor, Color fontColor);

class ColorChanger extends StatefulWidget {
  final Color currentColor;
  final Color currentFontColor;
  final OnColorPicked onColorPicked;
  ColorChanger(
      {this.currentColor = Colors.white,
      this.currentFontColor = Colors.white,
      this.onColorPicked});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ColorChangerState();
  }
}

class ColorChangerState extends State<ColorChanger> {
  @override
  Widget build(BuildContext context) {
    Color pickedColor = widget.currentColor;
    Color pickedFontColor = widget.currentFontColor;
    return Padding(
        padding: EdgeInsets.all(30),
        child: Align(
            alignment: Alignment.center,
            child: Container(
                child: Wrap(children: [
              Material(
                  borderRadius: BorderRadius.circular(8),
                  child: Wrap(children: [
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      DefaultTabController(
                          length: 2,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TabBar(
                                  controller: DefaultTabController.of(context),
                                  tabs: <Widget>[
                                    Padding(
                                        padding:
                                            EdgeInsets.only(top: 16, bottom: 8),
                                        child: Text(
                                          "Background",
                                          style: TextStyle(fontSize: 16),
                                        )),
                                    Padding(
                                        padding:
                                            EdgeInsets.only(top: 16, bottom: 8),
                                        child: Text(
                                          "Font",
                                          style: TextStyle(fontSize: 16),
                                        )),
                                  ],
                                ),
                                Container(
                                    height: MediaQuery.of(context).size.height/1.49 > 500?
                                    500: MediaQuery.of(context).size.height/1.49,
                                    child: TabBarView(children: [
                                      Container(

                                          child: BlockPicker(
                                            alphaValue: widget
                                                .currentColor.alpha
                                                .toDouble(),
                                            pickerColor: widget.currentColor,
                                            onColorChanged: (color) {
                                              pickedColor = color;
                                            },
                                          )),
                                      Container(

                                          child: BlockPicker(
                                            alphaValue: widget
                                                .currentFontColor.alpha
                                                .toDouble(),
                                            showAlphaPicker: false,
                                            pickerColor:
                                                widget.currentFontColor,
                                            onColorChanged: (color) {
                                              pickedFontColor = color;
                                            },
                                          )),
                                    ]))
                              ])),
                      Divider(
                        color: Colors.grey,
                        endIndent: 16,
                        indent: 16,
                      ),
                      FlatButton(
                          onPressed: () {
                            widget.onColorPicked(pickedColor, pickedFontColor);
                          },
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "OK",
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 18),
                              )))
                    ])
                  ]))
            ]))));
  }
}
