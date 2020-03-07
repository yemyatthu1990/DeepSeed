import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_seed/model/Feed.dart';
import 'package:deep_seed/network/ApiResponse.dart';
import 'package:deep_seed/repository/authentication_repository.dart';
import 'package:deep_seed/repository/could_fire_store_repository.dart';
import 'package:deep_seed/repository/firebase_storage_repository.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:path_provider/path_provider.dart';

class ImageEditorBloc {
  CloudFireStoreRepository _cloudFireStoreRepository;
  AuthenticationRepository _authenticationRepository;
  StreamController _authenticationController;
  StreamSink<ApiResponse<FirebaseUser>> get authenticationListSink =>
      _authenticationController.sink;
  Stream<ApiResponse<FirebaseUser>> get authenticationListStream =>
      _authenticationController.stream;
  FirebaseStorageRepository _firebaseStorageRepository;

  StreamController _storageController;

  StreamSink<ApiResponse<StorageTaskSnapshot>> get storageTaskSink =>
      _storageController.sink;

  Stream<ApiResponse<StorageTaskSnapshot>> get storageTaskStream =>
      _storageController.stream;

  StreamController _photoFilePathController;

  Stream<Map<String, String>> get photoFilePathStream =>
      _photoFilePathController.stream;
  StreamSink<Map<String, String>> get photoFilePathSink =>
      _photoFilePathController.sink;
  ImageEditorBloc() {
    _authenticationController = StreamController<ApiResponse<FirebaseUser>>();
    _authenticationRepository = AuthenticationRepository();
    _cloudFireStoreRepository = CloudFireStoreRepository();
    _storageController = StreamController<ApiResponse<StorageTaskSnapshot>>();
    _firebaseStorageRepository = FirebaseStorageRepository();
    _photoFilePathController = StreamController<Map<String, String>>();
  }

  signIn() async {
    authenticationListSink.add(ApiResponse.loading(true, "Signing in"));
    try {
      AuthResult authResult = await _authenticationRepository.signIn();
      authenticationListSink.add(ApiResponse.completed(authResult.user));
    } catch (e) {
      authenticationListSink.add(ApiResponse.error(true, e.toString()));
      print(e);
    }
  }

  getUser() async {
    authenticationListSink.add(ApiResponse.loading(true, "Getting user"));
    try {
      FirebaseUser user = await _authenticationRepository.getCurrentUserId();
      authenticationListSink.add(ApiResponse.completed(user));
    } catch (e) {
      authenticationListSink.add(ApiResponse.error(true, e.toString()));
      print(e);
    }
  }

  uploadPhoto(String uid, String imagePath, String imageName) async {
    storageTaskSink.add(ApiResponse.loading(true, "Uploading photo"));
    try {
      StorageTaskSnapshot snapshot = await _firebaseStorageRepository
          .uploadFile(uid, imagePath, imageName);
      storageTaskSink.add(ApiResponse.completed(snapshot));
    } catch (e) {
      storageTaskSink.add(ApiResponse.error(true, e.toString()));
      print(e);
    }
  }

  Future<String> getShareFilePath(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = new File('${tempDir.path}/$fileName');
    return file.path;
  }

  getSharePhoto(Uint8List imageBytes) async {
    String fileName =
        Timestamp.now().millisecondsSinceEpoch.toString() + ".jpg";
    final tempDir = await getTemporaryDirectory();
    final file = await new File('${tempDir.path}/$fileName').create();
    file.writeAsBytes(imageBytes).then((value) => {
          photoFilePathSink.add({"name": fileName, "path": value.path})
        });
  }

  uploadImage(Feed feed) async {
    _cloudFireStoreRepository
        .uploadImage(feed)
        .then((value) => {log("success uploading doc")})
        .catchError((error) {
      log("error uploading doc");
    });
  }

  dispose() {
    _authenticationController?.close();
    _storageController?.close();
    _photoFilePathController.close();
  }
}
