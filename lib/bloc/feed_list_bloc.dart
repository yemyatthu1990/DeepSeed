import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/repository/could_fire_store_repository.dart';

typedef OnReportFinished();

class FeedListBloc {
  DocumentSnapshot lastDocumentSnapshot;
  bool feedListLoading = false;
  CloudFireStoreRepository _fireStoreRepository;

  StreamController _feedListController;

  StreamSink<ApiResponse<List<Feed>>> get feedListSink =>
      _feedListController.sink;

  Stream<ApiResponse<List<Feed>>> get feedListStream =>
      _feedListController.stream;

  FeedListBloc() {
    _feedListController = StreamController<ApiResponse<List<Feed>>>();
    _fireStoreRepository = CloudFireStoreRepository();
  }
  report(String downloadUrl, OnReportFinished onReportFinished) async {
    _fireStoreRepository
        .reportImage(downloadUrl)
        .whenComplete(() => {onReportFinished()});
  }

  Future<bool> fetchFeedList({bool refresh = false}) async {
    //first list
    if (feedListLoading) return false;
    feedListLoading = true;
    feedListSink.add(ApiResponse.loading(lastDocumentSnapshot == null, ''));

    try {
      QuerySnapshot querySnapshot = await _fireStoreRepository
          .getListOfImages(refresh ? null : lastDocumentSnapshot);
      List<Feed> feeds = List();
      querySnapshot.documents.forEach((document) {
        Feed feed = new Feed();
        feed.userId = document["uid"];
        feed.downloadUrl = document["download_url"];
        feed.imageRatio = document["image_ratio"];
        feed.timeStamp = document["timestamp"];
        feeds.add(feed);
      });
      lastDocumentSnapshot =
          querySnapshot.documents[querySnapshot.documents.length - 1];
      feedListSink.add(ApiResponse.completed(feeds));
      feedListLoading = false;
    } catch (e) {
      feedListSink
          .add(ApiResponse.error(lastDocumentSnapshot == null, "Feeds empty"));
      feedListLoading = false;
    }
    return true;
  }

  dispose() {
    _feedListController?.close();
  }
}
