package dk.example.feedback.service

import dk.example.feedback.firebase.FirebaseService
import dk.example.feedback.persistence.repo.ImprovementNotificationRepo
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class ImprovementNotificationService(private val notifications: ImprovementNotificationRepo, private val firebase: FirebaseService) {
    @Scheduled(fixedDelay = 10000)
    fun send() {
        notifications.dispatch(firebase::pushImprovementNotification)
    }
}
