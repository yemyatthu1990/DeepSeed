import 'dart:io' show Platform;
import 'dart:math';

import 'package:deep_seed/main.dart';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiBaseHelper.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class PhotoRepository {
  ApiBaseHelper _helper = ApiBaseHelper();

  static List<String> _defaultQueries = [
    "love relationship and marriage",
    "hate anger relationship",
    "longing",
    "sad",
    "depression",
    "girls boys",
    "rainy sad coffee",
    "ex girlfriend boyfriend",
    "book poem art"
  ];
  String defaultQuery =
      _defaultQueries[Random().nextInt(_defaultQueries.length - 1)];

  Future<List<Photo>> fetchPhotoList(int pageNo, String query) async {
    if (query == null || query.length == 0) query = defaultQuery;
    final response =
        /* :*/ await _helper.get(
            "search/photos/?page=$pageNo&&query=$query&&client_id=${RemoteConfigKey.apiKey}");

    List<Photo> results = new List<Photo>();
    response["results"].forEach((v) {
      results.add(new Photo.fromJson(v));
    });
    return results;
  }

  Future<bool> sendDownloadLocationEvent(String url) async {
    await _helper.get("$url?client_id=${RemoteConfigKey.apiKey}", baseUrl: "");
    return true;
  }
}
