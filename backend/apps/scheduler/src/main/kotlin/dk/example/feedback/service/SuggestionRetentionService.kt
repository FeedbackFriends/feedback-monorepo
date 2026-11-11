package dk.example.feedback.service

import dk.example.feedback.persistence.repo.SuggestionRepo
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

// Disabled by default. Enabling requires verified backup expiry and restore-before-serving purge.
@Service
@ConditionalOnProperty(name = ["improvements.retention.enabled"], havingValue = "true")
class SuggestionRetentionService(private val suggestions: SuggestionRepo) {
    @Scheduled(cron = "0 0 2 * * *", zone = "UTC")
    fun purge() {
        suggestions.purgeClosedSuggestions()
    }
}
