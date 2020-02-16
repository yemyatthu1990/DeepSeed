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

class FavoriteListScreen extends StatefulWidget {
  _FavoriteListScreenState _favoriteListScreenState;
  final Key key;

  FavoriteListScreen({this.key}) : super(key: key);

  @override
  _FavoriteListScreenState createState() {
    return _FavoriteListScreenState();
  }
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  _FavoriteListScreenState();
  FavoriteListBloc _bloc;

  List<Urls> favoriteList = new List<Urls>();
  Status status;
  String message;
  @override
  void initState() {
    super.initState();
    _bloc = FavoriteListBloc();
    _bloc.favoriteListStream.listen((event) {
      setState(() {
        status = event.status;
        if (status == Status.COMPLETED) {
          if (event.data != null) {
            favoriteList = event.data;
          }
        } else if (status == Status.LOADING || status == Status.ERROR) {
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
        body: new CustomScrollView(
          slivers: <Widget>[
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
                                    "temp_file_url": ImageCacheManager()
                                        .getFileFromMemory(
                                            favoriteList[index].small)
                                        .file
                                        .path,
                                    "hero_tag":
                                        heroFavoriteTag + index.toString()
                                  };
                                  Navigator.pushNamed(context, detailRoute,
                                      arguments: data);
                                },
                                child: CachedNetworkImage(
                                  useOldImageOnUrlChange: true,
                                  imageUrl: favoriteList[index].small,
                                  cacheManager: ImageCacheManager(),
                                  fit: BoxFit.cover,
                                )))),
                  );
                }, childCount: favoriteList.length),
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2))
          ],
        ));
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
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
