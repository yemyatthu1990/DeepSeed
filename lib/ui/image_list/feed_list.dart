import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/bloc/PhotoBloc.dart';
import 'package:deep_seed/bloc/feed_list_bloc.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:deep_seed/ui/image_detail/image_editor.dart';
import 'package:deep_seed/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  _FeedListScreenState();
  FeedListBloc _bloc;
  List<Feed> feedList = new List<Feed>();
  Status status;
  String message;
  @override
  void initState() {
    super.initState();
    _bloc = FeedListBloc();
    _bloc.feedListStream.listen((event) {
      setState(() {
        status = event.status;
        if (status == Status.COMPLETED) {
          feedList.addAll(event.data);
        } else if (status == Status.LOADING || status == Status.ERROR) {
          message = event.message;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        body: CustomScrollView(
          controller: _buildScrollController(),
          slivers: <Widget>[
            new SliverList(
                delegate: new SliverChildBuilderDelegate(
                    (BuildContext buildContext, int index) {
              double imageHeight;
              Feed feed = feedList[index];
              Map<String, int> rgb = Utils.randomColor(feed.userId);
              if (feed.imageRatio == ImageRatio.Facebook.name) {
                imageHeight = MediaQuery.of(context).size.width *
                    ImageRatio.Facebook.ratio;
              } else {
                imageHeight = (MediaQuery.of(context).size.width - 48) *
                    ImageRatio.Instagram.ratio;
              }
              return Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: Theme.of(context).backgroundColor)),
                  child: Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.white,
                      child: Column(
                        children: [
                          Container(
                              margin: EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: <Widget>[
                                  CircleAvatar(
                                      child:
                                          Text(feed.userId[1] + feed.userId[2]),
                                      backgroundColor: Color.fromRGBO(
                                          rgb["r"], rgb["g"], rgb["b"], 1)),
                                  Padding(
                                      padding: EdgeInsets.only(left: 16),
                                      child: Text(
                                          Utils.readTimestamp(feed.timeStamp),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              fontSize: 12)))
                                ],
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: imageHeight,
                              child: InkWell(
                                  onTap: () {},
                                  child: CachedNetworkImage(
                                    imageUrl: feed.downloadUrl,
                                    cacheManager: ImageCacheManager(),
                                    fit: BoxFit.cover,
                                  ))),
                          Padding(
                              padding:
                                  EdgeInsets.only(left: 16, right: 16, top: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  FlatButton(
                                      onPressed: () {},
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(Icons.flag,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .primaryColorDark),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              "Report",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
                                            ),
                                          ])),
                                  FlatButton(
                                      onPressed: () {},
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(Icons.share,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .primaryColorDark),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              "Share",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColorDark),
                                            ),
                                          ])),
                                ],
                              ))
                        ],
                      )));
            }, childCount: feedList.length)),
            new SliverToBoxAdapter(
              child: new Footer(),
            )
          ],
        ));
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
}

class Error extends StatelessWidget {
  final String errorMessage;

  final Function onRetryPressed;

  const Error({Key key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.lightGreen,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.lightGreen,
            child: Text('Retry', style: TextStyle(color: Colors.white)),
            onPressed: onRetryPressed,
          )
        ],
      ),
    );
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.lightGreen,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
          ),
        ],
      ),
    );
  }
}
