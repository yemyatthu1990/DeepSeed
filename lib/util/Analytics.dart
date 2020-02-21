import 'package:firebase_analytics/firebase_analytics.dart';

class Analytics {
  static Analytics _instance;
  FirebaseAnalytics analytics;

  factory Analytics() {
    if (_instance == null) {
      _instance = new Analytics._();
    }
    return _instance;
  }

  Analytics._() {
    analytics = FirebaseAnalytics();
  }

  Future<void> sendAnalyticsEvent(
      String eventName, Map<String, dynamic> payload) async {
    await analytics.logEvent(
      name: eventName,
      parameters: payload,
    );
  }

  Future<void> setCurrentScreen(String screenName) async {
    await analytics.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenName,
    );
  }

  Future<void> logAppOpen() async {
    await analytics.logAppOpen();
  }

  Future<void> logShareImage(bool shareToDeepSeed) async {
    await analytics.logEvent(
        name: "share_image",
        parameters: {"share_to_deepseed": shareToDeepSeed});
  }

  Future<void> logWaterMarkAdsClicked() async {
    await analytics.logEvent(name: "water_mark_clicked");
  }

  Future<void> logShareFeed() async {
    await analytics.logEvent(name: "share_feed");
  }

  Future<void> logShareProfile() async {
    await analytics.logEvent(name: "share_profile");
  }

  Future<void> logFavoriteClicked() async {
    await analytics.logEvent(name: "favorite_clicked");
  }

  Future<void> logSearch(String query) async {
    await analytics.logSearch(searchTerm: "search");
  }

  Future<void> logCamera() async {
    await analytics.logEvent(name: "camera_opened");
  }

  Future<void> logGallery() async {
    await analytics.logEvent(name: "gallery_opened");
  }

  Future<void> logFontOpened() async {
    await analytics.logEvent(name: "font_opened");
  }

  Future<void> logColorOpened() async {
    await analytics.logEvent(name: "color_opened");
  }

  Future<void> logRatioChanged() async {
    await analytics.logEvent(name: "ratio_changed");
  }

  Future<void> logPoemOpened() async {
    await analytics.logEvent(name: "poem_opened");
  }
}
