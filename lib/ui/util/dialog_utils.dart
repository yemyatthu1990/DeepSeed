

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
class DialogUtils {
 static Future<Font> showFontChooser(BuildContext context) async {

  return await showDialog<Font>(
       context: context,
       builder: (BuildContext context) {
         return SimpleDialog(
           title: const Text('Select fonts'),
           children: <Widget>[
             SimpleDialogOption(
               onPressed: () {
                   Navigator.pop(context, Font.CHERRY);
               },
               child: new Text(Font.CHERRY.name),
             ),
             SimpleDialogOption(
               onPressed: () {
                 Navigator.pop(context, Font.PADAUK_GHOST);
               },
               child: new Text(Font.PADAUK_GHOST.name, style: TextStyle(fontFamily: Font.PADAUK_GHOST.family),),
             )
           ],
         );
       }
   );
 }

  static Future<Color> showColorChooser(Color currentColor, BuildContext context) async {
   Color pickedColor;
    return await showDialog<Color>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select a color"),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: currentColor,
                onColorChanged: (color) {
                  pickedColor = color;
                },
                displayThumbColor: true,
                enableLabel: false,

              ),
            ),
            actions: <Widget>[
              FlatButton(
        child: const Text("Ok"),
        onPressed: () {
          Navigator.pop(context, pickedColor);
        },
      )
            ],
          );
        }
    );
  }

}

 enum Font {
  CHERRY, PADAUK_GHOST
}

extension FontExtension on Font {
  String get name {
    switch (this) {
      case Font.CHERRY:
        return "Cherry​\t\t\tကံကိုဆွဲ၍မှုန်း​သီခြယ်";
        break;
      case Font.PADAUK_GHOST:
        return "Padauk Ghost\t\t\tကံကိုဆွဲ၍မှုန်း​သီခြယ်";
        break;
    }
    return "";
  }

  String get family {
    switch(this) {

      case Font.CHERRY:
        return "Cherry";
        break;
      case Font.PADAUK_GHOST:
        return "Padauk Ghost";
        break;
    }
    return "";
  }
}