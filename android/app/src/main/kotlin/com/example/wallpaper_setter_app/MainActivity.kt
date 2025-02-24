package com.example.wallpaper_setter_app

import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

class MainActivity: FlutterActivity() {
    private val CHANNEL = "wallpaper_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setWallpaper") {
                val imageUrl = call.argument<String>("url")
                if (imageUrl != null) {
                    setWallpaperFromUrl(imageUrl, result)
                } else {
                    result.error("INVALID_URL", "URL is null or invalid", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun setWallpaperFromUrl(imageUrl: String, result: MethodChannel.Result) {
        Executors.newSingleThreadExecutor().execute {
            try {
                val url = URL(imageUrl)
                val connection = url.openConnection() as HttpURLConnection
                connection.doInput = true
                connection.connect()
                val input: InputStream = connection.inputStream
                val bitmap = BitmapFactory.decodeStream(input)

                val wallpaperManager = WallpaperManager.getInstance(applicationContext)
                wallpaperManager.setBitmap(bitmap)

                Handler(Looper.getMainLooper()).post {
                    result.success("Wallpaper set successfully!")
                }
            } catch (e: Exception) {
                Log.e("WallpaperError", "Failed to set wallpaper: ${e.message}")
                Handler(Looper.getMainLooper()).post {
                    result.error("ERROR", "Failed to set wallpaper: ${e.message}", null)
                }
            }
        }
    }
}
