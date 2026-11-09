package dk.example.feedback.persistence.table

import org.jetbrains.exposed.sql.Table

object SuggestionTable : Table("team_suggestion") {
    val id = uuid("id")
    val team = reference("team_id", TeamTable.id)
    val author = reference("author_id", AccountTable.id).nullable()
    val problem = varchar("problem", 1000)
    val impact = varchar("impact", 1000)
    val solution = varchar("solution", 1000).nullable()
    val reported = bool("reported").default(false)
    val withdrawn = bool("withdrawn").default(false)
    override val primaryKey = PrimaryKey(id)
}

object SuggestionSupportTable : Table("suggestion_support") {
    val suggestion = reference("suggestion_id", SuggestionTable.id)
    val account = reference("account_id", AccountTable.id)
    override val primaryKey = PrimaryKey(suggestion, account)
}
