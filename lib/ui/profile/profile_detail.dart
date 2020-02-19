import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/bloc/image_share_bloc.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/util/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnImageShareListener(String path);

class ProfileDetailDialog extends StatelessWidget {
  final String filePath;
  final String heroTag;
  ProfileDetailDialog({this.filePath, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          print("tap");
          Navigator.pop(context);
        },
        child: Scaffold(
            backgroundColor: Colors.black,
            body: GestureDetector(
                onTap: () {},
                child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                            child: Wrap(children: [
                          Material(
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Hero(
                                            tag: heroTag,
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                    File(filePath))))),
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                    ),
                                    Divider(
                                      color: Colors.grey,
                                      endIndent: 16,
                                      indent: 16,
                                    ),
                                    FlatButton(
                                        onPressed: () {
                                          File(filePath)
                                              .readAsBytes()
                                              .then((value) async {
                                            String fileName = Timestamp.now()
                                                    .millisecondsSinceEpoch
                                                    .toString() +
                                                ".jpg";
                                            final tempDir =
                                                await getTemporaryDirectory();
                                            final file = await new File(
                                                    '${tempDir.path}/$fileName')
                                                .create();
                                            file.writeAsBytesSync(value);
                                            return fileName;
                                          }).then((fileName) =>
                                                  Utils.shareImage(fileName));
                                        },
                                        child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Share",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ))),
                                  ]))
                        ])))))));
  }
}
