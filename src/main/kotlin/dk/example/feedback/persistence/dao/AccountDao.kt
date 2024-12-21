package dk.example.feedback.persistence.dao

import dk.example.feedback.model.db_models.AccountEntity
import dk.example.feedback.persistence.table.*
import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.id.EntityID


class AccountDao(id: EntityID<String>): Entity<String>(id){

    companion object : EntityClass<String, AccountDao>(AccountTable)

    var name by AccountTable.name
    var email by AccountTable.email
    var fcmToken by AccountTable.fcmToken
    var phoneNumber by AccountTable.phoneNumber
    var createdAt by AccountTable.createdAt
    var updatedAt by AccountTable.updatedAt
    var ratingPrompted by AccountTable.ratingPrompted
    val events by EventDao referrersOn EventTable.manager
    val questions by QuestionDao referrersOn QuestionTable.manager


    fun toModel() = AccountEntity(
        id = id.value,
        name = name,
        email = email,
        fcmToken = fcmToken,
        phoneNumber = phoneNumber,
        ratingPrompted = ratingPrompted,
    )
}
