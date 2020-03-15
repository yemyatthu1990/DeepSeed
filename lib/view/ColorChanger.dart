import 'package:deep_seed/ui/util/block_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnColorPicked(Color bgColor, Color fontColor, bool showShadow);

class ColorChanger extends StatefulWidget {
  final Color currentColor;
  final Color currentFontColor;
  final bool currentShadowEnabled;
  final OnColorPicked onColorPicked;
  ColorChanger(
      {this.currentColor = Colors.white,
      this.currentFontColor = Colors.white,
      this.currentShadowEnabled = false,
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
    bool isShadowEnabled = widget.currentShadowEnabled;
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
                                    height: MediaQuery.of(context).size.height /
                                                1.49 >
                                            500
                                        ? 500
                                        : MediaQuery.of(context).size.height /
                                            1.49,
                                    child: TabBarView(children: [
                                      Container(
                                          child: BlockPicker(
                                        alphaValue: widget.currentColor.alpha
                                            .toDouble(),
                                        showAlphaPicker: true,
                                        showShadowPicker: false,
                                        pickerColor: pickedColor,
                                        onColorChanged: (color) {
                                          pickedColor = color;
                                        },
                                        onShadowChanged: (value) {
                                          //do nothing
                                        },
                                      )),
                                      Container(
                                          child: BlockPicker(
                                        alphaValue: widget
                                            .currentFontColor.alpha
                                            .toDouble(),
                                        showAlphaPicker: false,
                                        showShadowPicker: true,
                                        isShadowEnabled: isShadowEnabled,
                                        pickerColor: pickedFontColor,
                                        onColorChanged: (color) {
                                          pickedFontColor = color;
                                        },
                                        onShadowChanged: (value) {
                                          isShadowEnabled = value;
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
                            widget.onColorPicked(
                                pickedColor, pickedFontColor, isShadowEnabled);
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
