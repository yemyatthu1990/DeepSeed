import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/main.dart';
import 'package:deep_seed/model/poem.dart';
import 'package:deep_seed/repository/firebase_storage_repository.dart';
import 'package:deep_seed/ui/image_share/image_share_dialog.dart';
import 'package:deep_seed/ui/util/font_picker.dart';
import 'package:deep_seed/ui/util/poem_picker.dart';
import 'package:deep_seed/util/preference_utils.dart';
import 'package:deep_seed/util/rabbit.dart';
import 'package:deep_seed/view/ColorChanger.dart';
import 'package:deep_seed/view/StateAwareSlider.dart';
import 'package:deep_seed/view/about_me_dialog.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'block_picker.dart';

typedef OnFontSizeChangeListener(double fontSize);

class DialogUtils {
  static Future<String> showFontChooser(
      BuildContext context,
      double currentFontSize,
      OnFontSizeChangeListener onFontSizeChangeListener,
      String currentFontName) async {
    return await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return FontPicker(
            currentFontSize: currentFontSize,
            onFontSizeChangeListener: onFontSizeChangeListener,
            currentFontName: currentFontName,
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
    final String dialogBody =
        "ေဇာ္ဂ်ီေဖာင့္၏ အားနည္းခ်က္အခ်ိဳ႕ေၾကာင့္ DeepSeed application ကို အသုံးျပဳရာတြင္ ခ်ိဳ႕ယြင္းခ်က္မ်ားရွိႏိုင္ပါသည္. \nဥပမာ။ ေဖာင့္မမွန္ခ်င္း \n"
        "ပိုမိုေကာင္းမြန္ေသာ အေတြ႕အႀကဳံကိုရရွိရန္ \bယူနီကုတ္ေဖာင့္ကို ေျပာင္းလဲအသုံးျပဳဖို႔ တိုက္တြန္းလိုပါသည္။";
    final String dialogAction = Rabbit.uni2zg("Ok");

    return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            content: SingleChildScrollView(
              child: Text(dialogBody),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  dialogAction,
                  style: TextStyle(color: Colors.black, fontSize: 14),
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
