import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/bloc/PhotoBloc.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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
  void setQuery(String query) {
    this.query = query;
    this._pageNo = 1;
    _bloc.fetchPhotoList(this._pageNo, this.query);
  }

  _PhotoListScreenState({this.query});
  PhotoBloc _bloc;
  int _pageNo = 1;
  List<Photo> photoList = new List<Photo>();
  Status status;
  String message;
  @override
  void initState() {
    super.initState();

    if (widget.initializationFinished == false) {
      setState(() {
        showLoading = true;
        message = "";
      });

      initializeRemoteConfig().then((value) {
        _bloc = PhotoBloc();
        _bloc.photoListStream.listen((event) {
          setState(() {
            status = event.status;
            if (status == Status.COMPLETED) {
              showLoading = false;
              showError = false;
              showFooter = !(event.data == null || event.data.length == 0);

              if (_pageNo == 1) {
                photoList.clear();
              }
              if (event.data == null) return;
              photoList.addAll(event.data);
            } else if (status == Status.LOADING) {
              if (event.show) {
                showLoading = true;
                message = event.message;
              }
            } else if (status == Status.ERROR) {
              showLoading = false;
              showFooter = false;
              if (event.show) {
                showError = true;
                message = event.message;
              }
            }
          });
        });
        _bloc.fetchPhotoList(_pageNo, query);
        widget.initializationFinished = true;
      });
    } else {
      _bloc = PhotoBloc();
      _bloc.photoListStream.listen((event) {
        setState(() {
          status = event.status;
          if (status == Status.COMPLETED) {
            showLoading = false;
            showError = false;
            showFooter = !(event.data == null || event.data.length == 0);

            if (_pageNo == 1) {
              photoList.clear();
            }
            if (event.data == null) return;
            photoList.addAll(event.data);
          } else if (status == Status.LOADING) {
            if (event.show) {
              showLoading = true;
              message = event.message;
            }
          } else if (status == Status.ERROR) {
            showLoading = false;
            showFooter = false;
            if (event.show) {
              showError = true;
              message = event.message;
            }
          }
        });
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
                      new SliverGrid(
                          delegate: new SliverChildBuilderDelegate(
                              (BuildContext buildContext, int index) {
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
