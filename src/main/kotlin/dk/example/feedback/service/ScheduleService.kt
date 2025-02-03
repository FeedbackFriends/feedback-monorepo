package dk.example.feedback.service

import dk.example.feedback.persistence.repo.EventRepo
import java.time.Duration
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class ScheduleService(
    private val eventRepo: EventRepo,
) {

    @Scheduled(cron = "0 0 0 * * *", zone = "Europe/Copenhagen")
    fun cleanUpPinsScheduler() {
        val sevenDays = Duration.ofDays(7)
        eventRepo.cleanUpPinCodesWithStopTimeOlderThan(duration = sevenDays)
    }
}
