import 'dart:async';

import 'package:deep_seed/model/model.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/repository/PhotoRepository.dart';

class PhotoBloc {
  PhotoRepository _photoRepository;

  StreamController _photoListController;

  StreamSink<ApiResponse<List<Photo>>> get photoListSink =>
      _photoListController.sink;

  Stream<ApiResponse<List<Photo>>> get photoListStream =>
      _photoListController.stream;

  PhotoBloc() {
    _photoListController = StreamController<ApiResponse<List<Photo>>>();
    _photoRepository = PhotoRepository();
  }

  fetchPhotoList(int pageNo) async {
    photoListSink.add(ApiResponse.loading('Fetching Popular Movies'));
    try {
      List<Photo> photos = await _photoRepository.fetchPhotoList(pageNo);
      photoListSink.add(ApiResponse.completed(photos));
    } catch (e) {
      photoListSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _photoListController?.close();
  }
}
