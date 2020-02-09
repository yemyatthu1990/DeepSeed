import 'package:cached_network_image/cached_network_image.dart';
import 'package:deep_seed/bloc/PhotoBloc.dart';
import 'package:deep_seed/constants.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:flutter/material.dart';
import 'package:infinite_widgets/infinite_widgets.dart';

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
  @override
  void initState() {
    super.initState();
    _bloc = PhotoBloc();
    _bloc.fetchPhotoList(_pageNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<ApiResponse<List<Photo>>>(
        stream: _bloc.photoListStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                if (_pageNo == 1) {
                  return Loading(
                    loadingMessage: snapshot.data.message,
                  );
                }
                break;
              case Status.COMPLETED:
                PhotoList photoListScreen = new PhotoList(this);
                if (_pageNo == 1) {
                  photoList.clear();
                }
                photoList.addAll(snapshot.data.data);
                photoListScreen.photoList = photoList;
                return photoListScreen;
                break;
              case Status.ERROR:
                return Error(
                    errorMessage: snapshot.data.message,
                    onRetryPressed: () {
                      _pageNo = 1;
                      return _bloc.fetchPhotoList(1);
                    });
                break;
            }
          }
          return Container();
        },
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  void onScroll() {
    _pageNo = _pageNo + 1;
    print("on scroll " +
        _pageNo.toString() +
        " " +
        photoList.length.toString()); //
    if (_pageNo < 4) {
      print(_pageNo.toString() + "WTF");

      _bloc.fetchPhotoList(_pageNo);
    } else {
      print("do nothing");
    }
  }
}

class PhotoList extends StatelessWidget {
  _PhotoInfiniteInterface _interface;
  var photoList = new List<Photo>();

  PhotoList(_PhotoInfiniteInterface interface) {
    this._interface = interface;
  }
  ScrollController _buildScrollController() {
    ScrollController _scrollController = new ScrollController();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll - currentScroll <= 100) {
        _interface.onScroll();
      }
    });
    return _scrollController;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
                                "index": index
                              };
                              Navigator.pushNamed(context, detailRoute,
                                  arguments: data);
                            },
                            child: CachedNetworkImage(
                              imageUrl: photoList[index].urls.small,
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
    );
    return InfiniteGridView(
      itemCount: photoList.length,
      hasNext: (photoList.length ~/ 10) < 4,
      scrollThreshold: 100,
      loadingWidget: Footer(),
      nextData: this.loadNextData(),
      itemBuilder: (context, index) {},
    );
  }

  loadNextData() {
    _interface.onScroll();
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
