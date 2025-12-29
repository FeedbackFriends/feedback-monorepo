package dk.example.feedback.persistence.pincodegenerator

import dk.example.feedback.persistence.repo.EventRepo

class PinCodeGenerator(
    val eventRepo: EventRepo,
    ) {
        fun generate(): String {
            repeat(10) {
                val pinCode = (1000..9999).random().toString()
                if (!eventRepo.pinCodeExists(pinCode)) return pinCode
            }
            throw IllegalStateException("Failed to generate a unique pin code after multiple attempts")
        }
    }