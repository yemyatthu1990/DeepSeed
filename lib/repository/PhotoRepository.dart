import 'dart:io' show Platform;
import 'dart:math';

import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiBaseHelper.dart';

class PhotoRepository {
  ApiBaseHelper _helper = ApiBaseHelper();
  String apiKey = "";

  static List<String> _defaultQueries = ["love", "hate", "relationship", "longing", "sad", "depression", "girls"];
  String defaultQuery = _defaultQueries[Random().nextInt(_defaultQueries.length-1)];
  PhotoRepository() {
    if (Platform.isAndroid) apiKey = "d47eb5e2d163fc2a6b047108bd3b201bfcd8129a9aaa92cd7dac0777f8fd762a";
    if (Platform.isIOS) apiKey = "4b36820da7cb19e67bec552aa419229e012ed54d988b60f3f6db16e04082d2f4";
  }

  Future<List<Photo>> fetchPhotoList(int pageNo, String query) async {
    if (query == null || query.length == 0) query = defaultQuery;
    final response =
    /* :*/ await _helper.get(
            "search/photos/?page=$pageNo&&query=$query&&client_id=$apiKey");

    List<Photo> results = new List<Photo>();
    response["results"].forEach((v) {
      results.add(new Photo.fromJson(v));
    });
    return results;
  }
}
