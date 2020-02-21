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

  fetchPhotoList(int pageNo, String query) async {
    photoListSink.add(ApiResponse.loading(pageNo == 1, ''));
    try {
      List<Photo> photos = await _photoRepository.fetchPhotoList(pageNo, query);
      photoListSink.add(ApiResponse.completed(photos));
    } catch (e) {
      photoListSink.add(ApiResponse.error(pageNo == 1, e.toString()));
    }
  }

  sendDownoadEvent(String url) {
    _photoRepository.sendDownloadLocationEvent(url);
  }

  dispose() {
    _photoListController?.close();
  }
}
