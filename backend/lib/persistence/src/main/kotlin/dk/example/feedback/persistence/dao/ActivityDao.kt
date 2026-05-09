package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.ActivityEntity
import dk.example.feedback.persistence.dao.utility.BaseCompanion
import dk.example.feedback.persistence.dao.utility.CommonColumns
import dk.example.feedback.persistence.table.ActivityInviteTable
import dk.example.feedback.persistence.table.ActivityTable
import dk.example.feedback.persistence.table.QuestionTable
import java.util.UUID
import org.jetbrains.exposed.dao.id.EntityID

class ActivityDao(id: EntityID<UUID>) : CommonColumns<ActivityEntity>(id, ActivityTable) {

    companion object : BaseCompanion<ActivityEntity, ActivityDao>(ActivityTable)

    var title by ActivityTable.title
    var agenda by ActivityTable.agenda
    var runMode by ActivityTable.runMode
    var sendEmails by ActivityTable.sendEmails
    var manager by AccountDao referencedOn ActivityTable.manager
    val questions by QuestionDao optionalReferrersOn QuestionTable.activity
    val invites by ActivityInviteDao referrersOn ActivityInviteTable.activity

    override fun toModel(): ActivityEntity {
        return ActivityEntity(
            id = id.value,
            title = title,
            agenda = agenda,
            runMode = runMode,
            sendEmails = sendEmails,
            createdAt = dateCreated,
            updatedAt = lastUpdate,
            questions = questions.map { it.toModel() },
            invites = invites.map { it.toModel() },
            manager = manager.toModel(),
        )
    }
}
