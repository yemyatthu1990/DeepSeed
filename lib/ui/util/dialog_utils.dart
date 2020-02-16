import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/poem.dart';
import 'package:deep_seed/ui/image_share/image_share_dialog.dart';
import 'package:deep_seed/ui/util/poem_picker.dart';
import 'package:deep_seed/view/StateAwareSlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

typedef OnFontSizeChangeListener(double fontSize);

class DialogUtils {
  static Future<Font> showFontChooser(
      BuildContext context,
      double currentFontSize,
      OnFontSizeChangeListener onFontSizeChangeListener) async {
    var options = List<Widget>();
    options.add(StateAwareSlider(
        currentFontSize: currentFontSize,
        onFontSizeChangeListener: onFontSizeChangeListener));
    Font.values.forEach((element) {
      options.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, element);
        },
        child: new Text(
          element.name,
          style: TextStyle(fontFamily: element.family),
        ),
      ));
    });
    return await showDialog<Font>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Fonts'),
            children: options,
          );
        });
  }

  static Future<Color> showColorChooser(
      Color currentColor, BuildContext context) async {
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
        });
  }

  static Future<bool> showReportDialog(BuildContext context) async {
    return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select a color"),
            content: SingleChildScrollView(
              child: Text("Are you sure you want to report this?"),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: const Text("Report"),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });
  }

  static Future<String> showImageShareDialog(
    BuildContext context,
    Future<Uint8List> imageBytes,
    String imageRatio,
  ) async {
    return await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return ImageShareDialog(
            initialValue: true,
            onImageShareListener: (path) {
              Navigator.pop(context, path);
            },
            imageBytes: imageBytes,
            imageRatio: imageRatio,
          );
        });
  }

  static Future<Poem> showPoemPickerDialog(
      BuildContext context, Stream<QuerySnapshot> snapshots) async {
    return await showDialog<Poem>(
        context: context,
        builder: (BuildContext context) {
          return PoemPicker(snapshots: snapshots);
        });
  }
}

enum Font {
  CHERRY,
  PADAUK_GHOST,
  PAUK_LAY,
  PHET_SOT,
  PHIK_SEL,
  PONE_NYET,
  SABAE,
  SAGAR,
  SANPYA,
  TAGU,
  THURIYA,
  WASO,
  YINMAR
}

extension FontExtension on Font {
  String get name {
    return this.family + "​\t\t\tကံကိုဆွဲ၍မှုန်း​သီခြယ်";
  }

  String get family {
    switch (this) {
      case Font.CHERRY:
        return "Cherry";
      case Font.PADAUK_GHOST:
        return "Padauk Ghost";
      case Font.PAUK_LAY:
        return "Pauk Lay";
      case Font.PHET_SOT:
        return "Phet Sot";
      case Font.PHIK_SEL:
        return "Phik Sel";
      case Font.PONE_NYET:
        return "Pone Nyet";
      case Font.SABAE:
        return "Sabae";
      case Font.SAGAR:
        return "Sagar";
      case Font.SANPYA:
        return "San Pya";
      case Font.TAGU:
        return "Tagu";
      case Font.THURIYA:
        return "Thuriya";
      case Font.WASO:
        return "Waso";
      case Font.YINMAR:
        return "Yinmar";
    }
    return "";
  }
}
