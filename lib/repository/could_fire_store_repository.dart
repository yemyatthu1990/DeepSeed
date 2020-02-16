import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudFireStoreRepository {
  var fireStore = Firestore.instance;
  var firebaseAuth = FirebaseAuth.instance;
  Future<QuerySnapshot> getListOfImages(DocumentSnapshot snapshot) async {
    if (snapshot == null) {
      return await fireStore
          .collection("images")
          .orderBy("timestamp", descending: true)
          .limit(25)
          .getDocuments(source: Source.serverAndCache);
    } else {
      return await fireStore
          .collection("images")
          .orderBy("timestamp", descending: true)
          .limit(25)
          .startAfterDocument(snapshot)
          .getDocuments(source: Source.serverAndCache);
    }
  }

  Future<QuerySnapshot> getMyImages() async {
    var currentUser = await firebaseAuth.currentUser();
    print("CURRENT USER" + currentUser.toString());
    if (currentUser == null) {
      return null;
    }
    print("current user uid: " + currentUser.uid);
    return fireStore
        .collection("images")
        .limit(25)
        .where("uid", isEqualTo: currentUser.uid)
        .getDocuments(source: Source.serverAndCache);
  }

  Future<void> uploadImage(Feed feed) async {
    return await fireStore
        .collection("images")
        .document(Timestamp.now().millisecondsSinceEpoch.toString())
        .setData({
      "uid": feed.userId,
      "download_url": feed.downloadUrl,
      "image_ratio": feed.imageRatio,
      "timestamp": feed.timeStamp
    });
  }
}
