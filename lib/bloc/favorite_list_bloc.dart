import 'dart:async';
import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/util/preference_utils.dart';

class FavoriteListBloc {
  StreamController _favoriteListController;

  StreamSink<ApiResponse<List<Urls>>> get favoriteListSink =>
      _favoriteListController.sink;

  Stream<ApiResponse<List<Urls>>> get favoriteListStream =>
      _favoriteListController.stream;

  FavoriteListBloc() {
    _favoriteListController = StreamController<ApiResponse<List<Urls>>>();
  }

  Future<bool> fetchFavoriteList(bool isRefreshing) async {
    favoriteListSink.add(ApiResponse.loading(!isRefreshing, ''));
    try {
      List<Urls> favorites = await PreferenceUtils.getFavorites();
      favoriteListSink.add(ApiResponse.completed(favorites));
    } catch (e) {
      favoriteListSink.add(ApiResponse.error(true, "Add to favorites"));
      print(e);
    }
    return true;
  }

  dispose() {
    _favoriteListController?.close();
  }
}
