import 'dart:async';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/repository/could_fire_store_repository.dart';
import 'package:deep_seed/util/preference_utils.dart';

typedef OnReportFinished();
typedef OnUpvoteFinished();

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

  upvoteImage(String downloadUrl, OnUpvoteFinished onUpvoteFinished,
      int upvoteCount) async {
    _fireStoreRepository
        .upvoteImage(downloadUrl, upvoteCount)
        .whenComplete(() => {onUpvoteFinished()});
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
      await Future.wait(querySnapshot.documents.map((document) async {
        Feed feed = new Feed();
        feed.userId = document["uid"];
        bool isBlocked = await PreferenceUtils.isUserBlocked(feed.userId);
        feed.downloadUrl = document["download_url"];
        bool isHidden = await PreferenceUtils.isImageHidden(feed.downloadUrl);
        if (!(isBlocked || isHidden)) {
          feed.imageRatio = document["image_ratio"];
          feed.timeStamp = document["timestamp"];
          feed.clapCount = document["clap_count"];
          feeds.add(feed);
        }
      }));

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

  Future<void> blockUser(String userId) async {
    return PreferenceUtils.addToBlockList(userId);
  }

  Future<void> hideImage(String downloadUrl) async {
    return PreferenceUtils.addToHideImageList(downloadUrl);
  }

  dispose() {
    _feedListController?.close();
  }
}
