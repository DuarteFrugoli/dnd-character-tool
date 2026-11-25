package com.duartefrugoli.dnd_character_tool

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val fileChannelName = "dnd.character/file_import"
    private val screenChannelName = "dnd.character/screen"
    private var fileChannel: MethodChannel? = null
    private val fileCallbacks = Handler(Looper.getMainLooper())
    private val fileReader = IncomingFileReader(
        worker = Executors.newSingleThreadExecutor(),
        main = Executor { callback -> fileCallbacks.post(callback) },
        onFileReceived = { content -> fileChannel?.invokeMethod("onFileReceived", content) },
    )

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
        fileChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fileChannelName)
        fileChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getPendingFile" -> {
                    result.success(fileReader.takePendingFile())
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
            // Strip the data URI before passing to super so Flutter's navigation
            // channel does not forward the content:// URI to go_router.
            super.onNewIntent(Intent(intent).apply { data = null })
            handleIntent(intent)
            return
        }
        super.onNewIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        if (intent.action != Intent.ACTION_VIEW) return
        val uri = intent.data ?: return
        val resolver = contentResolver
        fileReader.read {
            resolver.openInputStream(uri)?.bufferedReader()?.use { it.readText() }
        }
    }

    override fun onDestroy() {
        fileReader.close()
        fileCallbacks.removeCallbacksAndMessages(null)
        fileChannel?.setMethodCallHandler(null)
        fileChannel = null
        super.onDestroy()
    }
}
