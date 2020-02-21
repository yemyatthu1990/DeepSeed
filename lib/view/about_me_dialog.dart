import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/bloc/image_share_bloc.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/ui/image_detail/image_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

typedef void OnImageShareListener(String path);

class AboutMeDialog extends StatelessWidget {
  final PackageInfo info;
  AboutMeDialog({this.info});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(24, 30, 24, 0),
        child: Align(
            alignment: Alignment.center,
            child: Container(
                child: Wrap(children: [
              Material(
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Image.asset("graphics/app_icon.png"),
                        )),
                    SizedBox(
                      height: 12,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          info.appName != null ? info.appName : "DeepSeed",
                          style: TextStyle(fontSize: 24, color: Colors.black87),
                        )),
                    SizedBox(
                      height: 8,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Version ${info.version != null ? info.version : "1.0.0"}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        )),
                    SizedBox(
                      height: 24,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Imagination makes the world \na better place",
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(
                      height: 80,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              String url = "https://terms.deepseed.co";
                              canLaunch(url).then((value) {
                                if (value) {
                                  launch(url);
                                }
                              });
                            },
                            child: Text("Privacy policy",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.blueAccent))),
                        FlatButton(
                            onPressed: () {
                              final Email email = Email(
                                body: 'Hello DeepSeed team, \n',
                                subject:
                                    'Feedback regarding DeepSeed ${Platform.operatingSystem} app',
                                recipients: ['deepseed.co@gmail.com'],
                                isHTML: false,
                              );
                              FlutterEmailSender.send(email);
                            },
                            child: Text("Send feedback",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.blueAccent))),
                      ],
                    ),
                    Divider(
                      color: Colors.grey,
                      endIndent: 16,
                      indent: 16,
                    ),
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
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
}
//Imagination makes the world a better place
