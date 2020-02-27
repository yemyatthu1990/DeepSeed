import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/poem.dart';
import 'package:deep_seed/ui/image_share/image_share_dialog.dart';
import 'package:deep_seed/ui/util/poem_picker.dart';
import 'package:deep_seed/util/preference_utils.dart';
import 'package:deep_seed/view/ColorChanger.dart';
import 'package:deep_seed/view/StateAwareSlider.dart';
import 'package:deep_seed/view/about_me_dialog.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'block_picker.dart';

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
        child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 4),
            child: new Text(
              element.name,
              style: TextStyle(fontFamily: element.family),
            )),
      ));
    });
    return await showDialog<Font>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            title: const Text('Fonts'),
            children: options,
          );
        });
  }

  static Future<List<Color>> showColorChooser(
      Color currentColor, Color currentFontColor, BuildContext context) async {
    return await showDialog<List<Color>>(
        context: context,
        builder: (BuildContext context) {
          return ColorChanger(
              currentColor: currentColor,
              currentFontColor: currentFontColor,
              onColorPicked: (bgColor, fontColor) =>
                  Navigator.pop(context, [bgColor, fontColor]));
        });
  }

  static void showAboutMe(BuildContext context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              contentPadding: EdgeInsets.all(0),
              content: SingleChildScrollView(
                  child: AboutMeDialog(info: packageInfo)));
        });
  }

  static Future<bool> showZawgyiDialog(BuildContext context) async {
    PreferenceUtils.zawgyiDialogHasShown();
    return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            title: Text(
              "ဇော်ဂျီဖောင့်အသုံးပြုမှုအတွက် အသိပေးချက်",
              style: TextStyle(fontFamily: Font.CHERRY.family),
            ),
            content: SingleChildScrollView(
              child: Text(
                  "ဇော်ဂျီဖောင့်၏ အားနည်းချက်အချို့ကြောင့် DeepSeed application ကို အသုံးပြုရာတွင် ချို့ယွင်းချက်များရှိနိုင်ပါသည်. ဥပမာ။ ဖောင့်မမှန်ချင်း \n"
                  "ပိုမိုကောင်းမွန်သော အတွေ့အကြုံကိုရရှိရန် ယူနီကုတ်ဖောင့်ကို ပြောင်းလဲအသုံးပြုဖို့ တိုက်တွန်းလိုပါသည်။",
                  style: TextStyle(fontFamily: Font.CHERRY.family)),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text(
                  "အိုကေ",
                  style: TextStyle(
                      color: Colors.black, fontSize: 14, fontFamily: "Cherry"),
                ),
                onPressed: () {
                  Navigator.pop(context, true);
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            title: Text("Are you sure you want to report this?"),
            content: SingleChildScrollView(
              child: Text(
                  "Photos that have nudity, violence, animal abuse, and harrasment should be reported."),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              FlatButton(
                child: const Text(
                  "Report",
                  style: TextStyle(color: Colors.redAccent),
                ),
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
