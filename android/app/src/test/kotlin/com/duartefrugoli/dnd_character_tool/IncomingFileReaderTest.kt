package com.duartefrugoli.dnd_character_tool

import java.io.IOException
import java.util.ArrayDeque
import java.util.concurrent.AbstractExecutorService
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import org.junit.Assert.*
import org.junit.Test

class IncomingFileReaderTest {
    private val character = """{"character":{"name":"Hero"}}"""
    private val backup = """{"characters":[]}"""

    private class QueuedWorker : AbstractExecutorService() {
        val tasks = ArrayDeque<Runnable>()
        private var stopped = false
        override fun execute(command: Runnable) { tasks.addLast(command) }
        override fun shutdown() { stopped = true }
        override fun shutdownNow(): MutableList<Runnable> {
            stopped = true
            return tasks.toMutableList().also { tasks.clear() }
        }
        override fun isShutdown() = stopped
        override fun isTerminated() = stopped && tasks.isEmpty()
        override fun awaitTermination(timeout: Long, unit: TimeUnit) = isTerminated
        fun drain() { while (tasks.isNotEmpty()) tasks.removeFirst().run() }
    }

    private class Fixture {
        val worker = QueuedWorker()
        val main = ArrayDeque<Runnable>()
        val delivered = mutableListOf<String>()
        val reader = IncomingFileReader(worker, Executor { main.addLast(it) }, delivered::add)
        fun drainMain() { while (main.isNotEmpty()) main.removeFirst().run() }
        fun finishRead() { worker.drain(); drainMain() }
    }

    @Test fun coldStartKeepsTheFileUntilFlutterIsReady() {
        val f = Fixture()
        f.reader.read { character }
        f.finishRead()
        assertTrue(f.delivered.isEmpty())
        assertEquals(character, f.reader.takePendingFile())
        assertNull(f.reader.takePendingFile())
        assertTrue(f.delivered.isEmpty())
    }

    @Test fun coldStartReadingAfterFlutterIsReadyDeliversExactlyOnce() {
        val f = Fixture()
        f.reader.read { backup }
        assertNull(f.reader.takePendingFile())
        f.worker.drain()
        assertTrue(f.delivered.isEmpty()) // Worker cannot call the Flutter channel.
        f.drainMain()
        assertEquals(listOf(backup), f.delivered)
        assertNull(f.reader.takePendingFile())
    }

    @Test fun alreadyRunningAppReceivesFilesInOrderOnTheMainExecutor() {
        val f = Fixture()
        f.reader.takePendingFile()
        f.reader.read { character }
        f.reader.read { backup }
        f.worker.drain()
        assertTrue(f.delivered.isEmpty())
        f.drainMain()
        assertEquals(listOf(character, backup), f.delivered)
    }

    @Test fun multiplePendingFilesAreNotLostOrDuplicated() {
        val f = Fixture()
        f.reader.read { character }
        f.reader.read { backup }
        f.finishRead()
        assertEquals(character, f.reader.takePendingFile())
        assertTrue(f.delivered.isEmpty())
        f.drainMain()
        assertEquals(listOf(backup), f.delivered)
        assertNull(f.reader.takePendingFile())
    }

    @Test fun unreadableAndUnrelatedFilesDoNotPreventLaterImports() {
        val f = Fixture()
        f.reader.takePendingFile()
        f.reader.read { throw IOException("provider unavailable") }
        f.reader.read { null }
        f.reader.read { "unrelated content" }
        f.reader.read { character }
        f.finishRead()
        assertEquals(listOf(character), f.delivered)
    }

    @Test fun aNewResultCannotOvertakeAnOlderPendingFile() {
        val f = Fixture()
        f.reader.read { character }
        f.reader.read { backup }
        f.finishRead()
        val latest = """{"character":{"name":"Latest"}}"""
        f.reader.read { latest }
        f.worker.drain() // Its callback is ahead of the pending-file notification.
        assertEquals(character, f.reader.takePendingFile())
        f.drainMain()
        assertEquals(listOf(backup, latest), f.delivered)
    }

    @Test fun destroyingTheActivityDropsQueuedCallbacksAndStopsTheWorker() {
        val f = Fixture()
        f.reader.takePendingFile()
        f.reader.read { character }
        f.worker.drain()
        f.reader.close()
        f.drainMain()
        assertTrue(f.delivered.isEmpty())
        assertTrue(f.worker.isShutdown)
        f.reader.read { fail("Must not read after Activity destruction"); null }
        assertTrue(f.worker.tasks.isEmpty())
    }

    @Test fun destroyingTheActivityClearsPendingFilesAndUnstartedReads() {
        val f = Fixture()
        f.reader.read { character }
        f.finishRead()
        f.reader.read { fail("Queued read must be cancelled"); null }
        f.reader.close()
        f.finishRead()
        assertNull(f.reader.takePendingFile())
        assertTrue(f.delivered.isEmpty())
    }

    @Test fun aSlowProviderDoesNotBlockTheCallingThread() {
        val worker = Executors.newSingleThreadExecutor()
        val started = CountDownLatch(1)
        val release = CountDownLatch(1)
        val callerReturned = CountDownLatch(1)
        val callbackQueued = CountDownLatch(1)
        val callbacks = java.util.concurrent.ConcurrentLinkedQueue<Runnable>()
        val delivered = mutableListOf<String>()
        val reader = IncomingFileReader(worker, Executor {
            callbacks.add(it)
            callbackQueued.countDown()
        }, delivered::add)
        reader.takePendingFile()
        val caller = Thread {
            reader.read {
                started.countDown()
                check(release.await(15, TimeUnit.SECONDS))
                character
            }
            callerReturned.countDown()
        }
        try {
            caller.start()
            assertTrue("Provider must begin reading", started.await(5, TimeUnit.SECONDS))
            assertTrue("Caller must return while provider is still blocked", callerReturned.await(5, TimeUnit.SECONDS))
            assertEquals(1L, release.count)
            assertTrue(delivered.isEmpty())
            release.countDown()
            assertTrue(callbackQueued.await(5, TimeUnit.SECONDS))
            callbacks.remove().run()
            assertEquals(listOf(character), delivered)
        } finally {
            release.countDown()
            caller.join(2000)
            reader.close()
        }
    }

    @Test fun aProviderReturningAfterActivityDestructionCannotNotifyFlutter() {
        val worker = Executors.newSingleThreadExecutor()
        val started = CountDownLatch(1)
        val release = CountDownLatch(1)
        val callbackCount = java.util.concurrent.atomic.AtomicInteger()
        val reader = IncomingFileReader(worker, Executor { callbackCount.incrementAndGet() }) {
            fail("A destroyed Activity must not deliver files")
        }
        reader.takePendingFile()
        reader.read {
            started.countDown()
            try {
                check(release.await(15, TimeUnit.SECONDS))
            } catch (_: InterruptedException) {
                // Even a provider that returns content on cancellation is safe.
            }
            character
        }
        try {
            assertTrue(started.await(5, TimeUnit.SECONDS))
            reader.close()
            assertTrue(worker.awaitTermination(5, TimeUnit.SECONDS))
            assertEquals(0, callbackCount.get())
        } finally {
            release.countDown()
            reader.close()
        }
    }
}
