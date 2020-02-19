import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/bloc/PhotoBloc.dart';
import 'package:deep_seed/bloc/favorite_list_bloc.dart';
import 'package:deep_seed/bloc/profile_block.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart'
    as prefresh;

class ProfileListScreen extends StatefulWidget {
  final Key key;
  _ProfileListScreenState _profileListScreenState;
  ProfileListScreen({this.key}) : super(key: key);

  void refresh() {
    _profileListScreenState.refresh();
  }

  @override
  _ProfileListScreenState createState() {
    _profileListScreenState = _ProfileListScreenState();
    return _profileListScreenState;
  }
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  _ProfileListScreenState();
  ProfileBloc _bloc;
  bool showError = false;
  bool showLoading = false;
  List<Feed> profileList = new List<Feed>();
  Status status;
  String message;
  final GlobalKey<prefresh.PullToRefreshNotificationState>
      _refreshIndicatorKey =
      new GlobalKey<prefresh.PullToRefreshNotificationState>();
  void refresh() {
    if (showError == true) {
      setState(() {
        showError = false;
        showLoading = false;
      });
      Future.delayed(Duration(seconds: 2), () {
        _refreshIndicatorKey.currentState.show(notificationDragOffset: 40);
      });
    } else {
      _refreshIndicatorKey.currentState.show(notificationDragOffset: 40);
    }
  }

  @override
  void initState() {
    super.initState();
    _bloc = ProfileBloc();
    _bloc.profileStream.listen((event) {
      setState(() {
        status = event.status;
        if (status == Status.COMPLETED) {
          showLoading = false;
          showError = false;
          if (event.data == null || event.data.length == 0) {
            showError = true;
            message = "Share DeepSeed to showcase here.";
          } else {
            profileList = event.data;
          }
        } else if (status == Status.LOADING) {
          showLoading = true;
          showError = false;
          message = event.message;
        } else if (status == Status.ERROR) {
          showLoading = false;
          showError = true;
          message = event.message;
        }
      });
    });
    _bloc.fetchMyImages();
  }

  /* Widget _buildPhotoList() {
    if (_pageNo == 1) {
      switch (status) {
        case Status.LOADING:
          return Loading(
            loadingMessage: message,
          );
          break;
        case Status.ERROR:
          return Error(
              errorMessage: message,
              onRetryPressed: () {
                _pageNo = 1;
                return _bloc.fetchPhotoList(1);
              });

          break;
        case Status.COMPLETED:

      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        body: showError
            ? Error(
                key: GlobalKey(),
                errorMessage: message,
                onRetryPressed: () {
                  _bloc.fetchMyImages();
                })
            : showLoading
                ? Loading(
                    key: GlobalKey(debugLabel: "Loading"),
                    loadingMessage: message,
                  )
                : prefresh.PullToRefreshNotification(
                    color: Colors.blue,
                    onRefresh: () {
                      return _bloc.fetchMyImages();
                    },
                    maxDragOffset: 40,
                    armedDragUpCancel: false,
                    key: _refreshIndicatorKey,
                    child: new CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          ///Properties of app bar
                          backgroundColor:
                              Theme.of(context).dialogBackgroundColor,
                          floating: false,
                          pinned: true,
                          centerTitle: false,
                          expandedHeight: 100.0,

                          ///Properties of the App Bar when it is expanded
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text(
                              "My DeepSeed",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            background: Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black26,
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        prefresh.PullToRefreshContainer(
                            buildPulltoRefreshHeader),
                        new SliverGrid(
                            delegate: new SliverChildBuilderDelegate(
                                (BuildContext buildContext, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Hero(
                                    tag: heroProfileTag + index.toString(),
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: () {
                                              Map<String, dynamic> data = {
                                                "file_url": ImageCacheManager()
                                                    .getFileFromMemory(
                                                        profileList[index]
                                                            .downloadUrl)
                                                    .file
                                                    .path,
                                                "hero_tag": heroProfileTag +
                                                    index.toString()
                                              };
                                              Navigator.pushNamed(
                                                  context, profileDetailRoute,
                                                  arguments: data);
                                            },
                                            child: CachedNetworkImage(
                                              useOldImageOnUrlChange: true,
                                              imageUrl: profileList[index]
                                                  .downloadUrl,
                                              cacheManager: ImageCacheManager(),
                                              fit: BoxFit.cover,
                                            )))),
                              );
                            }, childCount: profileList.length),
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2))
                      ],
                    )));
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  Widget buildPulltoRefreshHeader(
      prefresh.PullToRefreshScrollNotificationInfo info) {
    var offset = info?.dragOffset ?? 0.0;
    var mode = info?.mode;
    Widget refreshWiget = Container();
    //it should more than 18, so that RefreshProgressIndicator can be shown fully
    if (info?.refreshWiget != null &&
        offset > 18.0 &&
        mode != prefresh.RefreshIndicatorMode.error) {
      refreshWiget = info.refreshWiget;
    }

    Widget child = null;
    if (mode == prefresh.RefreshIndicatorMode.error) {
      child = GestureDetector(
          onTap: () {
            // refreshNotification;
            info?.pullToRefreshNotificationState?.show();
          },
          child: Container(
            color: Colors.grey,
            alignment: Alignment.bottomCenter,
            height: offset,
            width: double.infinity,
            //padding: EdgeInsets.only(top: offset),
            child: Container(
              padding: EdgeInsets.only(left: 5.0),
              alignment: Alignment.center,
              child: Text(
                mode?.toString() + "  click to retry" ?? "",
                style: TextStyle(fontSize: 12.0, inherit: false),
              ),
            ),
          ));
    } else {
      child = Container(
          color: Theme.of(context).dialogBackgroundColor,
          alignment: Alignment.bottomCenter,
          height: offset,
          width: double.infinity,
          child: refreshWiget);
    }

    return SliverToBoxAdapter(
      child: child,
    );
  }
}

class Error extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        height: 112,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              "My DeepSeed",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            )),
      ),
      Align(
        alignment: Alignment.center,
        child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            )),
      )
    ]);
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: new CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen)));
  }
}

class Loading extends StatelessWidget {
  final String loadingMessage;

  const Loading({Key key, this.loadingMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 112,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "My DeepSeed",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ),
        Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        )
      ],
    );
  }
}
