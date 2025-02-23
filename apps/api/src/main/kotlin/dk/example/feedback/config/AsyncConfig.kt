//package dk.example.feedback.config
//
//import java.util.concurrent.Executor
//import java.util.concurrent.Executors
//import org.springframework.context.annotation.Bean
//import org.springframework.context.annotation.Configuration
//import org.springframework.scheduling.annotation.EnableAsync
//import org.springframework.security.concurrent.DelegatingSecurityContextExecutorService
//
//@Configuration
//@EnableAsync
//class AsyncConfig {
//    @Bean
//    fun taskExecutor(): Executor {
//        val executor = Executors.newCachedThreadPool()
//        return DelegatingSecurityContextExecutorService(executor)
//    }
//}
