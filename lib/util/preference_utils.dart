import 'package:deep_seed/model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static String favoriteKey = "Favorite";
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
}