import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/ui/favorite/favorite_list.dart';
import 'package:deep_seed/ui/image_list/feed_list.dart';
import 'package:deep_seed/ui/image_list/image_list.dart';
import 'package:deep_seed/ui/profile/profile_list.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/Analytics.dart';
import 'package:deep_seed/view/search/search_bar_controller.dart';
import 'package:deep_seed/view/search/search_bar_style.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  final List<Widget> _children = [
    PhotoListScreen(key: PageStorageKey("PhotoList"), query: ""),
    FeedListScreen(key: PageStorageKey("FeedList")),
    FavoriteListScreen(key: PageStorageKey("Favorite")),
    ProfileListScreen(key: PageStorageKey("Profile"))
  ];

  @override
  _BottomBarState createState() => _BottomBarState(children: _children);
}

class _BottomBarState extends State<BottomBarScreen> {
  int currentIndex;
  String query = "";
  final PageStorageBucket bucket = PageStorageBucket();
  final List<Widget> children;
  _BottomBarState({this.children});
  @override
  void initState() {
    super.initState();
    Analytics().logAppOpen();
    currentIndex = 0;
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildCompleteList();
  }

  Widget _buildFloatingActionButton() {

    return FloatingActionButton(
      onPressed: () => _showModalSheet(),

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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            ImagePicker.pickImage(source: ImageSource.camera)
                                .then((value) {
                              if (value == null) return;
                              Map<String, dynamic> data = {
                                "file_url": value.path,
                                "hero_tag": heroFavoriteTag + "_temp"
                              };
                              Navigator.pushNamed(context, detailRoute,
                                  arguments: data);
                            });
                          },
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: new BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: new Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Camera")
                          ])),
                      InkWell(
                          onTap: () {
                            ImagePicker.pickImage(source: ImageSource.gallery)
                                .then((value) {
                              if (value == null) return;
                              Map<String, dynamic> data = {
                                "file_url": value.path,
                                "hero_tag": heroFavoriteTag + "_temp"
                              };
                              Navigator.pushNamed(context, detailRoute,
                                  arguments: data);
                            });
                          },
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: new BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: new Icon(
                                Icons.photo_album,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Gallery")
                          ]))
                    ],
                  )),
            ),
          );
        });
  }

  Widget _buildAppbarTitle(int index) {
    if (index == 0) {
      return Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: SearchBar(
              onSearchQueryChanged: (query) {
                // Only first tab has search screen
                if (currentIndex == 0) {
                  setState(() {
                    (children[0] as PhotoListScreen).setQuery(query);
                  });
                }
              },
              onSuggestionShow: (show) {},
              icon: Icon(Icons.search),
              hintText: "Love, hate, relationship ...",
              hintStyle: TextStyle(fontSize: 16),
              textStyle: TextStyle(fontSize: 16),
              cancellationWidget: Icon(
                Icons.close,
                color: Colors.grey,
              ),
              searchBarStyle: SearchBarStyle(
                  backgroundColor: Theme.of(context).backgroundColor,
                  borderRadius: BorderRadius.circular(8)),
              searchBarPadding: EdgeInsets.only(left: 0, right: 0)));
    } else {
      switch (index) {
        case 1:
          return Text("Feed");
        case 2:
          return Text("Favorite");
        case 3:
          return Text("Profile");
      }
    }
  }

  Widget _buildBody(int index) {
    return IndexedStack(index: index, children: children);
  }

  Widget _buildCompleteList() {
    return _buildBackground();
  }

  Widget _buildBackground() {
    return Scaffold(
      appBar: (currentIndex == 0)
          ? AppBar(
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              title: _buildAppbarTitle(currentIndex))
          : null,
      body: _buildBody(currentIndex),
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
                Icons.home,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.home,
                color: Colors.red,
              ),
              title: Text("Home")),
          BubbleBottomBarItem(
              backgroundColor: Colors.deepPurple,
              icon: Icon(
                Icons.rss_feed,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.rss_feed,
                color: Colors.deepPurple,
              ),
              title: Text("Feed")),
          BubbleBottomBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(
                Icons.favorite,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.favorite,
                color: Colors.indigo,
              ),
              title: Text("Favorite")),
          BubbleBottomBarItem(
              backgroundColor: Colors.green,
              icon: Icon(
                Icons.person,
                color: Colors.black,
              ),
              activeIcon: Icon(
                Icons.person,
                color: Colors.green,
              ),
              title: Text("Profile"))
        ],
      ),
    );
  }
}
