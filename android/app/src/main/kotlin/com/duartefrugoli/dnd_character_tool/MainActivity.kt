package com.duartefrugoli.dnd_character_tool

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "dnd.character/file_import"
    private var pendingFileContent: String? = null

    // Prevent FlutterActivity from using the content:// URI as the initial route,
    // which would cause go_router to navigate to "content://..." and crash.
    override fun getInitialRoute(): String? {
        if (intent.action == Intent.ACTION_VIEW) return null
        return super.getInitialRoute()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPendingFile" -> {
                        result.success(pendingFileContent)
                        pendingFileContent = null
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
                    MethodChannel(messenger, channelName).invokeMethod("onFileReceived", content)
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
                // Only accept content that looks like a .dndchar file
                if (content.contains("\"character\"")) {
                    pendingFileContent = content
                }
            } catch (_: Exception) {}
        }
    }
}
