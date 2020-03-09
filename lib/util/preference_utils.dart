import 'package:deep_seed/model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

class PreferenceUtils {
  static String favoriteKey = "Favorite";
  static String hideKey = "Hide";
  static String zawgyiDialogKey = "zawgyiDiaog";
  static String isUnicodeKey = "isUnicode";
  static String blockKey = "Block";
  static Future<List<Urls>> getFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> url = prefs.getStringList(favoriteKey);
    List<Urls> finalUrls = new List();
    if (url != null) {
      url.forEach((url) {
        var urls = url.split("#");
        if (urls.length < 2) return;
        Urls finalUrl = new Urls(small: urls[0], full: urls[1]);
        finalUrls.add(finalUrl);
      });
    }
    return finalUrls;
  }

  static Future<bool> isFavorite(String smallUrl, String fullrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = smallUrl + "#" + fullrl;
    var favoriteList = prefs.getStringList(favoriteKey);
    if (favoriteList == null) return false;
    return favoriteList.contains(url);
  }

  static Future<void> addToFavorite(String smallUrl, String fullUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = smallUrl + "#" + fullUrl;
    List<String> favorites;
    if (prefs.containsKey(favoriteKey)) {
      favorites = prefs.getStringList(favoriteKey);
    }
    if (favorites == null) favorites = new List();
    favorites.add(url);

    await prefs.setStringList(favoriteKey, favorites);
  }

  static List<String> _hideImageList;
  static List<String> _blockUserList;

  static Future<void> addToHideImageList(String url) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (preferences.containsKey(hideKey)) {
      _hideImageList = preferences.getStringList(hideKey);
    }
    if (_hideImageList == null) _hideImageList = new List();
    _hideImageList.add(url);
    await preferences.setStringList(hideKey, _hideImageList);
  }


  static Future<bool> isImageHidden(String url) async{
    if (_hideImageList == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _hideImageList = preferences.getStringList(hideKey);
    }
    if (_hideImageList == null) return false;
    return _hideImageList.contains(url);
  }


  static Future<void> addToBlockList(String userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if (preferences.containsKey(blockKey)) {
      _blockUserList = preferences.getStringList(blockKey);
    }
    if (_blockUserList == null) _blockUserList = new List();
    _blockUserList.add(userId);
    await preferences.setStringList(blockKey, _blockUserList);
  }


  static Future<bool> isUserBlocked(String userId) async{
    if (_blockUserList == null) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _blockUserList = preferences.getStringList(blockKey);
    }
    if (_blockUserList == null) return false;
    return _blockUserList.contains(userId);
  }

  static Future<void> removeFromFavorite(
      String smallUrl, String fullUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = smallUrl + "#" + fullUrl;
    if (prefs.containsKey(favoriteKey)) {
      List<String> favorites = prefs.getStringList(favoriteKey);
      if (favorites == null || favorites.isEmpty || !favorites.contains(url))
        return;
      favorites.remove(url);
      await prefs.setStringList(favoriteKey, favorites);
    }
  }

  static Future<bool> haveShownZawgyiDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(zawgyiDialogKey))
      return prefs.getBool(zawgyiDialogKey);
    else
      return false;
  }

  static Future<void> zawgyiDialogHasShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(zawgyiDialogKey, true);
  }

  static Future<bool> isUnicode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(isUnicodeKey)) {
      return prefs.getBool(isUnicodeKey);
    } else {
      bool isUnicode = await Utils.isUnicode();
      prefs.setBool(isUnicodeKey, isUnicode);
      return isUnicode;
    }
  }
}
