import 'dart:io' as io;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/bloc/PhotoBloc.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';

import '../../main.dart';

typedef OnRefreshValueChanged(bool value, bool goToFeed);

class PhotoListScreen extends StatefulWidget {
  String query;
  _PhotoListScreenState _photoListScreenState;
  final Key key;
  final OnRefreshValueChanged onRefreshValueChanged;

  bool initializationFinished = false;
  void setQuery(String query) {
    this.query = query;
    _photoListScreenState.setQuery(this.query);
  }

  PhotoListScreen({this.key, this.query, this.onRefreshValueChanged})
      : super(key: key);

  @override
  _PhotoListScreenState createState() {
    _photoListScreenState = _PhotoListScreenState(query: this.query);
    return _photoListScreenState;
  }
}

class _PhotoInfiniteInterface {
  void onScroll() {}
}

class _PhotoListScreenState extends State<PhotoListScreen>
    implements _PhotoInfiniteInterface {
  String query;
  bool showFooter = false;
  bool showError = false;
  bool showLoading = false;
  void setQuery(String query, {bool showLoading = true}) {
    this.query = query;
    if (this.query.length == 0 &&
        RemoteConfigKey.queries != null &&
        RemoteConfigKey.queries.length > 0) {
      this.query = RemoteConfigKey
              .queries[Random().nextInt(RemoteConfigKey.queries.length - 1)]
          as String;
    }
    this._pageNo = 1;
    _bloc.fetchPhotoList(this._pageNo, this.query, showLoading: showLoading);
  }

  _PhotoListScreenState({this.query});
  PhotoBloc _bloc;
  int _pageNo = 1;
  List<dynamic> photoList = new List<dynamic>();
  Status status;
  String message;
  List<Widget> filterList = new List();
  var selectedIndex = -1;
  var admobList = List<NativeAdmob>();
  var admobIndex = -1;
  var relatedIndex = -1;
  @override
  void initState() {
    super.initState();
    var adUnitId = "ca-app-pub-7811418762973637/4266376782";
    if (io.Platform.isAndroid) {
      adUnitId = "ca-app-pub-7811418762973637/4266376782";
    } else if (io.Platform.isIOS) {
      adUnitId = "ca-app-pub-7811418762973637/9055475516";
    }
    if (widget.initializationFinished == false) {
      setState(() {
        showLoading = true;
        message = "";
      });

      initializeRemoteConfig().then((value) {
        _bloc = PhotoBloc();
        if (RemoteConfigKey.queries != null &&
            RemoteConfigKey.queries.length > 0) {
          if (this.query.length == 0) {
            query = RemoteConfigKey.queries[
                Random().nextInt(RemoteConfigKey.queries.length - 1)] as String;
          }
        }
        _bloc.photoListStream.listen((event) {
          status = event.status;
          if (status == Status.COMPLETED) {
            showLoading = false;
            showError = false;
            showFooter = !(event.data == null || event.data.length == 0);

            if (_pageNo == 1) {
              photoList.clear();
            }
            if (event.data == null) return;
            setState(() {
              photoList.addAll(event.data);
            });
            var admobController = NativeAdmobController();

            admobController.setAdUnitID(adUnitId);
            var admob = NativeAdmob(
              adUnitID: adUnitId,
              controller: admobController,
            );
            admobIndex = admobIndex + 1;
            photoList.insert(photoList.length - 5, admobIndex);
            admobList.add(admob);
          } else if (status == Status.LOADING) {
            if (event.show) {
              setState(() {
                showLoading = true;
                message = event.message;
              });
            }
          } else if (status == Status.ERROR) {
            showLoading = false;
            showFooter = false;
            if (event.show) {
              setState(() {
                showError = true;
                message = event.message;
              });
            }
          }
        });

        _bloc.fetchPhotoList(_pageNo, query);
        widget.initializationFinished = true;
      });
    } else {
      _bloc = PhotoBloc();
      _bloc.photoListStream.listen((event) {
        status = event.status;
        if (status == Status.COMPLETED) {
          showLoading = false;
          showError = false;
          showFooter = !(event.data == null || event.data.length == 0);

          if (_pageNo == 1) {
            photoList.clear();
          }
          if (event.data == null) return;
          setState(() {
            photoList.addAll(event.data);
          });
        } else if (status == Status.LOADING) {
          if (event.show) {
            setState(() {
              showLoading = true;
              message = event.message;
            });
          }
        } else if (status == Status.ERROR) {
          showLoading = false;
          showFooter = false;
          if (event.show) {
            setState(() {
              showError = true;
              message = event.message;
            });
          }
        }
      });
      _bloc.fetchPhotoList(_pageNo, query);
    }
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

  @override
  Widget build(BuildContext context) {
    filterList.clear();
    if (RemoteConfigKey.queries != null &&
        RemoteConfigKey.queries.length > 0 &&
        RemoteConfigKey.queries.contains(this.query)) {
      RemoteConfigKey.queries.asMap().forEach((index, query) {
        if (this.query == query) selectedIndex = index;
        var filterChip = Padding(
            padding: EdgeInsets.only(left: 4, right: 4),
            child: ChoiceChip(
                label: Padding(
                    padding: EdgeInsets.only(left: 4, right: 4),
                    child: Text(
                      query,
                      style: TextStyle(
                          color: selectedIndex == index
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 12),
                    )),
                selected: selectedIndex == index,
                selectedColor: Colors.orange,
                onSelected: (value) {
                  setState(() {
                    if (value) selectedIndex = index;
                  });
                  setQuery(query, showLoading: false);
                }));
        filterList.add(filterChip);
      });
    }
    return Scaffold(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        body: showError
            ? Error(
                key: GlobalKey(),
                errorMessage: message,
                onRetryPressed: () {
                  _pageNo = 1;
                  _bloc.fetchPhotoList(_pageNo, query);
                })
            : showLoading
                ? Loading(
                    key: GlobalKey(debugLabel: "Loading"),
                    loadingMessage: message,
                  )
                : CustomScrollView(
                    controller: _buildScrollController(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Wrap(children: filterList)),
                      ),
                      new SliverGrid(
                          delegate: new SliverChildBuilderDelegate(
                              (BuildContext buildContext, int index) {
                            if (photoList[index] is int) {
                              return Container(
                                  child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: admobList[photoList[index]]));
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Hero(
                                    tag: heroPhotoTag + index.toString(),
                                    child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: () {
                                              _bloc.sendDownoadEvent(
                                                  photoList[index]
                                                      .links
                                                      .downloadLocation);
                                              Map<String, dynamic> data = {
                                                "urls": photoList[index].urls,
                                                "photographer_name":
                                                    photoList[index].user.name,
                                                "username": photoList[index]
                                                    .user
                                                    .username,
                                                "index": index,
                                                "temp_file_url":
                                                    ImageCacheManager()
                                                        .getFileFromMemory(
                                                            photoList[index]
                                                                .urls
                                                                .small)
                                                        .file
                                                        .path,
                                                "hero_tag": heroPhotoTag +
                                                    index.toString()
                                              };
                                              Navigator.pushNamed(
                                                      context, detailRoute,
                                                      arguments: data)
                                                  .then((value) {
                                                if (value != null) {
                                                  widget.onRefreshValueChanged(
                                                      true, value == 1);
                                                }
                                              });
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  photoList[index].urls.small,
                                              cacheManager: ImageCacheManager(),
                                              fit: BoxFit.cover,
                                            )))),
                              );
                            }
                          }, childCount: photoList.length),
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2)),
                      new SliverToBoxAdapter(
                        child: showFooter ? new Footer() : Container(),
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
    int _actualPageNo = photoList.length ~/ 10 + 1;

    if (_pageNo == _actualPageNo) return;
    _pageNo = _actualPageNo;
    _bloc.fetchPhotoList(_pageNo, query);
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
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.black,
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
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black)));
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
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ],
      ),
    );
  }
}
