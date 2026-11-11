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
    val closedAt = long("closed_at").nullable()
    override val primaryKey = PrimaryKey(id)
}

object SuggestionSupportTable : Table("suggestion_support") {
    val suggestion = reference("suggestion_id", SuggestionTable.id)
    val account = reference("account_id", AccountTable.id)
    override val primaryKey = PrimaryKey(suggestion, account)
}

object SuggestionDecisionTable : Table("suggestion_decision") {
    val id = uuid("id")
    val suggestion = reference("suggestion_id", SuggestionTable.id)
    val revision = integer("revision")
    val status = varchar("status", 16)
    val explanation = varchar("explanation", 1000)
    // Compare normalized retry commands without retaining a historical account association.
    val requestFingerprint = varchar("request_fingerprint", 64)
    val responsibleName = varchar("responsible_name", 255)
    val followUpDate = varchar("follow_up_date", 10).nullable()
    val publishedAt = long("published_at")
    override val primaryKey = PrimaryKey(id)
}

object SuggestionTrialTable : Table("suggestion_trial") {
    val id = uuid("id")
    val suggestion = reference("suggestion_id", SuggestionTable.id)
    val revision = integer("revision")
    val decision = reference("decision_id", SuggestionDecisionTable.id)
    val change = varchar("trial_change", 1000)
    val intendedBenefit = varchar("intended_benefit", 1000)
    // No account FK: publication must not acquire another account lock after locking the suggestion.
    val responsibleFingerprint = varchar("responsible_fingerprint", 64)
    val responsibleName = varchar("responsible_name", 255)
    val requestFingerprint = varchar("request_fingerprint", 64)
    val startDate = varchar("start_date", 10)
    val endDate = varchar("end_date", 10)
    val followUpDate = varchar("follow_up_date", 10)
    val publishedAt = long("published_at")
    override val primaryKey = PrimaryKey(id)
}


object SuggestionEvaluationTable : Table("suggestion_evaluation") {
    val id = uuid("id")
    val suggestion = reference("suggestion_id", SuggestionTable.id)
    val trial = reference("trial_id", SuggestionTrialTable.id).uniqueIndex()
    val closesAt = long("closes_at")
    val summary = varchar("summary", 32).nullable()
    override val primaryKey = PrimaryKey(id)
}

// Fingerprints avoid acquiring another account FK lock after the suggestion lock.
// They remain internally linkable; they are never exposed through the API.
object SuggestionEvaluationResponseTable : Table("suggestion_evaluation_response") {
    val evaluation = reference("evaluation_id", SuggestionEvaluationTable.id)
    val accountFingerprint = varchar("account_fingerprint", 64)
    val answer = varchar("answer", 16).nullable()
    override val primaryKey = PrimaryKey(evaluation, accountFingerprint)
}

object SuggestionOutcomeTable : Table("suggestion_outcome") {
    val id = uuid("id")
    val suggestion = reference("suggestion_id", SuggestionTable.id)
    val trial = reference("trial_id", SuggestionTrialTable.id).uniqueIndex()
    val outcome = varchar("outcome", 16)
    val explanation = varchar("explanation", 1000)
    val publishedAt = long("published_at")
    override val primaryKey = PrimaryKey(id)
}


// Permanent, content-free reservation. No team, author, timestamps, or command data.
object SuggestionReceiptTable : Table("suggestion_receipt") {
    val id = uuid("id")
    override val primaryKey = PrimaryKey(id)
}


object ImprovementNotificationTable : Table("improvement_notification") {
    val id = uuid("id")
    val suggestion = reference("suggestion_id", SuggestionTable.id)
    override val primaryKey = PrimaryKey(id)
}
