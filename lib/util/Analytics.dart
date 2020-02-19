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

  Future<void> logShare(
      String contentType, String itemId, String method) async {
    await analytics.logShare(
        contentType: contentType, itemId: itemId, method: method);
  }
}
