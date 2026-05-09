package dk.example.feedback.persistence.table

import dk.example.feedback.model.enumerations.ActivityRunMode
import dk.example.feedback.persistence.dao.utility.CommonColumnsTbl
import org.jetbrains.exposed.sql.ReferenceOption

object ActivityTable : CommonColumnsTbl("activity") {
    val title = text("title")
    val agenda = text("agenda").nullable()
    val runMode = enumerationByName("run_mode", 255, ActivityRunMode::class)
    val sendEmails = bool("send_emails").default(false)
    val manager = reference("manager_id", AccountTable, onDelete = ReferenceOption.CASCADE)
}
