import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/bloc/PhotoBloc.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/network/image_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PhotoListScreen extends StatefulWidget {
  @override
  _PhotoListScreenState createState() => _PhotoListScreenState();
}

class _PhotoInfiniteInterface {
  void onScroll() {}
}

class _PhotoListScreenState extends State<PhotoListScreen>
    implements _PhotoInfiniteInterface {
  PhotoBloc _bloc;
  int _pageNo = 1;
  List<Photo> photoList = new List<Photo>();
  Status status;
  String message;
  @override
  void initState() {
    super.initState();
    _bloc = PhotoBloc();
    _bloc.photoListStream.listen((event) {
      setState(() {
        status = event.status;
        if (status == Status.COMPLETED) {
          photoList.addAll(event.data);
        } else if (status == Status.LOADING || status == Status.ERROR) {
          message = event.message;
        }
      });
    });
    _bloc.fetchPhotoList(_pageNo);
  }

  ScrollController _buildScrollController() {
    ScrollController _scrollController = new ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      print(maxScroll.toString() + " max scroll");
      print(currentScroll.toString() + " current scroll");
      if (maxScroll == currentScroll) {
        print("on next");
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
        backgroundColor: Colors.white,
        body: CustomScrollView(
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
                                  Map<String, dynamic> data = {
                                    "urls": photoList[index].urls,
                                    "index": index,
                                    "temp_file_url": ImageCacheManager()
                                        .getFileFromMemory(
                                            photoList[index].urls.small)
                                        .file
                                        .path
                                  };
                                  Navigator.pushNamed(context, detailRoute,
                                      arguments: data);
                                },
                                child: CachedNetworkImage(
                                  imageUrl: photoList[index].urls.small,
                                  cacheManager: ImageCacheManager(),
                                  fit: BoxFit.cover,
                                )))),
                  );
                }, childCount: photoList.length),
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2)),
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
    int _actualPageNo = photoList.length ~/ 10 + 1;
    print(_pageNo.toString() + " : " + _actualPageNo.toString());
    if (_pageNo == _actualPageNo) return;
    _pageNo = _actualPageNo;
    print("on scroll " +
        _pageNo.toString() +
        " " +
        photoList.length.toString()); //

    print(_pageNo.toString() + "WTF");

    _bloc.fetchPhotoList(_pageNo);
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
