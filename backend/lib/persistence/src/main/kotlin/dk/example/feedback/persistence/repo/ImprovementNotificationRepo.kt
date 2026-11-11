package dk.example.feedback.persistence.repo

import dk.example.feedback.persistence.table.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.util.UUID

@Component
@Transactional
class ImprovementNotificationRepo {
    // The callback sends generic copy only. Tokens and current membership are resolved at dispatch,
    // never retained in the queue. Failed sends roll back acknowledgement for a later retry.
    fun dispatch(send: (String, UUID, UUID) -> Boolean) {
        ImprovementNotificationTable.selectAll().orderBy(ImprovementNotificationTable.id).limit(100).forUpdate().toList().forEach { row ->
            val suggestion = SuggestionTable.selectAll().where { SuggestionTable.id eq row[ImprovementNotificationTable.suggestion] }.singleOrNull()
            if (suggestion != null && !suggestion[SuggestionTable.withdrawn]) {
                val team = suggestion[SuggestionTable.team]
                val members = TeamMembershipTable.selectAll().where { TeamMembershipTable.team eq team }.map { it[TeamMembershipTable.account] }
                if (members.isNotEmpty()) {
                    FCMTokenTable.selectAll().where { FCMTokenTable.account inList members }.forEach {
                        val token = it[FCMTokenTable.id].value
                        if (!send(token, team, row[ImprovementNotificationTable.id])) {
                            FCMTokenTable.deleteWhere { FCMTokenTable.id eq token }
                        }
                    }
                }
            }
            ImprovementNotificationTable.deleteWhere { id eq row[ImprovementNotificationTable.id] }
        }
    }
}
