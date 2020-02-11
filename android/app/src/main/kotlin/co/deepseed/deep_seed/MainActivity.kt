package co.deepseed.deep_seed

import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.core.content.FileProvider
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)


    MethodChannel(flutterView,"channel:co.deepseed.deep_seed/share").setMethodCallHandler { methodCall, _ ->
        if (methodCall.method == "shareFile") {
            shareFile(methodCall.arguments as String)
        }
    }
  }

  private fun shareFile(path:String) {
    val imageFile = File(this.applicationContext.cacheDir,path)
    val contentUri = FileProvider.getUriForFile(this,"co.deepseed.deep_seed",imageFile)
    val shareIntent = Intent()
    shareIntent.action = Intent.ACTION_SEND
    shareIntent.type="image/jpg"
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
}
