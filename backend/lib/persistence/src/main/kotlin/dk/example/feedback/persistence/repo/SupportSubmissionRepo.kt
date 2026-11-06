package dk.example.feedback.persistence.repo

import dk.example.feedback.model.database.SupportSubmissionEntity
import dk.example.feedback.persistence.table.SupportSubmissionTable
import dk.example.feedback.persistence.table.AccountTable
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.sql.insertIgnore
import org.jetbrains.exposed.sql.selectAll
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
@Transactional
class SupportSubmissionRepo {
    fun createOrGet(submission: SupportSubmissionEntity): SupportSubmissionEntity {
        SupportSubmissionTable.insertIgnore {
            it[id] = EntityID(submission.id, SupportSubmissionTable)
            it[account] = EntityID(submission.accountId, AccountTable)
            it[kind] = submission.kind
            it[rating] = submission.rating
            it[message] = submission.message
            it[expectedBehavior] = submission.expectedBehavior
            it[contactEmail] = submission.contactEmail
            it[appVersion] = submission.appVersion
            it[appBuild] = submission.appBuild
            it[osVersion] = submission.osVersion
            it[createdAt] = submission.createdAt
        }
        val row = SupportSubmissionTable.selectAll().where { SupportSubmissionTable.id eq submission.id }.single()
        return SupportSubmissionEntity(
            id = row[SupportSubmissionTable.id].value,
            accountId = row[SupportSubmissionTable.account].value,
            kind = row[SupportSubmissionTable.kind],
            rating = row[SupportSubmissionTable.rating],
            message = row[SupportSubmissionTable.message],
            expectedBehavior = row[SupportSubmissionTable.expectedBehavior],
            contactEmail = row[SupportSubmissionTable.contactEmail],
            appVersion = row[SupportSubmissionTable.appVersion],
            appBuild = row[SupportSubmissionTable.appBuild],
            osVersion = row[SupportSubmissionTable.osVersion],
            createdAt = row[SupportSubmissionTable.createdAt],
        )
    }
}
