package com.nobodywho.ooo.flutter_starter_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "copy_asset")
            .setMethodCallHandler { call, result ->
                if (call.method == "copyAsset") {
                    val assetPath = call.argument<String>("assetPath")!!
                    val destPath = call.argument<String>("destPath")!!
                    try {
                        val destFile = File(destPath)
                        if (!destFile.exists()) {
                            destFile.parentFile?.mkdirs()
                            assets.open("flutter_assets/$assetPath").use { input ->
                                destFile.outputStream().use { output ->
                                    input.copyTo(output)
                                }
                            }
                        }
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("COPY_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}