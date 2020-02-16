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

class ProfileListScreen extends StatefulWidget {
  final Key key;
  ProfileListScreen({this.key}) : super(key: key);

  @override
  _ProfileListScreenState createState() {
    return _ProfileListScreenState();
  }
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  _ProfileListScreenState();
  ProfileBloc _bloc;

  List<Feed> profileList = new List<Feed>();
  Status status;
  String message;
  @override
  void initState() {
    super.initState();
    _bloc = ProfileBloc();
    _bloc.profileStream.listen((event) {
      setState(() {
        status = event.status;
        if (status == Status.COMPLETED) {
          if (event.data != null) {
            profileList = event.data;
          }
        } else if (status == Status.LOADING || status == Status.ERROR) {
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
        body: new CustomScrollView(
          slivers: <Widget>[
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
                                            profileList[index].downloadUrl)
                                        .file
                                        .path,
                                    "hero_tag":
                                        heroProfileTag + index.toString()
                                  };
                                  Navigator.pushNamed(
                                      context, profileDetailRoute,
                                      arguments: data);
                                },
                                child: CachedNetworkImage(
                                  useOldImageOnUrlChange: true,
                                  imageUrl: profileList[index].downloadUrl,
                                  cacheManager: ImageCacheManager(),
                                  fit: BoxFit.cover,
                                )))),
                  );
                }, childCount: profileList.length),
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
