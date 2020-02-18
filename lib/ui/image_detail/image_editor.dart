import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/main.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/model/poem.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:deep_seed/ui/image_detail/draggable_text.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/jumping_dots.dart';
import 'package:deep_seed/util/preference_utils.dart';
import 'package:deep_seed/util/utils.dart';
import 'package:deep_seed/view/chat_bubble_triangle.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ImageEditor extends StatefulWidget {
  final Urls photoUrls;
  final int index;
  final String tempFileUrl;
  final String fileUrl;
  final String heroTag;

  ImageEditor(
      this.photoUrls, this.index, this.tempFileUrl, this.fileUrl, this.heroTag);
  @override
  State<StatefulWidget> createState() {
    return ImageEditorState(photoUrls, index, tempFileUrl, this.fileUrl);
  }
}

class ImageEditorState extends State<ImageEditor> {
  Future<Uint8List> _capturePng(GlobalKey globalKey) async {
    ui.Image image;
    bool catched = false;
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    try {
      image = await boundary.toImage(pixelRatio: 2);
      catched = true;
    } catch (exception) {
      catched = false;
      Timer(Duration(milliseconds: 1), () {
        _capturePng(globalKey);
      });
    }
    if (catched) {
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      return pngBytes;
    }
  }

  _shareFinalImage(
      BuildContext context, GlobalKey captureKey, String imageRatio) {
    FocusScope.of(context).requestFocus(new FocusNode());
    Future.delayed(Duration(milliseconds: 200), () {
      DialogUtils.showImageShareDialog(
              context, _capturePng(captureKey), imageRatio)
          .then((imagePath) {
        if (imagePath != null) {
          refreshValue = 1;
          Utils.shareImage(imagePath);
        }
      });
    });
  }

  final Urls photoUrls;
  final int index;
  int refreshValue = -1;
  String tempFileUrl;
  String fileUrl;
  DraggableText draggableText = DraggableText();
  double height = 0;
  ImageRatio imageRatio = ImageRatio.Instagram;
  Font currentFont = Font.WASO;
  String _textFieldText = "";
  bool isFavorite = false;
  IconData favoriteIcon = Icons.favorite_border;
  GlobalKey captureKey = GlobalKey();
  ImageEditorState(this.photoUrls, this.index, this.tempFileUrl, this.fileUrl);
  double imageHeight = 0;
  bool showAdsLoading = false;
  @override
  Widget build(BuildContext context) {
    Image image = Image.file(new File(fileUrl),
        gaplessPlayback: true,
        width: MediaQuery.of(context).size.width,
        height: height > 0
            ? height
            : MediaQuery.of(context).size.width * imageRatio.ratio,
        fit: BoxFit.cover);
    draggableText.setMaxXY(0, image.height);
    imageHeight = image.height;
    if (isFavorite) {
      favoriteIcon = Icons.favorite;
    } else {
      favoriteIcon = Icons.favorite_border;
    }
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, refreshValue);
          return false;
        },
        child: Stack(children: [
          Scaffold(
              backgroundColor: Theme.of(context).dialogBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                actions: <Widget>[
                  InkWell(
                      onTap: () {
                        refreshValue = 2;
                        setState(() {
                          isFavorite = !isFavorite;
                        });

                        if (isFavorite)
                          PreferenceUtils.addToFavorite(
                              widget.photoUrls.small, widget.photoUrls.full);
                        else
                          PreferenceUtils.removeFromFavorite(
                              widget.photoUrls.small, widget.photoUrls.full);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          favoriteIcon,
                          color: Theme.of(context).primaryIconTheme.color,
                        ),
                      )),
                  InkWell(
                      onTap: () {
                        _shareFinalImage(context, captureKey, imageRatio.name);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.share,
                          color: Theme.of(context).primaryIconTheme.color,
                        ),
                      ))
                ],
              ),
              body: Stack(children: <Widget>[
                RepaintBoundary(
                    key: captureKey,
                    child: Stack(
                      children: <Widget>[
                        Hero(tag: widget.heroTag, child: image),
                        draggableText,
                        if (WaterMark.show)
                          Positioned(
                              top: image.height - 16,
                              left: image.width - 80,
                              child: Container(
                                  padding: EdgeInsets.only(left: 8, right: 8),
                                  decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8.0))),
                                  child: Text("deepseed.co",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: Font.SAGAR.family,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black54)))),
                      ],
                    )),
                if (WaterMark.show)
                  Positioned(
                      top: imageRatio == ImageRatio.Instagram
                          ? image.height
                          : image.height - 10,
                      right: imageRatio == ImageRatio.Instagram ? 16 : 68,
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CustomPaint(
                          painter: ChatBubbleTriangle(
                              direction: imageRatio == ImageRatio.Instagram
                                  ? DIRECTION.TOP
                                  : DIRECTION.RIGHT),
                        ),
                      )),
                if (WaterMark.show)
                  Positioned(
                      top: imageRatio == ImageRatio.Instagram
                          ? image.height + 10
                          : image.height - 40,
                      right: imageRatio == ImageRatio.Instagram ? 0 : 96,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          ),
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  showAdsLoading = true;
                                });

                                RewardedVideoAd.instance.load(
                                    adUnitId: RewardedVideoAd.testAdUnitId,
                                    targetingInfo: MobileAdTargetingInfo());
                                RewardedVideoAd.instance.listener =
                                    (adEvent, {rewardAmount, rewardType}) {
                                  print(adEvent);
                                  if (adEvent == RewardedVideoAdEvent.loaded) {
                                    if (showAdsLoading) {
                                      setState(() {
                                        showAdsLoading = false;
                                      });
                                    }
                                    RewardedVideoAd.instance.show();
                                  } else if (adEvent ==
                                      RewardedVideoAdEvent.rewarded) {
                                    Fluttertoast.showToast(
                                        msg: "Closing Video automatically...");
                                    Future.delayed(Duration(milliseconds: 3000),
                                        () {
                                      setState(() {
                                        WaterMark.show = false;
                                      });
                                      RewardedVideoAd.instance.destroy();
                                      Fluttertoast.showToast(
                                          msg:
                                              "Thank you! Watermark will be removed for this session.");
                                    });
                                  } else {
                                    if (showAdsLoading)
                                      setState(() {
                                        showAdsLoading = false;
                                      });
                                  }
                                };
                              },
                              child: showAdsLoading
                                  ? SizedBox(
                                      width: 228,
                                      child: JumpingDotsProgressIndicator(
                                        fontSize: 30.0,
                                      ))
                                  : Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        "Remove Watermark for FREE?",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ))))),
                SafeArea(
                    child: Align(
                        alignment: Alignment.bottomCenter, child: _bottomBar()))
              ])),
          SafeArea(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      margin: const EdgeInsets.only(bottom: 96),
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      child: Material(
                          color: Theme.of(context).dialogBackgroundColor,
                          child: Container(
                              child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(32, 0, 32, 0),
                                  child: Container(
                                      child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      InkWell(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                            DialogUtils.showFontChooser(context,
                                                draggableText.getFontSize(),
                                                (fontSize) {
                                              draggableText
                                                  .setFontSize(fontSize);
                                            }).then((font) {
                                              if (font != null) {
                                                setState(() {
                                                  currentFont = font;
                                                });
                                                draggableText.setFont(font);
                                              }
                                            });
                                          },
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: const Icon(
                                                  Icons.font_download))),
                                      InkWell(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                            DialogUtils.showColorChooser(
                                                    draggableText.getColor(),
                                                    draggableText
                                                        .getFontColor(),
                                                    context)
                                                .then((colors) {
                                              if (colors != null) {
                                                draggableText.setColor(colors);
                                              }
                                            });
                                          },
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: const Icon(
                                                  Icons.color_lens))),
                                      InkWell(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                            setState(() {
                                              if (imageRatio.index <
                                                  ImageRatio.values.length -
                                                      1) {
                                                imageRatio = ImageRatio.values[
                                                    imageRatio.index + 1];
                                              } else {
                                                imageRatio =
                                                    ImageRatio.values[0];
                                              }

                                              height = MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  imageRatio.ratio;
                                            });
                                            draggableText
                                                .setOffSet(Offset(0, 80));
                                          },
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: const Icon(
                                                  Icons.aspect_ratio))),
                                      InkWell(
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                            DialogUtils.showPoemPickerDialog(
                                                    context,
                                                    Firestore.instance
                                                        .collection("poems")
                                                        .snapshots(
                                                            includeMetadataChanges:
                                                                false))
                                                .then((poem) {
                                              if (poem == null) return;
                                              setState(() {
                                                _textFieldText = poem.body +
                                                    "\n\n" +
                                                    poem.title +
                                                    " - " +
                                                    poem.author;
                                              });
                                              draggableText
                                                  .setText(_textFieldText);
                                              draggableText
                                                  .setOffSet(Offset(0, 80));
                                            });
                                          },
                                          child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child:
                                                  const Icon(Icons.art_track))),
                                    ],
                                  )))))))),
          SafeArea(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      margin: const EdgeInsets.only(
                          left: 32, right: 32, bottom: 16),
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                          ),
                          child: FlatButton(
                              onPressed: () {
                                _shareFinalImage(
                                    context, captureKey, imageRatio.name);
                              },
                              child: Text(
                                "Share",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ))))))
        ]));
  }

  @override
  void initState() {
    super.initState();
    if (fileUrl == null || fileUrl.isEmpty) {
      fileUrl = tempFileUrl;
      PreferenceUtils.isFavorite(photoUrls.small, photoUrls.full).then((value) {
        setState(() {
          isFavorite = value;
        });
      });
      if (fileUrl != photoUrls.full) {
        ImageCacheManager().downloadFile(photoUrls.full).then((fileInfo) {
          //Delayed so that the image will not flash
          Future.delayed(Duration(milliseconds: 300), () {
            setState(() {
              fileUrl = fileInfo.file.path;
            });
          });
        });
      }
    }
  }

  Widget _bottomBar() {
    return Container(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
          child: Material(
              color: Theme.of(context).dialogBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        DialogUtils.showFontChooser(
                            context, draggableText.getFontSize(), (fontSize) {
                          draggableText.setFontSize(fontSize);
                        }).then((font) {
                          if (font != null) {
                            setState(() {
                              currentFont = font;
                            });
                            draggableText.setFont(font);
                          }
                        });
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: const Icon(Icons.font_download))),
                  InkWell(
                      onTap: () {
                        DialogUtils.showColorChooser(draggableText.getColor(),
                                draggableText.getFontColor(), context)
                            .then((colors) {
                          if (colors != null) {
                            draggableText.setColor(colors);
                          }
                        });
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: const Icon(Icons.color_lens))),
                  InkWell(
                      onTap: () {
                        setState(() {
                          if (imageRatio.index < ImageRatio.values.length - 1) {
                            imageRatio =
                                ImageRatio.values[imageRatio.index + 1];
                          } else {
                            imageRatio = ImageRatio.values[0];
                          }

                          height = MediaQuery.of(context).size.width *
                              imageRatio.ratio;
                        });
                        draggableText.setOffSet(Offset(0, 80));
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: const Icon(Icons.aspect_ratio))),
                  InkWell(
                      onTap: () {
                        DialogUtils.showPoemPickerDialog(
                                context,
                                Firestore.instance
                                    .collection("poems")
                                    .snapshots(includeMetadataChanges: false))
                            .then((poem) {
                          if (poem == null) return;
                          setState(() {
                            _textFieldText = poem.body +
                                "\n\n" +
                                poem.title +
                                " - " +
                                poem.author;
                          });
                          draggableText.setText(_textFieldText);
                          draggableText.setOffSet(Offset(0, 80));
                        });
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: const Icon(Icons.art_track))),
                ],
              ))),
    );
  }
}

enum ImageRatio { Facebook, Instagram }

extension ImageRatioExtension on ImageRatio {
  double get ratio {
    switch (this) {
      case ImageRatio.Facebook:
        return 1.33;
        break;
      case ImageRatio.Instagram:
        return 1.0;
        break;
    }
    return 1.0;
  }

  String get name {
    switch (this) {
      case ImageRatio.Facebook:
        return "Facebook";
        break;
      case ImageRatio.Instagram:
        return "Instagram";
    }
    return "";
  }
}
