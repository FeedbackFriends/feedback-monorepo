package dk.example.feedback.service

import dk.example.feedback.dto.SupportSubmissionReceipt
import dk.example.feedback.model.exceptions.InvalidSupportSubmissionException
import dk.example.feedback.model.exceptions.SupportSubmissionConflictException
import dk.example.feedback.model.database.SupportSubmissionEntity
import dk.example.feedback.model.enumerations.SupportSubmissionKind
import dk.example.feedback.model.exceptions.ForbiddenResourceAccessException
import dk.example.feedback.payloads.SupportSubmissionInput
import dk.example.feedback.persistence.repo.AccountRepo
import dk.example.feedback.persistence.repo.SupportSubmissionRepo
import org.springframework.stereotype.Service
import java.time.OffsetDateTime
import java.time.ZoneOffset

@Service
class SupportSubmissionService(private val repo: SupportSubmissionRepo, private val accountRepo: AccountRepo) {
    fun submit(input: SupportSubmissionInput, accountId: String): SupportSubmissionReceipt {
        val message = input.message?.trim()?.takeIf { it.isNotEmpty() }
        val expected = input.expectedBehavior?.trim()?.takeIf { it.isNotEmpty() }
        when (input.kind) {
            SupportSubmissionKind.ProductFeedback -> if ((input.rating == null && message == null) || expected != null) {
                throw InvalidSupportSubmissionException()
            }
            SupportSubmissionKind.BugReport -> if (message == null || input.rating != null) {
                throw InvalidSupportSubmissionException()
            }
        }
        accountRepo.getAccount(accountId)
        val submission = SupportSubmissionEntity(
            id = input.id, accountId = accountId, kind = input.kind, rating = input.rating,
            message = message, expectedBehavior = expected,
            contactEmail = input.contactEmail?.trim()?.takeIf { it.isNotEmpty() },
            appVersion = input.metadata.appVersion.trim(), appBuild = input.metadata.appBuild.trim(),
            osVersion = input.metadata.osVersion.trim(), createdAt = OffsetDateTime.now(ZoneOffset.UTC),
        )
        val stored = repo.createOrGet(submission)
        if (stored.accountId != accountId) throw ForbiddenResourceAccessException("Support submission belongs to another account")
        if (stored.copy(createdAt = submission.createdAt) != submission) throw SupportSubmissionConflictException()
        return SupportSubmissionReceipt(stored.id, stored.createdAt)
    }
}
