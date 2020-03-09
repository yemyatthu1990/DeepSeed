import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:deep_seed/bloc/feed_list_bloc.dart';
import 'package:deep_seed/util/Analytics.dart';
import 'package:deep_seed/view/native_admob.dart';
import 'package:flutter/material.dart';
import 'package:deep_seed/model/Feed.dart';

import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:deep_seed/ui/image_detail/image_editor.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart'
    as prefresh;

import '../../main.dart';

class FeedListScreen extends StatefulWidget {
  _FeedListScreenState _feedListScreenState;
  final Key key;
  Timer _debounce;

  FeedListScreen({this.key}) : super(key: key);
  void refresh() {
    _feedListScreenState.refresh();
  }

  @override
  _FeedListScreenState createState() {
    _feedListScreenState = _FeedListScreenState();
    return _feedListScreenState;
  }
}

class _PhotoInfiniteInterface {
  void onScroll() {}
}

class _FeedListScreenState extends State<FeedListScreen>
    implements _PhotoInfiniteInterface {
  bool showFooter = false;
  bool showError = false;
  bool showLoading = false;
  _FeedListScreenState();
  FeedListBloc _bloc;
  List<Feed> feedList = new List();
  Status status;
  String message;
  bool isRefreshing = false;
  var adMobViews = new List<Widget>();
  var adMobCount = 0;
  PopupMenu popupMenu;

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

    _bloc = FeedListBloc();
    _bloc.feedListStream.listen((event) {
      setState(() {
        status = event.status;
        if (status == Status.COMPLETED) {
          showLoading = false;
          showFooter = !(event.data == null || event.data.length == 0);
          if (event.data == null) return;
          if (isRefreshing) {
            isRefreshing = false;

            List<Feed> totalList = new List();
            totalList.addAll(event.data);
            feedList = totalList;
          } else {
            feedList.addAll(event.data);
          }
        } else if (status == Status.LOADING) {
          if (event.show) {
            showLoading = true;
            message = event.message;
          }
        } else if (status == Status.ERROR) {
          if (event.show) {
            showError = true;
            message = event.message;
          }
          showLoading = false;
          showFooter = false;
        }
      });
    });
    _bloc.fetchFeedList();
  }

  ScrollController _buildScrollController() {
    ScrollController _scrollController = new ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll == currentScroll) {
        onScroll();
      }
    });
    return _scrollController;
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
  final GlobalKey<prefresh.PullToRefreshNotificationState>
      _refreshIndicatorKey =
      new GlobalKey<prefresh.PullToRefreshNotificationState>();

  Future<Map<String, dynamic>> _showPopupMenu(RelativeRect rect, Feed feed) async {
    var valueMapOne = new Map<String,dynamic>();
    valueMapOne["index"] = 0;
    valueMapOne["feed"] = feed;
    var valueMapTwo = new Map<String,dynamic>();
    valueMapTwo["index"] = 1;
    valueMapTwo["feed"] = feed;
    var valueMapThree = new Map<String,dynamic>();
    valueMapThree["index"] = 2;
    valueMapThree["feed"] = feed;
    return await showMenu(
      context: context,
      position: rect,
      items: [
        PopupMenuItem(value: valueMapOne, child: Text("Report")),
        PopupMenuItem(value: valueMapTwo, child: Text("Hide this image")),
        PopupMenuItem(value: valueMapThree, child: Text("Block this user"))
      ],
      elevation: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        body: prefresh.PullToRefreshNotification(
            color: Colors.blue,
            onRefresh: () {
              isRefreshing = true;
              return _bloc.fetchFeedList(refresh: true);
            },
            maxDragOffset: 40,
            armedDragUpCancel: false,
            key: _refreshIndicatorKey,
            child: CustomScrollView(
                physics: prefresh.AlwaysScrollableClampingScrollPhysics(),
                controller: _buildScrollController(),
                slivers: <Widget>[
                  SliverAppBar(

                      ///Properties of app bar
                      backgroundColor: Theme.of(context).dialogBackgroundColor,
                      floating: false,
                      pinned: true,
                      centerTitle: false,
                      expandedHeight: 100.0,

                      ///Properties of the App Bar when it is expanded
                      flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Text(
                            "Feed",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ))),
                  prefresh.PullToRefreshContainer(buildPulltoRefreshHeader),
                  showError
                      ? SliverToBoxAdapter(
                          child: Error(
                              key: GlobalKey(),
                              errorMessage: message,
                              onRetryPressed: () {
                                _bloc.fetchFeedList();
                              }))
                      : showLoading
                          ? SliverToBoxAdapter(
                              child: Loading(
                              key: GlobalKey(debugLabel: "Loading"),
                              loadingMessage: message,
                            ))
                          : new SliverList(
                              delegate: new SliverChildBuilderDelegate(
                                  (BuildContext buildContext, int index) {
                              double imageHeight;
                              Feed feed = feedList[index];
                              Map<String, int> rgb =
                                  Utils.randomColor(feed.userId);

                              if (feed.imageRatio == ImageRatio.Facebook.name) {
                                imageHeight =
                                    (MediaQuery.of(context).size.width - 32) *
                                        ImageRatio.Facebook.ratio;
                              } else {
                                imageHeight =
                                    (MediaQuery.of(context).size.width - 32) *
                                        ImageRatio.Instagram.ratio;
                              }
                              Color avatarBgColor = Color.fromRGBO(
                                  rgb["r"], rgb["g"], rgb["b"], 1);
                              return Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .backgroundColor)),
                                  child: Container(
                                      padding: EdgeInsets.all(8),
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 8),
                                              child: Row(
                                                children: <Widget>[
                                                  CircleAvatar(
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8,
                                                                  right: 8,
                                                                  top: 8),
                                                          child: Image.asset(
                                                            "graphics/deepseed_alpha.png",
                                                            color: Colors.white,
                                                          )),
                                                      backgroundColor:
                                                          avatarBgColor),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 16),
                                                      child: Text(
                                                          Utils.readTimestamp(
                                                              feed.timeStamp),
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              fontSize: 12))),
                                                  Expanded(child: Container()),
                                                  InkWell(
                                                      onTapDown: (detail) {
                                                        Future<dynamic>
                                                            awaitFeed =
                                                            _showPopupMenu(
                                                                RelativeRect.fromLTRB(
                                                                    detail
                                                                        .globalPosition
                                                                        .dx,
                                                                    detail
                                                                        .globalPosition
                                                                        .dy,
                                                                    0,
                                                                    0),
                                                                feed);
                                                        awaitFeed.then((value) {
                                                          var valueMap = value as Map<String, dynamic>;
                                                          if(valueMap == null) return;
                                                          if (valueMap["index"] == 0) {
                                                            String downloadUrl =
                                                                (valueMap["feed"] as Feed)
                                                                    .downloadUrl;
                                                            DialogUtils
                                                                    .showReportDialog(
                                                                        context, "Are you sure you want to report this?",
                                                            "Photos that have nudity, violence, animal abuse, and harrasment should be reported.",
                                                            "Report")
                                                                .then((value) {
                                                              if (value) {

                                                              }
                                                            });
                                                          }
                                                           else if (valueMap["index"] == 1) {
                                                            String downloadUrl =
                                                                (valueMap["feed"] as Feed)
                                                                    .downloadUrl;
                                                            DialogUtils
                                                                    .showReportDialog(
                                                                        context,
                                                                "Are you sure you want to hide this?",
                                                                "Photo hidden by you will not show up on Feed. This action can not be undone.",
                                                            "Hide")
                                                                .then((value) {
                                                              if (value) {
                                                                _bloc.report(
                                                                    downloadUrl,
                                                                    () {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Report successful. Thank you for being a responsible person.");
                                                                });
                                                              }
                                                            });
                                                          }    else if (valueMap["index"] == 2) {
                                                            String downloadUrl =
                                                                (valueMap["feed"] as Feed)
                                                                    .downloadUrl;
                                                            DialogUtils
                                                                    .showReportDialog(
                                                                        context,
                                                                "Are you sure you want to block this user?",
                                                                "If you block a user, all of that user's photos will not show up on Feed. This action can not be undone",
                                                            "Block")
                                                                .then((value) {
                                                              if (value) {
                                                                _bloc.report(
                                                                    downloadUrl,
                                                                    () {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Report successful. Thank you for being a responsible person.");
                                                                });
                                                              }
                                                            });
                                                          }
                                                        });
                                                      },
                                                      onTap: () {
                                                        log("Tap");
                                                      },
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          child: Icon(
                                                            Icons.more_vert,
                                                            size: 20,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark,
                                                          )))
                                                ],
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: imageHeight,
                                              child: InkWell(
                                                  onTap: () {},
                                                  child: CachedNetworkImage(
                                                    imageUrl: feed.downloadUrl,
                                                    cacheManager:
                                                        ImageCacheManager(),
                                                    fit: BoxFit.cover,
                                                  ))),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  left: 16, right: 16, top: 8),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  FlatButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          feed.clapCount = feed
                                                                      .clapCount ==
                                                                  null
                                                              ? 0
                                                              : feed.clapCount +
                                                                  1;
                                                        });

                                                        if (widget._debounce
                                                                ?.isActive ??
                                                            false) {
                                                          widget._debounce
                                                              ?.cancel();
                                                        }
                                                        widget._debounce =
                                                            Timer(
                                                                Duration(
                                                                    seconds: 3),
                                                                () {
                                                          _bloc.upvoteImage(
                                                              feed.downloadUrl,
                                                              () => {},
                                                              feed.clapCount);
                                                        });
                                                      }, //
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            SvgPicture.asset(
                                                              "graphics/clap.svg",
                                                              width: 20,
                                                              height: 20,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                            ),
                                                            if ((feed.clapCount ==
                                                                        null
                                                                    ? 0
                                                                    : feed
                                                                        .clapCount) >
                                                                0)
                                                              Text(
                                                                feed.clapCount
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColorDark),
                                                              ),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                              "Clap",
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark),
                                                            ),
                                                          ])),
                                                  FlatButton(
                                                      onPressed: () {
                                                        ImageCacheManager()
                                                            .getFileFromMemory(
                                                                feed
                                                                    .downloadUrl)
                                                            .file
                                                            .readAsBytes()
                                                            .then(
                                                                (value) async {
                                                          String fileName = Timestamp
                                                                      .now()
                                                                  .millisecondsSinceEpoch
                                                                  .toString() +
                                                              ".jpg";
                                                          final tempDir =
                                                              await getTemporaryDirectory();
                                                          final file =
                                                              await new File(
                                                                      '${tempDir.path}/$fileName')
                                                                  .create();
                                                          file.writeAsBytesSync(
                                                              value);
                                                          return fileName;
                                                        }).then((fileName) {
                                                          Analytics()
                                                              .logShareFeed();
                                                          Utils.shareImage(
                                                              fileName, "");
                                                        });
                                                      },
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            Icon(Icons.share,
                                                                size: 20,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColorDark),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                              "Share",
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColorDark),
                                                            ),
                                                          ])),
                                                ],
                                              ))
                                        ],
                                      )));
                            }, childCount: feedList.length)),
                  new SliverToBoxAdapter(
                    child: showFooter ? new Footer() : Container(),
                  )
                ])));
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  void onScroll() {
    _bloc.fetchFeedList();
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
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 2 - 60,
                        left: 40,
                        right: 40),
                    child: Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    )))
          ],
        ));
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
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 2 - 60),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ))),
          ],
        ));
  }
}
