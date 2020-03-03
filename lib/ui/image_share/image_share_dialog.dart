import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/bloc/image_share_bloc.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/ui/image_detail/image_editor.dart';
import 'package:deep_seed/util/Analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

typedef void OnImageShareListener(String path);

class ImageShareDialog extends StatefulWidget {
  final bool initialValue;
  final Future<Uint8List> imageBytes;
  final String imageRatio;
  final OnImageShareListener onImageShareListener;

  ImageShareDialog(
      {this.initialValue,
      this.imageBytes,
      this.onImageShareListener,
      this.imageRatio});

  @override
  State<StatefulWidget> createState() {
    return ImageShareState(
        initialValue: this.initialValue,
        imageBytesFuture: this.imageBytes,
        onImageShareListener: this.onImageShareListener);
  }
}

class ImageShareState extends State<ImageShareDialog> {
  bool initialValue;
  bool showProgress = false;
  bool showLoading = true;
  final OnImageShareListener onImageShareListener;
  final Future<Uint8List> imageBytesFuture;
  Uint8List imgBytes;
  String filePath = "";
  String fileName = "";
  String currentUserId = "";
  ImageShareBloc _imageShareBloc;

  ImageShareState(
      {this.initialValue, this.imageBytesFuture, this.onImageShareListener});
  @override
  void initState() {
    super.initState();
    _imageShareBloc = ImageShareBloc();
    imageBytesFuture.then((value) {
      setState(() {
        imgBytes = value;
        showLoading = false;
      });
    });
    _imageShareBloc.authenticationListStream.listen((event) {
      if (event.status == Status.LOADING) {
        setState(() {
          showProgress = true;
        });
      } else if (event.status == Status.COMPLETED) {
        //user already login
        if (event.data != null) {
          currentUserId = event.data.uid;
          _imageShareBloc.uploadPhoto(currentUserId, filePath, fileName);
        }
        //may be user is not logged in
        else {
          _imageShareBloc.signIn();
        }
      }
    });
    _imageShareBloc.storageTaskStream.listen((event) {
      if (event.status == Status.COMPLETED) {
        setState(() {
          showProgress = false;
        });
        Feed feed = new Feed();
        feed.timeStamp = Timestamp.now().millisecondsSinceEpoch;
        feed.userId = currentUserId;
        feed.imageRatio = widget.imageRatio;
        event.data.ref.getDownloadURL().then((value) {
          feed.downloadUrl = value.toString();
          _imageShareBloc.uploadImage(feed);
        });
        onImageShareListener(fileName);
      }
    });
    _imageShareBloc.photoFilePathStream.listen((event) {
      if (event == null) {
        onImageShareListener(null);
      } else {
        if (initialValue == false) {
          onImageShareListener(event["name"]);
        } else {
          filePath = event["path"];
          fileName = event["name"];
          _imageShareBloc.getUser();
        }
      }
    });
  }

  @override
  void dispose() {
    _imageShareBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(30),
        child: Align(
            alignment: Alignment.center,
            child: Container(
                child: Wrap(children: [
              Material(
                  borderRadius: BorderRadius.circular(8),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    new LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      double width = constraints.maxWidth;

                      double height;
                      if (widget.imageRatio == ImageRatio.Instagram.name) {
                        height = width * ImageRatio.Instagram.ratio;
                      } else if (widget.imageRatio ==
                          ImageRatio.Facebook.name) {
                        height = width * ImageRatio.Facebook.ratio;
                      }

                      return showLoading
                          ? Container(
                              width: width,
                              height: height,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      ))))
                          : Container(
                              width: width,
                              height: height,
                              child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        imgBytes,
                                        gaplessPlayback: true,
                                      ))));
                    }),
                    Padding(
                        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                initialValue = !initialValue;
                              });
                            },
                            child:
                                Row(mainAxisSize: MainAxisSize.max, children: [
                              Checkbox(
                                onChanged: (value) {
                                  setState(() {
                                    initialValue = value;
                                  });
                                },
                                value: initialValue,
                              ),
                              Flexible( child: Text("Share to DeepSeed community too" ))
                            ]))),
                    Padding(
                        padding: EdgeInsets.only(left: 62, right: 16),
                        child: Html(
                          defaultTextStyle:
                              TextStyle(color: Colors.grey, fontSize: 12),
                          data: """
                      By selecting this, you agree to DeepSeed's 
                      <a href=https://terms.deepseed.co>Terms and Conditons</a>
                      """,
                          onLinkTap: (url) {
                            canLaunch(url).then((can) {
                              if (can) {
                                launch(url);
                              }
                            });
                          },
                        )),
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: _buildCircularProgress(),
                    ),
                    Divider(
                      color: Colors.grey,
                      endIndent: 16,
                      indent: 16,
                    ),
                    FlatButton(
                        onPressed: () {
                          Analytics().logShareImage(initialValue);
                          _imageShareBloc.getSharePhoto(imgBytes);
                        },
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "OK",
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 18),
                            ))),
                  ]))
            ]))));
  }

  Widget _buildCircularProgress() {
    if (showProgress)
      return CircularProgressIndicator(
        strokeWidth: 2.0,
      );
    else
      return Container();
  }
}
