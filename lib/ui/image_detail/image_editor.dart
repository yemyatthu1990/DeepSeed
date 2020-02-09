import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/ui/image_detail/draggable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';

class ImageEditor extends StatefulWidget {
  final Urls photoUrls;
  final int index;
  ImageEditor(this.photoUrls, this.index);
  @override
  State<StatefulWidget> createState() {
    return ImageEditorState(photoUrls, index);
  }
}

class ImageEditorState extends State<ImageEditor> {
  final Urls photoUrls;
  final int index;
  ImageEditorState(this.photoUrls, this.index);
  DraggableText draggableText = DraggableText();
  double height = 0;
  ImageRatio imageRatio = ImageRatio.Instagram;
  GlobalKey captureKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    CachedNetworkImage image = CachedNetworkImage(
        imageUrl: photoUrls.full,
        placeholder: (context, url) => CachedNetworkImage(
            imageUrl: photoUrls.small,
            width: MediaQuery.of(context).size.width,
            height: height > 0 ? height : MediaQuery.of(context).size.height,
            fit: BoxFit.fitHeight),
        width: MediaQuery.of(context).size.width,
        height: height > 0 ? height : MediaQuery.of(context).size.height,
        fit: BoxFit.fitHeight);
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
              color: Color(0xfffafafa),
              padding: EdgeInsets.all(32),
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
                                onChanged: (value) =>
                                    {draggableText.setText(value)}),
                            padding: EdgeInsets.all(12),
                          ),
                        )),
                    Container(
                      color: Color(0xfffafafa),
                      child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              SvgPicture.asset(
                                'graphics/android/font.svg',
                                height: 32,
                                width: 32,
                              ),
                              SvgPicture.asset(
                                'graphics/android/art.svg',
                                height: 32,
                                width: 32,
                              ),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      switch (imageRatio) {
                                        case ImageRatio.Facebook:
                                          height = MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.75.toDouble());
                                          imageRatio = ImageRatio.Instagram;
                                          break;
                                        case ImageRatio.Instagram:
                                          height = MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              (0.5625.toDouble());
                                          imageRatio = ImageRatio.Facebook;
                                          break;
                                      }
                                    });

                                    /*_capturePng(captureKey); */
                                  },
                                  child: SvgPicture.asset(
                                    'graphics/android/ratio.svg',
                                    height: 32,
                                    width: 32,
                                  ))
                            ],
                          )),
                    )
                  ])))
    ]));
  }
}

enum ImageRatio { Facebook, Instagram }

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
