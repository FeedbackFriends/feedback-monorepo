package dk.example.feedback.utils

import dk.example.feedback.model.enumerations.Role
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors

class MockJwtFactory(private val userId: String) {
    private fun generateJwt(
        userId: String,
        role: Role? = null
    ): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor {

        val jwtBuilder = Jwt.withTokenValue("mock-token-$userId")
            .header("alg", "RS256") // or whatever header(s) you need
            .claim("sub", userId)
            .subject(userId)
        // If role is not null, set it as a claim
        val r = SecurityMockMvcRequestPostProcessors.jwt().jwt(jwtBuilder.build())
        role?.let {
            // store a list of role strings if you plan on multiple roles
            jwtBuilder.claim("role", it.toString())
            r.authorities(SimpleGrantedAuthority(role.value))
        }
        r.jwt {
            it.subject(userId)
        }
        return r.jwt(jwtBuilder.build())
    }

    fun anonymousToken(): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor =
        generateJwt(userId = userId, role = null)

    fun participantToken(): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor =
        generateJwt(userId = userId, role = Role.Participant)

    fun organizerToken(): SecurityMockMvcRequestPostProcessors.JwtRequestPostProcessor =
        generateJwt(userId = userId, role = Role.Organizer)
}

//class MockJwtFactory(private val userId: String) {
//
//    private fun generateJwt(userId: String, role: Role? = null): Jwt {
//        val jwtBuilder =  Jwt.withTokenValue("mock-token-$userId")
//            .header("alg", "RS256") // or whatever header(s) you need
//            .claim("sub", userId)
//            .subject(userId)
//        // If role is not null, set it as a claim
//        role?.let {
//            // store a list of role strings if you plan on multiple roles
//            jwtBuilder.claim("role", it.toString())
//        }
//
//        return jwtBuilder.build()
//    }
//
//    fun anonymousToken(): Jwt =
//        generateJwt(userId = userId, role = null)
//
//    fun participantToken(): Jwt =
//        generateJwt(userId = userId, role = Role.Participant)
//
//    fun organizerToken(): Jwt =
//        generateJwt(userId = userId, role = Role.Organizer)
//}

//class MockJwtFactoryTest {
//
//    private val userId = "test-user-id"
//    private val factory = MockJwtFactory(userId)
//
//    @Test
//    fun `anonymousToken should generate a token without a role claim`() {
//        val token: Jwt = factory.anonymousToken()
//
//        assertEquals(userId, token.getAccountId())
//
//        val roleClaim = token.role()
//        assertNull(roleClaim, "Expected 'role' claim to be null or absent for anonymousToken.")
//    }
//
//    @Test
//    fun `participantToken should generate a token with the role Participant`() {
//        val token: Jwt = factory.participantToken()
//
//        assertEquals(userId, token.getAccountId())
//
//        val roleClaim = token.role()
//        assertNotNull(roleClaim, "Role claim should not be null for participantToken.")
//        assertTrue(roleClaim!!.toString().contains("Participant"), "Expected 'Participant' in role claim.")
//    }
//
//    @Test
//    fun `organizerToken should generate a token with the role Organizer`() {
//        val token: Jwt = factory.organizerToken()
//
//        assertEquals(userId, token.getAccountId())
//
//        val roleClaim = token.role()
//        assertNotNull(roleClaim, "Role claim should not be null for organizerToken.")
//        assertTrue(roleClaim!!.toString().contains("Organizer"), "Expected 'Organizer' in role claim.")
//    }
//
//    @Test
//    fun hello() {
//        val h = MockJwtFactory("User1").anonymousToken()
//        assertTrue(h.getAccountId().equals("User1"))
//        val t = MockJwtFactory("helloWorld").anonymousToken()
//        assertTrue(t.getAccountId().equals("helloWorld"))
//    }
//}
//
//
