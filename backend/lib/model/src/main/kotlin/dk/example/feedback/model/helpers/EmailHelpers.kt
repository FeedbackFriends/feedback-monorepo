package dk.example.feedback.model.helpers

fun String?.normalizedEmail(): String? {
    return this?.trim()?.lowercase()?.takeIf { it.isNotEmpty() }
}
