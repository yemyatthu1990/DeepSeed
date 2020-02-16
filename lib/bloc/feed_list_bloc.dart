import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/repository/could_fire_store_repository.dart';

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

  fetchFeedList() async {
    //first list
    if (feedListLoading) return;
    feedListLoading = true;
    if (lastDocumentSnapshot == null) {
      feedListSink.add(ApiResponse.loading('Fetching Feed'));
    }
    try {
      QuerySnapshot querySnapshot =
          await _fireStoreRepository.getListOfImages(lastDocumentSnapshot);
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
      if (lastDocumentSnapshot == null) {
        feedListSink.add(ApiResponse.error("Error fetching feeds"));
      }
      feedListLoading = false;
    }
  }

  dispose() {
    _feedListController?.close();
  }
}
