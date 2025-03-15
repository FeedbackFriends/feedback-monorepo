package dk.example.feedback.controller

// TODO: fix me
//@ControllerAdvice
//class ControllerAdvisor() {
//
//    @ExceptionHandler(Exception::class)
//    fun handleException(exception: Exception, request: HttpServletRequest): ResponseEntity<ApiError> {
//
//        val domainCode = if (exception is DomainException) exception.domainCode else null
//
//        val error = ApiError(
//            timestamp = OffsetDateTime.now(),
//            message = exception.message ?: "An unexpected error occurred",
//            domainCode = domainCode,
//            exceptionType = exception.javaClass.simpleName,
//            path = request.requestURI,
//        )
//
//        return ResponseEntity(error, HttpStatus.INTERNAL_SERVER_ERROR)
//    }
//}
