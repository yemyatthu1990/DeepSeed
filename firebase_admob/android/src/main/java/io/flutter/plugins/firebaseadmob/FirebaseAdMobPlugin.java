// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.content.Context;
import android.view.Gravity;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.MobileAds;
import com.google.firebase.FirebaseApp;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Locale;
import java.util.Map;

/**
 * Flutter plugin accessing Firebase Admob API.
 *
 * <p>Instantiate this in an add to app scenario to gracefully handle activity and context changes.
 */
public class FirebaseAdMobPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {
  private Context applicationContext;
  private MethodChannel channel;
  private Activity activity;
  // This is always null when not using v2 embedding.
  private FlutterPluginBinding pluginBinding;
  private RewardedVideoAdWrapper rewardedWrapper;

  /**
   * Registers a plugin with the v1 embedding api {@code io.flutter.plugin.common}.
   *
   * <p>Calling this will register the plugin with the passed registrar. However, plugins
   * initialized this way won't react to changes in activity or context.
   *
   * @param registrar connects this plugin's {@link
   *     io.flutter.plugin.common.MethodChannel.MethodCallHandler} to its {@link
   *     io.flutter.plugin.common.BinaryMessenger}.
   */
  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // If a background Flutter view tries to register the plugin, there will be no activity from the registrar.
      // We stop the registering process immediately because the firebase_admob requires an activity.
      return;
    }

    final FirebaseAdMobPlugin plugin = new FirebaseAdMobPlugin();
    plugin.initializePlugin(registrar.context(), registrar.activity(), registrar.messenger());
  }

  private void initializePlugin(
      Context applicationContext, Activity activity, BinaryMessenger messenger) {
    this.activity = activity;
    this.applicationContext = applicationContext;
    FirebaseApp.initializeApp(applicationContext);

    this.channel = new MethodChannel(messenger, "plugins.flutter.io/firebase_admob");
    channel.setMethodCallHandler(this);

    rewardedWrapper = new RewardedVideoAdWrapper(activity, channel);
  }

  private void callInitialize(MethodCall call, Result result) {
    String appId = call.argument("appId");
    if (appId == null || appId.isEmpty()) {
      result.error("no_app_id", "a null or empty AdMob appId was provided", null);
      return;
    }
    MobileAds.initialize(applicationContext, appId);
    result.success(Boolean.TRUE);
  }

  private void callLoadBannerAd(Integer id, Activity activity, MethodCall call, Result result) {
    String adUnitId = call.argument("adUnitId");
    if (adUnitId == null || adUnitId.isEmpty()) {
      result.error("no_unit_id", "a null or empty adUnitId was provided for ad id=" + id, null);
      return;
    }

    final Integer width = call.argument("width");
    final Integer height = call.argument("height");
    final String adSizeType = call.argument("adSizeType");

    if (!"AdSizeType.WidthAndHeight".equals(adSizeType)
        && !"AdSizeType.SmartBanner".equals(adSizeType)) {
      String errMsg =
          String.format(
              Locale.ENGLISH,
              "an invalid adSizeType (%s) was provided for banner id=%d",
              adSizeType,
              id);
      result.error("invalid_adsizetype", errMsg, null);
    }

    if ("AdSizeType.WidthAndHeight".equals(adSizeType) && (width <= 0 || height <= 0)) {
      String errMsg =
          String.format(
              Locale.ENGLISH,
              "an invalid AdSize (%d, %d) was provided for banner id=%d",
              width,
              height,
              id);
      result.error("invalid_adsize", errMsg, null);
    }

    AdSize adSize;
    if ("AdSizeType.SmartBanner".equals(adSizeType)) {
      adSize = AdSize.SMART_BANNER;
    } else {
      adSize = new AdSize(width, height);
    }

    MobileAd.Banner banner = MobileAd.createBanner(id, adSize, activity, channel);

    if (banner.status != MobileAd.Status.CREATED) {
      if (banner.status == MobileAd.Status.FAILED)
        result.error("load_failed_ad", "cannot reload a failed ad, id=" + id, null);
      else result.success(Boolean.TRUE); // The ad was already loaded.
      return;
    }

    Map<String, Object> targetingInfo = call.argument("targetingInfo");
    banner.load(adUnitId, targetingInfo);
    result.success(Boolean.TRUE);
  }

  private void callLoadInterstitialAd(MobileAd ad, MethodCall call, Result result) {
    if (ad.status != MobileAd.Status.CREATED) {
      if (ad.status == MobileAd.Status.FAILED)
        result.error("load_failed_ad", "cannot reload a failed ad, id=" + ad.id, null);
      else result.success(Boolean.TRUE); // The ad was already loaded.
      return;
    }

    String adUnitId = call.argument("adUnitId");
    if (adUnitId == null || adUnitId.isEmpty()) {
      result.error(
          "no_adunit_id", "a null or empty adUnitId was provided for ad id=" + ad.id, null);
      return;
    }
    Map<String, Object> targetingInfo = call.argument("targetingInfo");
    ad.load(adUnitId, targetingInfo);
    result.success(Boolean.TRUE);
  }

  private void callLoadRewardedVideoAd(MethodCall call, Result result) {
    if (rewardedWrapper.getStatus() != RewardedVideoAdWrapper.Status.CREATED
        && rewardedWrapper.getStatus() != RewardedVideoAdWrapper.Status.FAILED) {
      result.success(Boolean.TRUE); // The ad was already loading or loaded.
      return;
    }

    String adUnitId = call.argument("adUnitId");
    if (adUnitId == null || adUnitId.isEmpty()) {
      result.error(
          "no_ad_unit_id", "a non-empty adUnitId was not provided for rewarded video", null);
      return;
    }

    Map<String, Object> targetingInfo = call.argument("targetingInfo");
    if (targetingInfo == null) {
      result.error(
          "no_targeting_info", "a null targetingInfo object was provided for rewarded video", null);
      return;
    }

    rewardedWrapper.load(adUnitId, targetingInfo);
    result.success(Boolean.TRUE);
  }

  private void callShowAd(Integer id, MethodCall call, Result result) {
    MobileAd ad = MobileAd.getAdForId(id);
    if (ad == null) {
      result.error("ad_not_loaded", "show failed, the specified ad was not loaded id=" + id, null);
      return;
    }
    final String anchorOffset = call.argument("anchorOffset");
    final String horizontalCenterOffset = call.argument("horizontalCenterOffset");
    final String anchorType = call.argument("anchorType");
    if (anchorOffset != null) {
      ad.anchorOffset = Double.parseDouble(anchorOffset);
    }
    if (anchorType != null) {
      ad.horizontalCenterOffset = Double.parseDouble(horizontalCenterOffset);
    }
    if (anchorType != null) {
      ad.anchorType = "bottom".equals(anchorType) ? Gravity.BOTTOM : Gravity.TOP;
    }

    ad.show();
    result.success(Boolean.TRUE);
  }

  private void callIsAdLoaded(Integer id, Result result) {
    MobileAd ad = MobileAd.getAdForId(id);
    if (ad == null) {
      result.error("no_ad_for_id", "isAdLoaded failed, no add exists for id=" + id, null);
      return;
    }
    result.success(ad.status == MobileAd.Status.LOADED ? Boolean.TRUE : Boolean.FALSE);
  }

  private void callShowRewardedVideoAd(Result result) {
    if (rewardedWrapper.getStatus() == RewardedVideoAdWrapper.Status.LOADED) {
      rewardedWrapper.show();
      result.success(Boolean.TRUE);
    } else {
      result.error("ad_not_loaded", "show failed for rewarded video, no ad was loaded", null);
    }
  }

  private void callDestroyRewardedVdieoAd(Result result) {
    rewardedWrapper.destroy(activity);
    result.success(Boolean.TRUE);
  }

  private void callDisposeAd(Integer id, Result result) {
    MobileAd ad = MobileAd.getAdForId(id);
    if (ad == null) {
      result.error("no_ad_for_id", "dispose failed, no add exists for id=" + id, null);
      return;
    }

    ad.dispose();
    result.success(Boolean.TRUE);
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    pluginBinding = binding;
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    initializePlugin(
        pluginBinding.getApplicationContext(),
        binding.getActivity(),
        pluginBinding.getFlutterEngine().getDartExecutor());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    MobileAd.disposeAll();
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    initializePlugin(
        pluginBinding.getApplicationContext(),
        binding.getActivity(),
        pluginBinding.getFlutterEngine().getDartExecutor());
  }

  @Override
  public void onDetachedFromActivity() {
    MobileAd.disposeAll();
    activity = null;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (activity == null) {
      result.error("no_activity", "firebase_admob plugin requires a foreground activity", null);
      return;
    }

    Integer id = call.argument("id");

    switch (call.method) {
      case "initialize":
        callInitialize(call, result);
        break;
      case "loadBannerAd":
        callLoadBannerAd(id, activity, call, result);
        break;
      case "loadInterstitialAd":
        callLoadInterstitialAd(MobileAd.createInterstitial(id, activity, channel), call, result);
        break;
      case "loadRewardedVideoAd":
        callLoadRewardedVideoAd(call, result);
        break;
      case "showAd":
        callShowAd(id, call, result);
        break;
      case "showRewardedVideoAd":
        callShowRewardedVideoAd(result);
        break;
      case "destroyRewardedVideoAd":
        callDestroyRewardedVdieoAd(result);
      case "disposeAd":
        callDisposeAd(id, result);
        break;
      case "isAdLoaded":
        callIsAdLoaded(id, result);
        break;
      default:
        result.notImplemented();
    }
  }
}
