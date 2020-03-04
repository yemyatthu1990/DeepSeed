import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

class CloudFireStoreRepository {
  var fireStore = Firestore.instance;
  var firebaseAuth = FirebaseAuth.instance;
  Future<QuerySnapshot> getListOfImages(DocumentSnapshot snapshot) async {
    if (snapshot == null) {
      return await fireStore
          .collection("images")
          .where("featured", isEqualTo: true)
          .orderBy("timestamp", descending: true)
          .limit(5)
          .getDocuments(source: Source.serverAndCache);
    } else {
      return await fireStore
          .collection("images")
          .where("featured", isEqualTo: true)
          .orderBy("timestamp", descending: true)
          .limit(5)
          .startAfterDocument(snapshot)
          .getDocuments(source: Source.serverAndCache);
    }
  }

  Future<void> deleteMyImage(String downloadUrl) async {
    var currentUser = await firebaseAuth.currentUser();

    if (currentUser == null) {
      return null;
    }
    return fireStore
        .collection("images")
        .limit(1)
        .where("uid", isEqualTo: currentUser.uid)
        .where("download_url", isEqualTo: downloadUrl)
        .getDocuments(source: Source.serverAndCache)
        .then((snapshot) {
      if (snapshot.documents.length > 0) {
        snapshot.documents[0].reference.delete();
      }
    });
  }

  Future<QuerySnapshot> getMyImages() async {
    var currentUser = await firebaseAuth.currentUser();
    if (currentUser == null) {
      return null;
    }
    return fireStore
        .collection("images")
        .limit(25)
        .where("uid", isEqualTo: currentUser.uid)
        .getDocuments(source: Source.serverAndCache);
  }

  Future<QuerySnapshot> reportImage(String downloadUrl) async {
    var currentUser = await firebaseAuth.currentUser();
    if (currentUser == null) {
      await firebaseAuth.signInAnonymously();
    }

    var ref = fireStore
        .collection("images")
        .where("download_url", isEqualTo: downloadUrl)
        .getDocuments(source: Source.server);
    ref.then((value) {
      if (value != null &&
          value.documents != null &&
          value.documents.length > 0) {
        int reportCount = 0;
        if (value.documents[0].data["report_count"] == null) {
          reportCount = 1;
        } else {
          reportCount = (value.documents[0].data["report_count"] as int) + 1;
        }

        value.documents[0].reference.updateData({"report_count": reportCount});
      }
    });
  }

  Future<QuerySnapshot> upvoteImage(String downloadUrl, int upvoteCount) async {
    var currentUser = await firebaseAuth.currentUser();
    if (currentUser == null) {
      await firebaseAuth.signInAnonymously();
    }

    var ref = fireStore
        .collection("images")
        .where("download_url", isEqualTo: downloadUrl)
        .getDocuments(source: Source.server);
    ref.then((value) {
      if (value != null &&
          value.documents != null &&
          value.documents.length > 0)
        value.documents[0].reference.updateData({"clap_count": upvoteCount});
    });
  }

  Future<void> uploadImage(Feed feed) async {
    return await fireStore
        .collection("images")
        .document(Timestamp.now().millisecondsSinceEpoch.toString())
        .setData({
      "uid": feed.userId,
      "download_url": feed.downloadUrl,
      "image_ratio": feed.imageRatio,
      "timestamp": feed.timeStamp,
      "featured": false
    });
  }
}
