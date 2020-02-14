import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/ui/image_list/image_list.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/Analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';

class BottomBarScreen extends StatefulWidget {
  BottomBarScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBarScreen> {
  int currentIndex;
  final List<Widget> _children = [
    PhotoListScreen(),
    PhotoListScreen(),
    PhotoListScreen(),
  ];
  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    Analytics().logAppOpen();
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        title: Text("Deep Seed"),
      ),
      body: _children[0],
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        hasNotch: true,
        fabLocation: BubbleBottomBarFabLocation.end,
        opacity: .2,
        currentIndex: currentIndex,
        onTap: changePage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        //border radius doesn't work when the notch is enabled.
        elevation: 8,
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
              backgroundColor: Colors.red,
              icon: Icon(
                Icons.dashboard,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.dashboard,
                color: Colors.red,
              ),
              title: Text("Home")),
          BubbleBottomBarItem(
              backgroundColor: Colors.deepPurple,
              icon: Icon(
                Icons.access_time,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.access_time,
                color: Colors.deepPurple,
              ),
              title: Text("Logs")),
          BubbleBottomBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(
                Icons.folder_open,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.folder_open,
                color: Colors.indigo,
              ),
              title: Text("Folders")),
          BubbleBottomBarItem(
              backgroundColor: Colors.green,
              icon: Icon(
                Icons.menu,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.menu,
                color: Colors.green,
              ),
              title: Text("Menu"))
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showModalSheet,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.add,
        color: Colors.black,
      ),
    );
  }

  void _showModalSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return Container(
            padding: EdgeInsets.all(32.0),
            color: Colors.transparent,
            child: Card(
              child: Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            ImagePicker.pickImage(source: ImageSource.camera)
                                .then((value){
                                  Map<String, dynamic> data = {
                                "file_url": value.path
                              };
                                  Navigator.pushNamed(context, detailRoute,
                                      arguments: data);
                            });
                          },
                          child: Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.camera,
                                      size: 56,
                                      color: Colors.red,
                                    ),
                                    Text("Camera")
                                  ]))),
                      InkWell(
                          onTap: () {
                            ImagePicker.pickImage(source: ImageSource.gallery)
                                .then((value) {
                              Map<String, dynamic> data = {
                                "file_url": value.path
                              };
                                  Navigator.pushNamed(context, detailRoute,
                                      arguments: data);
                            }
                            );
                          },
                          child: Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                         Container(
                                          width: 56,
                                          height: 56,
                                          decoration: new BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                          child: new Icon(
                                            Icons.photo_album,
                                            color: Colors.white,
                                          ),
                                        ),
                                    Text("Gallery")
                                  ])))
                    ],
                  )),
            ),
          );
        });
  }
}
