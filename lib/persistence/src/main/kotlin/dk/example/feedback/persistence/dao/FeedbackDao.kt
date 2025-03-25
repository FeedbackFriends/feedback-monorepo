package dk.example.feedback.persistence.dao

import dk.example.feedback.model.database.FeedbackEntity
import dk.example.feedback.persistence.dao.utility.BaseCompanion
import dk.example.feedback.persistence.dao.utility.CommonColumns
import dk.example.feedback.persistence.table.FeedbackTable
import java.util.*
import org.jetbrains.exposed.dao.id.EntityID

class FeedbackDao(id: EntityID<UUID>): CommonColumns<FeedbackEntity>(id, FeedbackTable) {

    companion object : BaseCompanion<FeedbackEntity, FeedbackDao>(FeedbackTable)

    var type by FeedbackTable.type
    var comment by FeedbackTable.comment
    var emoji by FeedbackTable.emoji
    var thumbsUpThumpsDown by FeedbackTable.thumbsUpThumpsDown
    var oneToTen by FeedbackTable.oneToTen
    var opinion by FeedbackTable.opinion
    var question by QuestionDao referencedOn FeedbackTable.question
    var manager by AccountDao referencedOn FeedbackTable.manager
    var participant by AccountDao optionalReferencedOn FeedbackTable.participant
    var seenByManager by FeedbackTable.seenBefore

    override fun toModel(): FeedbackEntity {
        return FeedbackEntity(
            feedbackType = type,
            comment = comment,
            emoji = emoji,
            thumbsUpThumpsDown = thumbsUpThumpsDown,
            oneToTen = oneToTen,
            opinion = opinion,
            questionId = question.id.value,
            id = id.value,
            participantId = participant?.id?.value,
            seenByManager = seenByManager
        )
    }
}
