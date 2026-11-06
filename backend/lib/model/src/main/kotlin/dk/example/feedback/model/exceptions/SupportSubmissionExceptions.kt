package dk.example.feedback.model.exceptions

class InvalidSupportSubmissionException : RuntimeException("Invalid support submission")
class SupportSubmissionConflictException : RuntimeException("Submission ID already used for different content")
