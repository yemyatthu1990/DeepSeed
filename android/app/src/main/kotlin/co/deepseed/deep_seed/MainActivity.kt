package co.deepseed.deep_seed

import NativeAdmobBannerViewFactory
import android.annotation.TargetApi
import android.app.Activity
import android.app.Application.ActivityLifecycleCallbacks
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.PixelFormat
import android.graphics.Rect
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.Handler
import android.os.PersistableBundle
import android.util.AttributeSet
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver.OnGlobalLayoutListener
import android.widget.Toast
import androidx.core.content.FileProvider
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformViewRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterView
import java.io.File
import java.util.Random
import java.util.Timer
import java.util.TimerTask

class MainActivity: FlutterActivity(), StreamHandler,
    OnGlobalLayoutListener {

  var mainView: View? = null
  var isKeyboardVisible: Boolean = false
  var eventSink: EventSink? = null
  var stream: EventChannel? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    GeneratedPluginRegistrant.registerWith(this)
    registrarFor("")
            .platformViewRegistry().registerViewFactory(
                    "native_admob_banner_view",NativeAdmobBannerViewFactory(flutterView))
    MethodChannel(flutterView,"channel:co.deepseed.deep_seed/share").setMethodCallHandler { methodCall, _ ->
        if (methodCall.method == "shareFile") {
            shareFile(methodCall.arguments("path") as String, methodCall.arguments("shareText") as String)
        }
    }
    val channel = MethodChannel(flutterView, "flutter_native_admob")
      channel.setMethodCallHandler{ methodCall, result ->

        result.notImplemented()
      }






  /*  stream = EventChannel(flutterView, "channel:co.deepseed.deep_seed/keyboard_visibility")
    stream?.setStreamHandler(this)*/

  }

  override fun onStart() {
    super.onStart()
   /* mainView = window?.decorView
    mainView?.viewTreeObserver?.addOnGlobalLayoutListener(this)*/
  }

  private fun shareFile(path:String, shareText: String) {
    val imageFile = File(this.applicationContext.cacheDir,path)
    val contentUri = FileProvider.getUriForFile(this,"co.deepseed.deep_seed",imageFile)
    val shareIntent = Intent()
    shareIntent.action = Intent.ACTION_SEND
    shareIntent.type="image/jpg"
    shareIntent.putExtra(Intent.EXTRA_TEXT, shareText)
    shareIntent.putExtra(Intent.EXTRA_STREAM, contentUri)
    shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    val finalIntent = Intent.createChooser(shareIntent,"Share Image")
    val resInfoList = packageManager.queryIntentActivities(finalIntent, PackageManager.MATCH_DEFAULT_ONLY)
    resInfoList.forEach {
      val packageName = it.activityInfo.packageName
      grantUriPermission(packageName, contentUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION and Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }

    startActivity(finalIntent)
  }

  private fun loadAds() {

  }

   override fun onListen(
    p0: Any?,
    eventSink: EventSink?
  ) {
     System.out.println("listening..")
     this.eventSink = eventSink
  }

  override fun onCancel(p0: Any?) {
    eventSink = null

  }

//  override fun onStart() {
//    super.onStart()
//    if (isKeyboardVisible) eventSink?.success(1)
//    mainView = findViewById<ViewGroup>(android.R.id.content) as ViewGroup?
//    mainView?.viewTreeObserver?.addOnGlobalLayoutListener(this)
//  }

  override fun onDestroy() {
    super.onDestroy()
    unregisterListener()
  }

  override fun onStop() {
    super.onStop()
    unregisterListener()
  }

  override fun onGlobalLayout() {
    val r = Rect()
    /*mainView?.let {
      it.getWindowVisibleDisplayFrame(r)
      System.out.println(it.rootView.height)
      System.out.println(it.bottom)
      System.out.println(it.rootView.bottom
      )
      val screenHeight = it.rootView.height
      val keypadHeight = screenHeight - it.bottom
      val newState = keypadHeight > screenHeight * 0.15
      System.out.println("Screen"+screenHeight)
      System.out.println("Keypad"+keypadHeight)
      if (newState != isKeyboardVisible) {
        isKeyboardVisible = newState
        eventSink?.success(if (isKeyboardVisible) 1 else 0)
      }
    }
*/

  }

  fun unregisterListener() {
   /* mainView?.viewTreeObserver?.removeOnGlobalLayoutListener(this)
    mainView = null*/
  }

}
