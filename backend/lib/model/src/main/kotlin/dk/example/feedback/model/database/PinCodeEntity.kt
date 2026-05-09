package dk.example.feedback.model.database


data class PinCodeEntity(
    val pinCode: String,
    val session: SessionEntity,
) {
    val event: SessionEntity
        get() = session
}
