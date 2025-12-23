//package dk.example.feedback.utils
//
//import dk.example.feedback.model.enumerations.Role
//import org.springframework.security.core.authority.SimpleGrantedAuthority
//import org.springframework.security.oauth2.jwt.Jwt
//import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors
//
//class MockJwtFactory(private val userId: String) {
//    private fun generateJwt(
//        userId: String,
//        role: Role? = null
//    ): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor {
//
//        val jwtBuilder = Jwt.withTokenValue("mock-token-$userId")
//            .header("alg", "RS256") // or whatever header(s) you need
//            .claim("sub", userId)
//            .subject(userId)
//        // If role is not null, set it as a claim
//        val r = SecurityMockMvcRequestPostProcessors.jwt().jwt(jwtBuilder.build())
//        role?.let {
//            // store a list of role strings if you plan on multiple roles
//            jwtBuilder.claim("role", it.toString())
//            r.authorities(SimpleGrantedAuthority(role.value))
//        }
//        r.jwt {
//            it.subject(userId)
//        }
//        return r.jwt(jwtBuilder.build())
//    }
//
//    fun anonymousToken(): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor =
//        generateJwt(userId = userId, role = null)
//
//    fun participantToken(): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor =
//        generateJwt(userId = userId, role = Role.Participant)
//
//    fun managerToken(): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor =
//        generateJwt(userId = userId, role = Role.Manager)
//}
