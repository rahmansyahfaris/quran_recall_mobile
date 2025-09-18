// android/app/src/main/kotlin/com/example/quran_recall_mobile/MainActivity.kt
package com.example.quran_recall_mobile

import android.content.ContentResolver
import android.net.Uri
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "quran_recall/files"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "overwriteFile") {
                    val uriStr = call.argument<String>("uri")
                    val data = call.argument<ByteArray>("data")

                    if (uriStr != null && data != null) {
                        try {
                            val uri = Uri.parse(uriStr)
                            val resolver: ContentResolver = contentResolver
                            val outStream: OutputStream? = resolver.openOutputStream(uri)

                            if (outStream != null) {
                                outStream.write(data)
                                outStream.flush()
                                outStream.close()
                                result.success("Success")
                            } else {
                                result.error("WRITE_FAIL", "Cannot open OutputStream", null)
                            }
                        } catch (e: Exception) {
                            result.error("EXCEPTION", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGS", "URI or data missing", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
