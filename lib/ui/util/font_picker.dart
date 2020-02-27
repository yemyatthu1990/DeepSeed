import 'package:deep_seed/main.dart';
import 'package:deep_seed/repository/firebase_storage_repository.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/rabbit.dart';
import 'package:deep_seed/util/utils.dart';
import 'package:deep_seed/view/StateAwareSlider.dart';
import 'package:flutter/material.dart';

class FontPicker extends StatefulWidget {
  final double currentFontSize;
  final OnFontSizeChangeListener onFontSizeChangeListener;
  final String currentFontName;
  FontPicker(
      {this.currentFontSize,
      this.onFontSizeChangeListener,
      this.currentFontName});

  @override
  State<StatefulWidget> createState() {
    return FontPickerState();
  }
}

class FontPickerState extends State<FontPicker> {
  bool showLoading = true;
  List<String> fonts = new List();
  FirebaseStorageRepository storageRepository = FirebaseStorageRepository();
  @override
  void initState() {
    super.initState();
    storageRepository.downloadAllFonts(Encoding.isUnicode).then((value) {
      setState(() {
        fonts = value;
        showLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration = BoxDecoration(
        border: Border.all(
            width: 1.0, style: BorderStyle.solid, color: Colors.grey),
        borderRadius: BorderRadius.all(Radius.circular(5.0)));
    List<Widget> childWidgets = new List();
    String fontExample = "ကံကိုဆွဲ၍မှုန်း​သီခြယ်";
    if (!Encoding.isUnicode) fontExample = Rabbit.uni2zg(fontExample);
    childWidgets.add(new SimpleDialogOption(
      child: StateAwareSlider(
          currentFontSize: widget.currentFontSize,
          onFontSizeChangeListener: widget.onFontSizeChangeListener),
    ));
    fonts.forEach((font) {
      String fontWithoutExtension = font.replaceAll(".ttf", "");
      Container container = Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10.0),
        decoration: fontWithoutExtension == widget.currentFontName
            ? decoration.copyWith(color: Colors.orangeAccent)
            : decoration,
        child: Text(
          fontWithoutExtension + "\t\t\t$fontExample",
          style: TextStyle(fontFamily: fontWithoutExtension),
        ),
      );

      childWidgets.add(new SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, fontWithoutExtension);
        },
        child: container,
      ));
    });
    return SimpleDialog(
      title: Text("Choose Font", style: TextStyle(fontSize: 16)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      children: showLoading
          ? [
              Container(
                  decoration: decoration,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  padding: EdgeInsets.all(100),
                  child: Center(
                      child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ))))
            ]
          : childWidgets,
    );
  }
}
