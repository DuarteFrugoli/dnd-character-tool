package com.duartefrugoli.dnd_character_tool

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.WindowManager
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val fileChannelName = "dnd.character/file_import"
    private val screenChannelName = "dnd.character/screen"
    private var pendingFileContent: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.enableEdgeToEdge(window)
    }

    // Prevent FlutterActivity from using the content:// URI as the initial route,
    // which would cause go_router to navigate to "content://..." and crash.
    override fun getInitialRoute(): String? {
        if (intent.action == Intent.ACTION_VIEW) return null
        return super.getInitialRoute()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fileChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPendingFile" -> {
                        result.success(pendingFileContent)
                        pendingFileContent = null
                    }
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, screenChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setKeepScreenOn" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        runOnUiThread {
                            if (enabled) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                            }
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        if (intent.action == Intent.ACTION_VIEW) {
            handleIntent(intent)
            // Strip the data URI before passing to super so Flutter's navigation
            // channel does not forward the content:// URI to go_router.
            super.onNewIntent(Intent(intent).apply { data = null })
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                val content = pendingFileContent
                if (content != null) {
                    MethodChannel(messenger, fileChannelName).invokeMethod("onFileReceived", content)
                    pendingFileContent = null
                }
            }
            return
        }
        super.onNewIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (intent.action == Intent.ACTION_VIEW) {
            val uri: Uri = intent.data ?: return
            try {
                val stream = contentResolver.openInputStream(uri) ?: return
                val content = stream.bufferedReader().use { it.readText() }
                // Only accept content that looks like a character export or backup.
                if (content.contains("\"character\"") || content.contains("\"characters\"")) {
                    pendingFileContent = content
                }
            } catch (_: Exception) {}
        }
    }
}
