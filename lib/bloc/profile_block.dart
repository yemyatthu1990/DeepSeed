import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/repository/could_fire_store_repository.dart';

class ProfileBloc {
  CloudFireStoreRepository _fireStoreRepository;

  StreamController _profileController;

  StreamSink<ApiResponse<List<Feed>>> get profileSink =>
      _profileController.sink;

  Stream<ApiResponse<List<Feed>>> get profileStream =>
      _profileController.stream;

  ProfileBloc() {
    _profileController = StreamController<ApiResponse<List<Feed>>>();
    _fireStoreRepository = CloudFireStoreRepository();
  }

  fetchMyImages() async {
    profileSink.add(ApiResponse.loading('Fetching Profile'));

    try {
      QuerySnapshot querySnapshot = await _fireStoreRepository.getMyImages();
      List<Feed> feeds = List();
      querySnapshot.documents.forEach((document) {
        Feed feed = new Feed();
        feed.userId = document["uid"];
        feed.downloadUrl = document["download_url"];
        feed.imageRatio = document["image_ratio"];
        feed.timeStamp = document["timestamp"];
        feeds.add(feed);
      });
      profileSink.add(ApiResponse.completed(feeds));
    } catch (e) {
      profileSink.add(ApiResponse.error("Error fetching feeds"));
    }
  }

  dispose() {
    _profileController?.close();
  }
}
