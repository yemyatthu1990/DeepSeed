import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/poem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_colorpicker/material_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                child: new Text(
                  Font.PADAUK_GHOST.name,
                  style: TextStyle(fontFamily: Font.PADAUK_GHOST.family),
                ),
              )
            ],
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

  static Future<ImageShare> showImageShareDialog(
      BuildContext context, Uint8List imageBytes) async {
    return await showDialog<ImageShare>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Image.memory(imageBytes),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.share
                ),
                onPressed: () {
                  Navigator.pop(context, ImageShare.SHARE);
                },
              )
            ],
          );
        });
  }

  static Future<Poem> showPoemPickerDialog(
      BuildContext context, List<Poem> poems) async {
    BoxDecoration decoration = BoxDecoration(
        border: Border.all(
            width: 1.0, style: BorderStyle.solid, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(5.0)));
    List<Widget> childWidgets = new List();
    poems.forEach((poem) {
      Container container = Container(
        padding: const EdgeInsets.all(10.0),
        decoration: decoration,
        child: IntrinsicHeight(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(child: Text(poem.body)),
            Text(poem.author),
          ],
        )),
      );

      childWidgets.add(new SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, poem);
        },
        child: container,
      ));
    });
    return await showDialog<Poem>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: childWidgets,
          );
        });
  }
}

enum ImageShare { DOWNLOAD, SHARE }

enum Font { CHERRY, PADAUK_GHOST }

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
    switch (this) {
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
