import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/bloc/image_editor_bloc.dart';
import 'package:deep_seed/main.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/model/poem.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:deep_seed/ui/image_detail/draggable_text.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/Analytics.dart';
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
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageEditor extends StatefulWidget {
  final Urls photoUrls;
  final int index;
  final String tempFileUrl;
  final String fileUrl;
  final String heroTag;
  final String photographerName;
  final String username;

  ImageEditor(this.photoUrls, this.photographerName, this.username, this.index,
      this.tempFileUrl, this.fileUrl, this.heroTag);
  @override
  State<StatefulWidget> createState() {
    return ImageEditorState(photoUrls, index, tempFileUrl, this.fileUrl);
  }
}

class ImageEditorState extends State<ImageEditor> {
  String currentUserId = "";

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
          .then((map) {
        String shareText = (widget.photographerName != null)
            ? "Photo by " + widget.photographerName + " on Unsplash"
            : "";

        if (map != null) {
          if (map["shareToDeepseed"]) {
            _imageEditorBloc.getUser();
          }
          fileName = map["fileName"];
          refreshValue = 1;
          Utils.shareImage(fileName, shareText);
        }
      });
    });
  }

  String fileName = "";
  final Urls photoUrls;
  final int index;
  int refreshValue = -1;
  String tempFileUrl;
  String fileUrl;
  DraggableText draggableText = DraggableText();
  double height = 0;
  ImageRatio imageRatio = ImageRatio.Instagram;
  String currentFont = Encoding.isUnicode ? "Roboto" : "Zawgyi3";
  String _textFieldText = "";
  bool isFavorite = false;
  IconData favoriteIcon = Icons.favorite_border;
  GlobalKey captureKey = GlobalKey();
  ImageEditorState(this.photoUrls, this.index, this.tempFileUrl, this.fileUrl);
  double imageHeight = 0;
  bool showAdsLoading = false;
  double imageToScreenRatio = 0;
  double waterMarkPositionRight = 0;
  double imageWidth = 0;
  double devicePixelRatioModifier = 1;
  @override
  Widget build(BuildContext context) {
    var wouldBeImageHeight =
        MediaQuery.of(context).size.width * imageRatio.ratio;
    var leftOverSpace = (MediaQuery.of(context).size.height -
            kToolbarHeight -
            MediaQuery.of(context).padding.top -
            120 -
            96) -
        wouldBeImageHeight;
    if (leftOverSpace < 50) {
      leftOverSpace = 50;
    }

    devicePixelRatioModifier = leftOverSpace / 60.0;

    if (devicePixelRatioModifier > 1) devicePixelRatioModifier = 1;
    if (devicePixelRatioModifier >= 1)
      imageWidth = MediaQuery.of(context).size.width;
    else
      imageWidth =
          MediaQuery.of(context).size.width - (60 * devicePixelRatioModifier);

    imageHeight = height > 0 ? height : imageWidth * imageRatio.ratio;
    Image image = Image.file(new File(fileUrl),
        gaplessPlayback: true,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.cover);
    if (isFavorite) {
      favoriteIcon = Icons.favorite;
    } else {
      favoriteIcon = Icons.favorite_border;
    }
    draggableText.setWidth(imageWidth);
    draggableText.setMaxXY(0, imageHeight);
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
                        padding: EdgeInsets.all(16),
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
                        padding: EdgeInsets.all(16),
                        child: Icon(
                          Icons.share,
                          color: Theme.of(context).primaryIconTheme.color,
                        ),
                      ))
                ],
              ),
              body: Stack(children: <Widget>[
                Align(
                    alignment: Alignment.topLeft,
                    child: RepaintBoundary(
                        key: captureKey,
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: <Widget>[
                            Hero(tag: widget.heroTag, child: image),
                            draggableText,
                            if (RemoteConfigKey.showWaterMark)
                              Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                          padding: EdgeInsets.only(
                                              left: 8,
                                              right: 8,
                                              top: 4,
                                              bottom: 4),
                                          decoration: BoxDecoration(
                                              color: Colors.white38,
                                              borderRadius: BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(8.0))),
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: Text("deepseed.co",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color:
                                                          Colors.black54)))))),
                          ],
                        ))),
                if (widget.photographerName != null && widget.username != null)
                  Positioned(
                      top: image.height + (8),
                      left: 16,
                      child: Html(
                        data: """
                      Photo by 
                      <a href=https://unsplash.com/@${widget.username}?utm_source=DeepSeed&utm_medium=referral>${widget.photographerName}</a> 
                      on 
                      <a href=https://unsplash.com/?utm_source=DeepSeed&utm_medium=referral>Unsplash</a>
                      """,
                        defaultTextStyle:
                            TextStyle(fontFamily: 'serif', fontSize: 12),
                        linkStyle: const TextStyle(
                          color: Colors.orangeAccent,
                        ),
                        onLinkTap: (url) {
                          canLaunch(url).then((can) {
                            if (can) {
                              launch(url);
                            }
                          });
                        },
                      )),
                if (RemoteConfigKey.showWaterMark)
                  Positioned(
                      top: imageRatio == ImageRatio.Instagram
                          ? image.height
                          : image.height - 10 * devicePixelRatioModifier,
                      left: imageRatio == ImageRatio.Instagram
                          ? imageWidth - (16 * devicePixelRatioModifier)
                          : imageWidth - (68 * devicePixelRatioModifier),
                      child: SizedBox(
                        width: 20 * devicePixelRatioModifier,
                        height: 20 * devicePixelRatioModifier,
                        child: CustomPaint(
                          painter: ChatBubbleTriangle(
                              direction: imageRatio == ImageRatio.Instagram
                                  ? DIRECTION.TOP
                                  : DIRECTION.RIGHT),
                        ),
                      )),
                if (RemoteConfigKey.showWaterMark)
                  Positioned(
                      top: imageRatio == ImageRatio.Instagram
                          ? image.height + 30 * devicePixelRatioModifier
                          : image.height - 80 * devicePixelRatioModifier,
                      right: imageRatio == ImageRatio.Instagram
                          ? 0
                          : image.width > 310 ? 140 : image.width - 170,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.all(
                                Radius.circular(50 * devicePixelRatioModifier)),
                          ),
                          child: InkWell(
                              onTap: () {
                                setState(() {
                                  showAdsLoading = true;
                                });
                                String adUnitId = Platform.isAndroid
                                    ? "ca-app-pub-7811418762973637/6923904688"
                                    : "ca-app-pub-7811418762973637/9829888176";
                                RewardedVideoAd.instance.load(
                                    adUnitId: adUnitId,
                                    targetingInfo: MobileAdTargetingInfo(
                                        testDevices: [
                                          "kGADSimulatorID",
                                          "3F97607562BF91239F6A61ED252FE5A8"
                                        ],
                                        keywords: [
                                          "Poem",
                                          "Romantic",
                                          "Myanmar",
                                          "Teens"
                                        ]));
                                RewardedVideoAd.instance.listener =
                                    (adEvent, {rewardAmount, rewardType}) {
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
                                        RemoteConfigKey.showWaterMark = false;
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
                              child: Container(
                                  width: 220,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(18),
                                  child: Text(
                                    showAdsLoading
                                        ? "Loading Ads"
                                        : "View Ads to remove watermark?",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ))))),
                if (!(devicePixelRatioModifier < 1))
                  SafeArea(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _bottomBar()))
              ])),
          devicePixelRatioModifier < 1
              ? _verticalToolbar()
              : _horizontalToolbar(),
          SafeArea(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      margin: EdgeInsets.only(left: 32, right: 32, bottom: 16),
                      width: MediaQuery.of(context).size.width,
                      height: 60,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
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

  var _imageEditorBloc = ImageEditorBloc();
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
      _imageEditorBloc.authenticationListStream.listen((event) {
        if (event.status == Status.LOADING) {
          /*setState(() {
          showProgress = true;
      });*/
        } else if (event.status == Status.COMPLETED) {
          //user already login
          if (event.data != null) {
            currentUserId = event.data.uid;
            _imageEditorBloc.getShareFilePath(fileName).then((filePath) {
              _imageEditorBloc.uploadPhoto(currentUserId, filePath, fileName);
            });
          }
          //may be user is not logged in
          else {
            _imageEditorBloc.signIn();
          }
        }
      });

      _imageEditorBloc.storageTaskStream.listen((event) {
        if (event.status == Status.COMPLETED) {
          /*  setState(() {
          showProgress = false;
        });*/
          Feed feed = new Feed();
          feed.timeStamp = Timestamp.now().millisecondsSinceEpoch;
          feed.userId = currentUserId;
          feed.imageRatio = imageRatio.name;
          event.data.ref.getDownloadURL().then((value) {
            feed.downloadUrl = value.toString();
            _imageEditorBloc.uploadImage(feed);
          });
        }
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

    if (!Encoding.isUnicode) {
      PreferenceUtils.haveShownZawgyiDialog().then((value) {
        if (!value) DialogUtils.showZawgyiDialog(context);
      });
    }
  }

  Widget _bottomBar() {
    return Container(
      child: Padding(
          padding: EdgeInsets.fromLTRB(32, 8, 32, 0),
          child: Material(
              color: Theme.of(context).dialogBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        Analytics().logFontOpened();
                        DialogUtils.showFontChooser(
                                context, draggableText.getFontSize(),
                                (fontSize) {
                          draggableText.setFontSize(fontSize);
                        }, currentFont)
                            .then((font) {
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
                        Analytics().logColorOpened();
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
                        Analytics().logRatioChanged();
                        setState(() {
                          if (imageRatio.index < ImageRatio.values.length - 1) {
                            imageRatio =
                                ImageRatio.values[imageRatio.index + 1];
                          } else {
                            imageRatio = ImageRatio.values[0];
                          }

                          height = 0;
                        });
                        draggableText.setOffSet(
                            Offset(0, 80 * devicePixelRatioModifier));
                      },
                      child: Padding(
                          padding:
                              EdgeInsets.all(20 * devicePixelRatioModifier),
                          child: const Icon(Icons.aspect_ratio))),
                  InkWell(
                      onTap: () {
                        Analytics().logPoemOpened();
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
                          draggableText.setOffSet(
                              Offset(0, 80 * devicePixelRatioModifier));
                        });
                      },
                      child: Padding(
                          padding:
                              EdgeInsets.all(20 * devicePixelRatioModifier),
                          child: const ImageIcon(
                            AssetImage("graphics/poem.png"),
                            color: Colors.black,
                          ))),
                ],
              ))),
    );
  }

  Widget _horizontalToolbar() {
    return SafeArea(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                margin: EdgeInsets.only(bottom: 96 * devicePixelRatioModifier),
                width: MediaQuery.of(context).size.width,
                height: 60 * devicePixelRatioModifier,
                child: Material(
                    color: Theme.of(context).dialogBackgroundColor,
                    child: Container(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                32 * devicePixelRatioModifier,
                                0,
                                32 * devicePixelRatioModifier,
                                0),
                            child: Container(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                InkWell(
                                    onTap: () {
                                      Analytics().logFontOpened();
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      DialogUtils.showFontChooser(context,
                                              draggableText.getFontSize(),
                                              (fontSize) {
                                        draggableText.setFontSize(fontSize);
                                      }, currentFont)
                                          .then((font) {
                                        if (font != null) {
                                          setState(() {
                                            currentFont = font;
                                          });
                                          draggableText.setFont(font);
                                        }
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            20 * devicePixelRatioModifier),
                                        child:
                                            const Icon(Icons.font_download))),
                                InkWell(
                                    onTap: () {
                                      Analytics().logColorOpened();
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      DialogUtils.showColorChooser(
                                              draggableText.getColor(),
                                              draggableText.getFontColor(),
                                              context)
                                          .then((colors) {
                                        if (colors != null) {
                                          draggableText.setColor(colors);
                                        }
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            20 * devicePixelRatioModifier),
                                        child: const Icon(Icons.color_lens))),
                                InkWell(
                                    onTap: () {
                                      Analytics().logRatioChanged();
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      setState(() {
                                        if (imageRatio.index <
                                            ImageRatio.values.length - 1) {
                                          imageRatio = ImageRatio
                                              .values[imageRatio.index + 1];
                                        } else {
                                          imageRatio = ImageRatio.values[0];
                                        }

                                        height =
                                            MediaQuery.of(context).size.width *
                                                imageRatio.ratio;
                                      });
                                      draggableText.setOffSet(Offset(
                                          0, 80 * devicePixelRatioModifier));
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            20 * devicePixelRatioModifier),
                                        child: const Icon(Icons.aspect_ratio))),
                                InkWell(
                                    onTap: () {
                                      Analytics().logPoemOpened();
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
                                        draggableText.setText(_textFieldText);
                                        draggableText.setOffSet(Offset(
                                            0, 80 * devicePixelRatioModifier));
                                      });
                                    },
                                    child: Padding(
                                        padding: EdgeInsets.all(
                                            20 * devicePixelRatioModifier),
                                        child: const ImageIcon(
                                          AssetImage("graphics/poem.png"),
                                          color: Colors.black,
                                        )))
                              ],
                            ))))))));
  }

  Widget _verticalToolbar() {
    return SafeArea(
        child: Align(
            alignment: Alignment.topRight,
            child: Container(
                margin: EdgeInsets.only(top: kToolbarHeight + 8),
                height: imageHeight >= 300 ? 300 : imageHeight,
                child: Material(
                    color: Theme.of(context).dialogBackgroundColor,
                    child: Container(
                        child: Container(
                            child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        InkWell(
                            onTap: () {
                              Analytics().logFontOpened();
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              DialogUtils.showFontChooser(
                                      context, draggableText.getFontSize(),
                                      (fontSize) {
                                draggableText.setFontSize(fontSize);
                              }, currentFont)
                                  .then((font) {
                                if (font != null) {
                                  setState(() {
                                    currentFont = font;
                                  });
                                  draggableText.setFont(font);
                                }
                              });
                            },
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    14 * devicePixelRatioModifier,
                                    20 * devicePixelRatioModifier,
                                    14 * devicePixelRatioModifier,
                                    20 * devicePixelRatioModifier),
                                child: const Icon(Icons.font_download))),
                        InkWell(
                            onTap: () {
                              Analytics().logColorOpened();
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              DialogUtils.showColorChooser(
                                      draggableText.getColor(),
                                      draggableText.getFontColor(),
                                      context)
                                  .then((colors) {
                                if (colors != null) {
                                  draggableText.setColor(colors);
                                }
                              });
                            },
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    14 * devicePixelRatioModifier,
                                    20 * devicePixelRatioModifier,
                                    14 * devicePixelRatioModifier,
                                    20 * devicePixelRatioModifier),
                                child: const Icon(Icons.color_lens))),
                        InkWell(
                            onTap: () {
                              Analytics().logRatioChanged();
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              setState(() {
                                if (imageRatio.index <
                                    ImageRatio.values.length - 1) {
                                  imageRatio =
                                      ImageRatio.values[imageRatio.index + 1];
                                } else {
                                  imageRatio = ImageRatio.values[0];
                                }
                                height = 0;
                              });
                              draggableText.setOffSet(
                                  Offset(0, 80 * devicePixelRatioModifier));
                            },
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    14 * devicePixelRatioModifier,
                                    20 * devicePixelRatioModifier,
                                    14 * devicePixelRatioModifier,
                                    20 * devicePixelRatioModifier),
                                child: const Icon(Icons.aspect_ratio))),
                        InkWell(
                            onTap: () {
                              Analytics().logPoemOpened();
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              DialogUtils.showPoemPickerDialog(
                                      context,
                                      Firestore.instance
                                          .collection("poems")
                                          .snapshots(
                                              includeMetadataChanges: false))
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
                                draggableText.setOffSet(
                                    Offset(0, 80 * devicePixelRatioModifier));
                              });
                            },
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                    14 * devicePixelRatioModifier,
                                    20 * devicePixelRatioModifier,
                                    14 * devicePixelRatioModifier,
                                    20 * devicePixelRatioModifier),
                                child: const ImageIcon(
                                    AssetImage("graphics/poem.png"),
                                    color: Colors.black))),
                      ],
                    )))))));
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
