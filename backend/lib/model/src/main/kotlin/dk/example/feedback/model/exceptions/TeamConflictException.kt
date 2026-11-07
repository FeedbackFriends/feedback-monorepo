package dk.example.feedback.model.exceptions

class TeamConflictException : RuntimeException("Team state changed or account already belongs to a team")

class InvalidTeamInputException : RuntimeException("Invalid team input")
open class TeamNotFoundException : RuntimeException("Team or invitation not found")

class InvalidTeamInviteException : TeamNotFoundException()
