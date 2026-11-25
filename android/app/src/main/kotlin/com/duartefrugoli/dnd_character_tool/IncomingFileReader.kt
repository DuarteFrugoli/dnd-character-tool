package com.duartefrugoli.dnd_character_tool

import java.util.ArrayDeque
import java.util.concurrent.Executor
import java.util.concurrent.ExecutorService

/** Reads on [worker], then hands results to Flutter on [main].
 *
 * Call the public methods on the Activity's main thread. [main] must enqueue
 * callbacks, so pending notifications run after the getPendingFile reply.
 */
internal class IncomingFileReader(
    private val worker: ExecutorService,
    private val main: Executor,
    private val onFileReceived: (String) -> Unit,
) {
    @Volatile private var closed = false
    private var listenerReady = false
    private val pending = ArrayDeque<String>()

    fun read(loadContent: () -> String?) {
        if (closed) return
        worker.execute {
            if (closed) return@execute
            val content = try {
                loadContent()
            } catch (_: Exception) {
                null
            } ?: return@execute
            if (closed) return@execute
            // Keep file access and potentially large string scans off the UI thread.
            if (!content.contains("\"character\"") && !content.contains("\"characters\"")) {
                return@execute
            }
            if (closed) return@execute
            main.execute {
                if (!closed) {
                    pending.addLast(content)
                    if (listenerReady) deliverPendingFiles()
                }
            }
        }
    }

    fun takePendingFile(): String? {
        if (closed) return null
        listenerReady = true
        val first = pending.pollFirst()
        // The channel's String response handles the first file. Preserve any
        // additional files and notify only after the caller has sent its reply.
        if (pending.isNotEmpty()) main.execute { deliverPendingFiles() }
        return first
    }

    private fun deliverPendingFiles() {
        while (!closed && pending.isNotEmpty()) onFileReceived(pending.removeFirst())
    }

    fun close() {
        closed = true
        pending.clear()
        worker.shutdownNow()
    }
}
