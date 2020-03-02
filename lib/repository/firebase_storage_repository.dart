import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FirebaseStorageRepository {
  final FirebaseStorage storage = FirebaseStorage.instance;
  Future<StorageTaskSnapshot> uploadFile(
      String uid, String imagePath, String imageName) async {
    StorageReference storageReference =
        storage.ref().child('images/$uid\_$imageName');

    StorageUploadTask uploadTask = storageReference.putFile(File(imagePath));
    return await uploadTask.onComplete;
  }

  Future<void> downloadFont(String fontName, String folderName) async {
    StorageReference storageReference =
        storage.ref().child('fonts/$folderName/$fontName');
    String downloadUrl = await storageReference.getDownloadURL();
    final fileDir = await getApplicationSupportDirectory();
    final file = new File('${fileDir.path}/$folderName/$fontName');
    var fontLoader = FontLoader(fontName.replaceFirst(".ttf", ""));
    bool fileExist = await file.exists();
    if (fileExist) {
      fontLoader.addFont(_getByteData(file));
    } else {
      ByteData bytes = await fetchFont(downloadUrl);
      await Directory('${fileDir.path}/$folderName').create(recursive: true);
      await file.writeAsBytes(bytes.buffer.asUint8List());
      fontLoader.addFont(_getByteData(file));
    }
    return fontLoader.load();
  }

  Future<ByteData> _getByteData(File file) async {
    Uint8List bytes = await file.readAsBytes();
    return ByteData.view(bytes.buffer);
  }

  Future<List<String>> downloadAllFonts(bool isUnicode) async {
    String folderName = isUnicode ? "unicode" : "zawgyi";
    StorageReference storageReference =
        storage.ref().child('fonts/$folderName');
    Map<dynamic, dynamic> fonts =
        await storageReference.listAll() as Map<dynamic, dynamic>;
    List<String> fontList = new List();
    var fontMap = fonts["items"] as Map<dynamic, dynamic>;
    fontMap.keys.forEach((element) {
      fontList.add(element);
    });
    await Future.wait(fontList.map((key) async {
      await downloadFont(key, folderName);
    }));
    return fontList;
  }

  Future<ByteData> fetchFont(String url) async {
    final response = await http.get(url);
    print("fetching $url");
    if (response.statusCode == 200) {
      return ByteData.view(response.bodyBytes.buffer);
    } else {
      // If that call was not successful, throw an error.
      return null;
    }
  }
}
