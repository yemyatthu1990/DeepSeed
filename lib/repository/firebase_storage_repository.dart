import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageRepository {
  final FirebaseStorage storage = FirebaseStorage.instance;
  Future<StorageTaskSnapshot> uploadFile(
      String uid, String imagePath, String imageName) async {
    StorageReference storageReference =
        storage.ref().child('images/$uid\_$imageName');
    StorageUploadTask uploadTask = storageReference.putFile(File(imagePath));
    return await uploadTask.onComplete;
  }
}
