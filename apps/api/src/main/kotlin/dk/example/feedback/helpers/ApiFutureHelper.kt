package dk.example.feedback.helpers

import com.google.api.core.ApiFuture
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

suspend fun <T> ApiFuture<T>.await(): T = suspendCancellableCoroutine { cont ->
    this.addListener(
        {
            try {
                cont.resume(this.get())
            } catch (e: Exception) {
                cont.resumeWithException(e)
            }
        },
        Runnable::run
    )
}
