import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/bloc/PhotoBloc.dart';
import 'package:deep_seed/bloc/favorite_list_bloc.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart'
    as prefresh;

class FavoriteListScreen extends StatefulWidget {
  _FavoriteListScreenState _favoriteListScreenState;
  final Key key;
  void refresh() {
    _favoriteListScreenState.refresh();
  }

  FavoriteListScreen({this.key}) : super(key: key);

  @override
  _FavoriteListScreenState createState() {
    _favoriteListScreenState = _FavoriteListScreenState();
    return _favoriteListScreenState;
  }
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  _FavoriteListScreenState();
  FavoriteListBloc _bloc;
  bool showLoading = false;
  bool showError = false;
  List<Urls> favoriteList = new List<Urls>();
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
    }
    _refreshIndicatorKey.currentState.show(notificationDragOffset: 40);
  }

  @override
  void initState() {
    super.initState();
    _bloc = FavoriteListBloc();
    _bloc.favoriteListStream.listen((event) {
      setState(() {
        status = event.status;
        if (status == Status.COMPLETED) {
          showLoading = false;
          showError = false;
          if (event.data == null || event.data.length == 0) {
            showError = true;
            message = "Add to favorites.";
          } else {
            favoriteList = event.data;
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
    _bloc.fetchFavoriteList();
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
                  _bloc.fetchFavoriteList();
                })
            : showLoading
                ? Loading(
                    key: GlobalKey(debugLabel: "Loading"),
                    loadingMessage: message,
                  )
                : prefresh.PullToRefreshNotification(
                    color: Colors.blue,
                    onRefresh: () {
                      return _bloc.fetchFavoriteList();
                    },
                    maxDragOffset: 40,
                    armedDragUpCancel: false,
                    key: _refreshIndicatorKey,
                    child: new CustomScrollView(
                      slivers: <Widget>[
                        SliverAppBar(
                          backgroundColor:
                              Theme.of(context).dialogBackgroundColor,
                          floating: false,
                          pinned: true,
                          centerTitle: false,
                          expandedHeight: 100.0,
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text(
                              "Favorite",
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
                                    tag: heroFavoriteTag + index.toString(),
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: () {
                                              Map<String, dynamic> data = {
                                                "urls": favoriteList[index],
                                                "index": index,
                                                "temp_file_url":
                                                    ImageCacheManager()
                                                        .getFileFromMemory(
                                                            favoriteList[index]
                                                                .small)
                                                        .file
                                                        .path,
                                                "hero_tag": heroFavoriteTag +
                                                    index.toString()
                                              };
                                              Navigator.pushNamed(
                                                  context, detailRoute,
                                                  arguments: data);
                                            },
                                            child: CachedNetworkImage(
                                              useOldImageOnUrlChange: true,
                                              imageUrl:
                                                  favoriteList[index].small,
                                              cacheManager: ImageCacheManager(),
                                              fit: BoxFit.cover,
                                            )))),
                              );
                            }, childCount: favoriteList.length),
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
    return Stack(
      children: <Widget>[
        Container(
          height: 112,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                "Favorite",
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
                )))
      ],
    );
  }
}

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: new CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black)));
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
                "Favorite",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              )),
        ),
        Text(
          loadingMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        SizedBox(height: 24),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      ],
    );
  }
}
