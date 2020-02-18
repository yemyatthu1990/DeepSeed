import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:deep_seed/bloc/feed_list_bloc.dart';
import 'package:deep_seed/view/native_admob.dart';
import 'package:flutter/material.dart';
import 'package:deep_seed/model/Feed.dart';

import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:deep_seed/ui/image_detail/image_editor.dart';
import 'package:deep_seed/ui/util/dialog_utils.dart';
import 'package:deep_seed/util/utils.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart'
    as prefresh;

class FeedListScreen extends StatefulWidget {
  _FeedListScreenState _feedListScreenState;
  final Key key;
  FeedListScreen({this.key}) : super(key: key);

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
  List<dynamic> feedList = new List();
  Status status;
  String message;
  bool isRefreshing = false;
  var adMobViews = new List<Widget>();
  var adMobCount = 0;
final  Widget adMobView =  NativeAdmobBannerView(
        //   adUnitID: "ca-app-pub-7811418762973637/4266376782",
        adUnitID: "ca-app-pub-3940256099942544/2247696110",
        // enum dark or light
        showMedia: false,
        // whether to show media view or not
        contentPadding: const EdgeInsets.all(10),
        // content padding
      );

  /* Future.delayed(Duration(milliseconds: 500),(){
     setState(() {
       adMobView = adMob;
     });
   });*/

  @override
  void initState() {
    super.initState();
    adMobViews.clear();





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
            var totalList = new List<dynamic>();
            adMobCount = 1;
            totalList.addAll(event.data);
            feedList = totalList;
          } else {
            feedList.addAll(event.data);
            /*if (adMobCount < adMobViews.length) {
              adMobCount = adMobCount + 1;

            }*/
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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        body: showError
            ? Error(
                key: GlobalKey(),
                errorMessage: message,
                onRetryPressed: () {
                  _bloc.fetchFeedList();
                })
            : showLoading
                ? Loading(
                    key: GlobalKey(debugLabel: "Loading"),
                    loadingMessage: message,
                  )
                : prefresh.PullToRefreshNotification(
                    color: Colors.blue,
                    onRefresh: () {
                      isRefreshing = true;
                      return _bloc.fetchFeedList(refresh: true);
                    },
                    maxDragOffset: 40,
                    armedDragUpCancel: false,
                    key: GlobalKey(),
                    child: CustomScrollView(
                        physics:
                            prefresh.AlwaysScrollableClampingScrollPhysics(),
                        controller: _buildScrollController(),
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
                                    "Feed",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ))),
                          prefresh.PullToRefreshContainer(
                              buildPulltoRefreshHeader),
                          new SliverList(
                              delegate: new SliverChildBuilderDelegate(
                                  (BuildContext buildContext, int index) {

                            dynamic item = feedList[index];

                              double imageHeight;
                              Feed feed = item;
                              Map<String, int> rgb =
                              Utils.randomColor(feed.userId);
                              if (feed.imageRatio == ImageRatio.Facebook.name) {
                                imageHeight = MediaQuery
                                    .of(context)
                                    .size
                                    .width *
                                    ImageRatio.Facebook.ratio;
                              } else {
                                imageHeight =
                                    (MediaQuery
                                        .of(context)
                                        .size
                                        .width - 48) *
                                        ImageRatio.Instagram.ratio;
                              }
                              return Container(
                                  margin: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 8),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                          Theme
                                              .of(context)
                                              .backgroundColor)),
                                  child: Container(
                                      padding: EdgeInsets.all(8),
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(
                                                  bottom: 8),
                                              child: Row(
                                                children: <Widget>[
                                                  CircleAvatar(
                                                      child: Text(
                                                          feed.userId[1] +
                                                              feed.userId[2]),
                                                      backgroundColor:
                                                      Color.fromRGBO(
                                                          rgb["r"],
                                                          rgb["g"],
                                                          rgb["b"],
                                                          1)),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 16),
                                                      child: Text(
                                                          Utils.readTimestamp(
                                                              feed
                                                                  .timeStamp),
                                                          style: TextStyle(
                                                              color: Theme
                                                                  .of(
                                                                  context)
                                                                  .primaryColorDark,
                                                              fontSize: 12)))
                                                ],
                                              )),
                                          Container(
                                              width: MediaQuery
                                                  .of(context)
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
                                                        DialogUtils
                                                            .showReportDialog(
                                                            context)
                                                            .then((report) {
                                                          if (report == null ||
                                                              report == false) {
                                                            return;
                                                          } else {
                                                            _bloc.report(
                                                                feed
                                                                    .downloadUrl,
                                                                    () {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                      msg:
                                                                      "Sucessfuly reported.");
                                                                });
                                                          }
                                                        });
                                                      }, //
                                                      child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                          mainAxisSize:
                                                          MainAxisSize.max,
                                                          children: [
                                                            Icon(Icons.flag,
                                                                size: 20,
                                                                color: Theme
                                                                    .of(
                                                                    context)
                                                                    .primaryColorDark),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                              "Report",
                                                              style: TextStyle(
                                                                  color: Theme
                                                                      .of(
                                                                      context)
                                                                      .primaryColorDark),
                                                            ),
                                                          ])),
                                                  FlatButton(
                                                      onPressed: () {
                                                        ImageCacheManager()
                                                            .getFileFromMemory(
                                                            feed.downloadUrl)
                                                            .file
                                                            .readAsBytes()
                                                            .then((
                                                            value) async {
                                                          String fileName = Timestamp
                                                              .now()
                                                              .millisecondsSinceEpoch
                                                              .toString() +
                                                              ".jpg";
                                                          final tempDir =
                                                          await getTemporaryDirectory();
                                                          final file = await new File(
                                                              '${tempDir
                                                                  .path}/$fileName')
                                                              .create();
                                                          file.writeAsBytes(
                                                              value);
                                                          return fileName;
                                                        }).then((fileName) =>
                                                            Utils.shareImage(
                                                                fileName));
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
                                                                color: Theme
                                                                    .of(
                                                                    context)
                                                                    .primaryColorDark),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                              "Share",
                                                              style: TextStyle(
                                                                  color: Theme
                                                                      .of(
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
                            child: Container(
                                  margin: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 8),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                          Theme
                                              .of(context)
                                              .backgroundColor)), child: adMobView!=null? adMobView: Container())
                          ),
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
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
        RaisedButton(
          color: Colors.black,
          child: Text('Reload', style: TextStyle(color: Colors.white)),
          onPressed: onRetryPressed,
        )
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
                "Feed",
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
