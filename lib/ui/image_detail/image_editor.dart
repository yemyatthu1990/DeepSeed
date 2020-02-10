import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:deep_seed/ui/image_detail/draggable_text.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';

class ImageEditor extends StatefulWidget {
  final Urls photoUrls;
  final int index;
  final String tempFileUrl;
  ImageEditor(this.photoUrls, this.index, this.tempFileUrl);
  @override
  State<StatefulWidget> createState() {
    return ImageEditorState(photoUrls, index, tempFileUrl);
  }
}

class ImageEditorState extends State<ImageEditor> {
  final Urls photoUrls;
  final int index;
  final String tempFileUrl;
  ImageEditorState(this.photoUrls, this.index, this.tempFileUrl);
  DraggableText draggableText = DraggableText();
  double height = 0;
  ImageRatio imageRatio = ImageRatio.Facebook;
  Font currentFont = Font.CHERRY;
  GlobalKey captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    CachedNetworkImage image = CachedNetworkImage(
        imageUrl: photoUrls.regular,
        placeholderFadeInDuration: Duration.zero,
        placeholder: (context, string) => Image.file(new File(tempFileUrl),
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height:
                height > 0 ? height : MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              imageRatio.ratio),
        width: MediaQuery.of(context).size.width,
        height: height > 0 ? height : MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              imageRatio.ratio,
        fit: BoxFit.cover);
    draggableText.setMaxXY(0, image.height - 40);
    return Scaffold(
        body: Stack(children: <Widget>[
      RepaintBoundary(
          key: captureKey,
          child: Stack(
            children: <Widget>[
              Hero(
                  tag: heroPhotoTag + index.toString(),
                  child: Material(child: image)),
              draggableText
            ],
          )),
      Align(
          alignment: Alignment.bottomCenter,
          child: Container(

              padding: EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 32, right: 32),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0.0,
                          child: Padding(
                            child: TextField(
                                decoration: InputDecoration.collapsed(
                                    hintText: "Feeling..."),
                                autofocus: false,
                                onChanged: (value) =>
                                    {draggableText.setText(value)}),
                            padding: EdgeInsets.all(12),
                          ),
                        )),
                    Container(
                      child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                             Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                               Padding(
                                padding: EdgeInsets.all(20),
                                    child: InkWell(
                                  onTap: () {
                                    DialogUtils.showFontChooser(context).then((
                                        font) {
                                      if (font != null) {
                                        setState(() {
                                          currentFont = font;
                                        });
                                        draggableText.setFont(font);
                                      }
                                    });
                                  },
                                  child: SvgPicture.asset(
                                'graphics/icon/font.svg',
                                height: 32,
                                width: 32,
                              )
                              )),
                              Padding(
                                  padding: EdgeInsets.all(20),
                              child: InkWell(
                                  onTap: () {
                                    DialogUtils.showColorChooser(draggableText.getColor(), context).then((
                                        color) {
                                      if (color != null) {
                                        draggableText.setColor(color);
                                      }
                                    });
                                  },
                              child: SvgPicture.asset(
                                'graphics/icon/art.svg',
                                height: 32,
                                width: 32,
                              ))),
                             
                              Padding(
                                padding: EdgeInsets.all(20),
                                  child: InkWell(
                                  onTap: () {
                                    setState(() {

                                      if (imageRatio.index < ImageRatio.values.length-1) {
                                        imageRatio =
                                        ImageRatio.values[imageRatio.index + 1];

                                      } else {
                                        imageRatio = ImageRatio.values[0];
                                      }

                                      height = MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              imageRatio.ratio;
                                    });

                                    /*_capturePng(captureKey); */
                                  },
                                  child: SvgPicture.asset(
                                    'graphics/icon/ratio.svg',
                                    height: 32,
                                    width: 32,
                                  ))
                              )
                            ],
                          ),
                           Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              SizedBox(width: 60,height: 30, child: Text(currentFont.family, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontFamily: currentFont.family),)),
                              SizedBox(width: 60,height: 30, child: Text("Color", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, ))),
                              SizedBox(width: 60,height: 30, child: Text(imageRatio.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, )))
                            ],
                          )
                          ],)
                           ),
                    )
                  ])))
    ]));
  }
}

enum ImageRatio { Facebook, Instagram, Story, Cover}

extension ImageRatioExtension on ImageRatio {
  double get ratio {
    switch(this) {

      case ImageRatio.Facebook:
        return 1.33;
        break;
      case ImageRatio.Instagram:
        return 1.0;
        break;
      case ImageRatio.Story:
        return 1.77;
        break;
      case ImageRatio.Cover:
        return 0.6;
        break;
    }
    return 1.0;
  }

  String get name {
       switch(this) {

      case ImageRatio.Facebook:
        return "Facebook";
        break;
      case ImageRatio.Instagram:
        return "Instagram";
        break;
      case ImageRatio.Story:
        return "Story";
        break;
      case ImageRatio.Cover:
        return "Cover";
        break;
    }
    return "";
  }
}

Future<void> _capturePng(GlobalKey globalKey) async {
  ui.Image image;
  bool catched = false;
  RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
  try {
    image = await boundary.toImage();
    catched = true;
  } catch (exception) {
    catched = false;
    Timer(Duration(milliseconds: 1), () {
      _capturePng(globalKey);
    });
  }
  if (catched) {
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
  }
}
