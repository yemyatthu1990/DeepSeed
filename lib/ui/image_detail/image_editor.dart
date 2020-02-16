import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/model/poem.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:deep_seed/ui/image_detail/draggable_text.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/preference_utils.dart';
import 'package:deep_seed/util/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

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
  final Urls photoUrls;
  final int index;
  String tempFileUrl;
  String fileUrl;
  ImageEditorState(this.photoUrls, this.index, this.tempFileUrl, this.fileUrl);
  DraggableText draggableText = DraggableText();
  double height = 0;
  ImageRatio imageRatio = ImageRatio.Instagram;
  Font currentFont = Font.CHERRY;
  String _textFieldText = "";
  bool isFavorite = false;
  IconData favoriteIcon = Icons.favorite_border;
  GlobalKey captureKey = GlobalKey();

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
    if (isFavorite) {
      favoriteIcon = Icons.favorite;
    } else {
      favoriteIcon = Icons.favorite_border;
    }
    return Scaffold(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          actions: <Widget>[
            InkWell(
                onTap: () {
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
                    Icons.save_alt,
                    color: Theme.of(context).primaryIconTheme.color,
                  ),
                ))
          ],
        ),
        body: SafeArea(
            child: Stack(children: <Widget>[
          RepaintBoundary(
              key: captureKey,
              child: Stack(
                children: <Widget>[
                  Hero(tag: widget.heroTag, child: image),
                  draggableText,
                ],
              )),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _bottomBar(),
                        Container(
                            margin: const EdgeInsets.only(left: 32, right: 32),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(4)),
                              ),
                              child: Padding(
                                child: TextField(
                                    controller: _textFieldText.length > 0
                                        ? TextEditingController.fromValue(
                                            TextEditingValue(
                                                text: _textFieldText,
                                                selection:
                                                    TextSelection.collapsed(
                                                        offset: _textFieldText
                                                            .length)))
                                        : null,
                                    focusNode: null,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: InputDecoration.collapsed(
                                        hintText: "Feeling..."),
                                    autofocus: false,
                                    onChanged: (value) =>
                                        {draggableText.setText(value)}),
                                padding: const EdgeInsets.all(12),
                              ),
                            )),
                      ])))
        ])));
  }

  Widget _bottomBar() {
    return Container(
      child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
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
                        DialogUtils.showColorChooser(
                                draggableText.getColor(), context)
                            .then((color) {
                          if (color != null) {
                            draggableText.setColor(color);
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
                        Firestore.instance
                            .collection("poems")
                            .snapshots(includeMetadataChanges: false)
                            .listen((data) {
                          List<Poem> poems = new List();
                          data.documents.forEach((snapshot) {
                            Poem poem = new Poem();
                            poem.body = snapshot["body"];
                            poem.title = snapshot["title"];
                            poem.author = snapshot["author"];
                            poems.add(poem);
                          });

                          DialogUtils.showPoemPickerDialog(context, poems)
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
                        });
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: const Icon(Icons.art_track))),
                ],
              ))
            ],
          )),
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

Future<Uint8List> _capturePng(GlobalKey globalKey) async {
  ui.Image image;
  bool catched = false;
  RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
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
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  }
}

_shareFinalImage(
    BuildContext context, GlobalKey captureKey, String imageRatio) {
  _capturePng(captureKey).then((pngBytes) {
    DialogUtils.showImageShareDialog(context, pngBytes, imageRatio)
        .then((imagePath) {
      if (imagePath != null) Utils.shareImage(imagePath);
    });
  });
}
