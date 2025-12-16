package dk.example.feedback.model.enumerations

enum class CalendarProvider {
    GOOGLE,
    APPLE,
    MICROSOFT,
    ZOOM;

    companion object {
        fun fromProdId(prodId: String?): CalendarProvider? {
            val value = prodId?.lowercase() ?: return null
            return when {
                "google" in value -> GOOGLE
                "apple" in value -> APPLE
                "microsoft" in value -> MICROSOFT
                "zoom" in value -> ZOOM
                else -> null
            }
        }
    }
}
