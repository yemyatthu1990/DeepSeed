import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/bloc/image_share_bloc.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

typedef void OnImageShareListener(String path);

class ImageShareDialog extends StatefulWidget {
  final bool initialValue;
  final Uint8List imageBytes;
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
        imageBytes: this.imageBytes,
        onImageShareListener: this.onImageShareListener);
  }
}

class ImageShareState extends State<ImageShareDialog> {
  bool initialValue;
  bool showProgress = false;
  final OnImageShareListener onImageShareListener;
  final Uint8List imageBytes;
  String filePath = "";
  String fileName = "";
  String currentUserId = "";
  ImageShareBloc _imageShareBloc;

  ImageShareState(
      {this.initialValue, this.imageBytes, this.onImageShareListener});
  @override
  void initState() {
    super.initState();
    _imageShareBloc = ImageShareBloc();
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
                    Padding(
                        padding: EdgeInsets.all(16),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(imageBytes))),
                    Padding(
                        padding: EdgeInsets.all(16),
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
                              Text("Share to DeepSeed community too")
                            ]))),
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
                          _imageShareBloc.getSharePhoto(imageBytes);
                        },
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Share",
                              style: TextStyle(color: Colors.black),
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
