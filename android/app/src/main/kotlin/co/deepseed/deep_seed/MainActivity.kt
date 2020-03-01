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
import android.graphics.Typeface
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.Handler
import android.os.PersistableBundle
import android.util.AttributeSet
import android.util.Xml
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
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserException
import java.io.File
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.IOException
import java.lang.RuntimeException
import java.util.Random
import java.util.Timer
import java.util.TimerTask
import java.util.logging.XMLFormatter

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
            shareFile(methodCall.argument<String>("path")!!, methodCall.argument<String>("shareText")!!)
        }
    }

     MethodChannel(flutterView,"channel:co.deepseed.deep_seed/font").setMethodCallHandler { methodCall, result ->
        if (methodCall.method == "getDefaultFont") {
            result.success(getDefaultFont())
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
    shareIntent.putExtra(Intent.EXTRA_TEXT, shareText) //Share format `Photo by @photographerName on Unsplash
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

  private fun getDefaultFont(): String {
        var configFilename =  File("/system/etc/system_fonts.xml")
        if (!configFilename.exists()) {
          configFilename = File("/system/etc/fonts.xml")
          if (!configFilename.exists()) { configFilename = File("/system/etc/fallback_fonts.xml")
          }
        }
        System.out.println(  " CONFIG FILE NAME exits: "+ configFilename.exists() +" : "+configFilename.path)
        // sans-serif is the default font family name in Android SDK, check out the code in Typeface.java
        var defaultFontName = "ZawgyiX1"

    try {
      val fontsIn =  FileInputStream(configFilename)
      val parser = Xml.newPullParser()
      parser.setInput(fontsIn, null)
      var done = false
      var getTheText = false
      var eventType: Int
      while (!done) {
        eventType = parser.next()
        System.out.println("parsername "+parser.name)
        if (eventType == XmlPullParser.START_TAG && parser.name.toLowerCase() == "name") {
          getTheText = true
        }
        if (eventType == XmlPullParser.TEXT && getTheText) {
          // first name
          defaultFontName = parser.text
          done = true
        }
        if (eventType == XmlPullParser.END_DOCUMENT) {
          done = true
        }
      }
      System.out.println("Get the Text?: "+getTheText)
    } catch (e: RuntimeException) {
      System.err.println("GetDefaultFont: Didn't create default family (most likely, non-Minikin build)")
    } catch ( e: FileNotFoundException) {
      System.err.println("GetDefaultFont: config file Not found")
    } catch ( e: IOException) {
      System.err.println("GetDefaultFont: IO exception: " + e.message)
    } catch ( e: XmlPullParserException) {
      System.err.println("getDefaultFont: XML parse exception " + e.message)
    }
    return defaultFontName
  }

}
